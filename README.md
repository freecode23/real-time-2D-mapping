# Introduction
This project is about configure a Raspberry Pi for LiDAR-based mapping, specifically focusing on Hector SLAM and Cartographer mapping techniques. It covers the installation of necessary software on the Raspberry Pi, methods to run the system using Docker, and instructions for executing LiDAR mapping tasks. The documentation is structured to facilitate both Hector SLAM for real-time indoor mapping and Cartographer. Since we are working with two versions of ROS, we will use Docker to isolate and manage the different environments, ensuring compatibility and simplifying the deployment process for each version on the same hardware without interference.
NOTE: This has only been tried in dual booted Linux.  

![Screenshot 2024-04-11 at 3 47 31 PM](https://github.com/freecode23/real-time-2D-mapping/assets/67333705/443ac761-daf4-4661-9805-46e4a012e1a6)

## Table of Contents
1. [Prerequisites](#1-prerequisites)  
1.1 [PC Set Up](#11-pc-set-up)  
1.2 [Pi Set Up](#12-pi-set-up)  
2. [Quick Start](#2-quick-start)  
2.1. [Run with Docker](#option-1-to-run-in-docker)  
2.2. [Run without Docker](#option-2-run-lidar-and-mapping-without-docker)
# 1. Prerequisites

## 1.1 PC Set Up
1. Make sure you have ROS with RVIZ installed on your PC.

2. X11 Permissions: Allow the Docker container to access your X11 server on the host:
```
xhost +local:
```

3. If you want to ssh into your Pi with ethernet you need to go to Linux system settings, then go to `Wired` > IPv4 , then select Shared to other computers.

4. Instal `nmap` and `ifconfig`

## 1.2 Pi Set Up
We need to install Ubuntu 20.0.4 on your Pi.
The easiest way to set this is to use Raspberry Pi Imager.
You can install it using snap if you are in ubuntu 20.04 or lower:
```
sudo snap install rpi-imager
```
If you are using later version, you can install the official version here https://www.raspberrypi.com/software/.
1. Select the hardware: Raspberry Pi4
2. Select Ubuntu 20.04.5 (64 bits) as the OS.
3. Once the write is done, unplug ssd and replug. 
4. Run `lsblk` to list all block devices and their partitions. You should see something like:
```
sdb      8:16   1  59.7G  0 disk 
├─sdb1   8:17   1   256M  0 part /media/sherly/system-boot
└─sdb2   8:18   1   3.1G  0 part /media/sherly/writable

```
5. Go into the `system-boot` directory and change the wifi settings in the `network-setting` file like below:

```
version: 2
ethernets:
  eth0:
    dhcp4: true
    optional: true
wifis:
  wlan0:
    dhcp4: true
    optional: true
    access-points:
      "Home_wifi":
        password: "1123581321"
#      myworkwifi:
#        password: "correct battery horse staple"
#      workssid:
#        auth:
#          key-management: eap
#          method: peap
#          identity: "me@example.com"
#          password: "passw0rd"
#          ca-certificate: /etc/my_ca.pem
```
6. Also change the `/media/sherly/system-boot/user-data` to allow ssh. By adding the commands at the end of the file. If the above command doesn't work to connect your Pi to wifi you can also connect manually using nmcli.
```
## Run arbitrary commands at rc.local like time
runcmd:
- [sudo, apt, update]
- [sudo, apt, install, openssh-server, -y]
- [nmcli, radio, wifi, on]
- [nmcli, device, wifi, connect, "Home_wifi", password, "1123581321"]
#- [ ls, -l, / ]
#- [ sh, -xc, "echo $(date) ': hello world!'" ]
#- [ wget, "http://ubuntu.com", -O, /run/mydir/index.html ]
```

7. Get the ip address of your PC by entering `ifconfig` on your terminal. Then you should see something like below:
For wifi, look for the `lo` prefix:
```
wlo2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.110.220.198  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 2601:197:a7f:85f0:1e0c:912:4272:9f0f  prefixlen 64  scopeid 0x0<global>
```
For ethernet look for the `enx` prefix:
```
enx00e04c681fa8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.42.0.1  netmask 255.255.255.0  broadcast 10.42.0.255
        inet6 fe80::bd33:4018:36b3:fe02  prefixlen 64  scopeid 0x20<link>
        ether 00:e0:4c:68:1f:a8  txqueuelen 1000  (Ethernet)
        RX packets 116  bytes 13444 (13.4 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 178  bytes 141691 (141.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

Your PC ip address is the address after `inet`. So in this example it's `10.110.220.198` on wifi and `10.42.0.1` for ethernet.

8. With this IP address, you can locate your Raspberry Pi using `nmap`. We will use wifi connection in our example. Simply modify the IP address by replacing the last two segments with 0s. For instance, if your PC's IP address on wifi is 10.0.1.59, change the 1.59 to 0.0 like this:
```
nmap -p 22 10.0.0.0/24 --open
```
Then you should see something like:
```
Starting Nmap 7.80 ( https://nmap.org ) at 2024-04-05 17:11 EDT
Nmap scan report for sherly-Inspiron-15-3510 (10.42.0.1)
Host is up (0.00050s latency).

PORT   STATE SERVICE
22/tcp open  ssh

Nmap scan report for 10.110.87.113 
Host is up (0.00056s latency).

PORT   STATE SERVICE
22/tcp open  ssh

Nmap done: 256 IP addre
```
Note that for wifi, it can take up to 5 mins until you see the Pi address shows up in your nmap result.

9. Copy the ip address of the Pi which is the latest ip address listed.

10. Check that you can now `ssh` into your Raspberry PI from your PC:
```
ssh ubuntu@10.110.87.113 
```

11. It will ask you for the password if you ssh into this for the first time. The default password is `ubuntu`

12. You can now log in again using your newly set password.

NOTE:
1. If you encounter an error `Lzma library error: Corrupted input data` while writing the image to the SD card, this means the downloaded ubuntu OS image stored in cache is corrupted. To fix this, you can either try to find the cached image and delete them, or uninstall thre rpi-imager using `sudo snap remove rpi-imager`, then reinstall it so that the image will be redownloaded fresh.
2. Credits to: https://www.youtube.com/watch?v=P_-_1Ab5jFM


## 1.2 Docker Set Up.
1. Install Docker on you PC with docker compose included.
```
sudo apt update
sudo apt install ros-noetic-desktop-full
```

2. Replace all the ROS_MASTER_URI and ROS_IP with your own ip.

# 2. Quick Start
## NOTE: Make sure to replace the ip addresses in this instructions with your own ip addresses.
1. Set up your hardware as the picture above.

2. Make sure that Pi is connected to wifi:
```
nmap -p 22 10.0.0.0/24 --open
```

3. ssh into your Pi from your PC terminal:
```
ssh ubuntu@10.110.87.113 
```

3. Clone this repo to both your Pi and PC if you have not already done so.

## Option 1. To run in Docker:
On your PC, cd in to the docker/ directory.
```
docker compose -f docker-compose.pc.yaml up --build
```
On your Pi:
```
docker compose -f docker-compose.pi.yaml up --build
```

For Cartography, run the `carto` version of docker compose instead:
```
docker compose -f docker-compose.pc-carto.yaml up --build
docker compose -f docker-compose.pi-carto.yaml up --build
```

To bring down the containers:
On your PC:
```
docker compose -f docker-compose.pc.yaml down
```
On your Pi:
```
docker compose -f docker-compose.pi.yaml down
```

## Option 2. Run LiDAR and Mapping without Docker (Hector SLAM only)
### Step 1. Run ROS master node in your PC

1. Run the following on your PI, so that your pi can connect to the master node on your PC.
```
export ROS_MASTER_URI=http://10.110.220.198:11311
export ROS_IP=10.110.87.113 
```

2. Run the following on your PC:
```
export ROS_MASTER_URI=http://10.110.220.198:11311
export ROS_IP=10.110.220.198
```

3. Build the workspace
```
catkin_make
```

4 Then to ensure that your shell environment is updated to include the latest changes made to your ROS packages, including any new executables, libraries, or environment variables that were generated or modified during the build process, run:
```
source ./devel/setup.bash
```

5. Run master node:
```
roscore
```


### Step 2. Run LiDAR driver in Raspberry Pi
1. Add the authority to write to USB serial:
```
ls -l /dev |grep ttyUSB
sudo chmod 666 /dev/ttyUSB0
```

2. cd into the workspace directory and run:
```
catkin_make
source ./devel/setup.bash
```

3. Run RP lidar without RVIZ:
```
roslaunch rplidar_ros rplidar.launch
```
If you connect LiDAR directly to you PC you can visualize with RVIZ:
```
roslaunch rplidar_ros view_rplidar.launch
```

### Step 3. Run Hector SLAM in your PC
1. Check that the scan topic is publishing messages:
```
rostopic echo /scan
```
You should see:
```
header: 
  seq: 2166
  stamp: 
    secs: 1712259118
    nsecs: 210201248
  frame_id: "laser"
angle_min: -3.1241390705108643
angle_max: 3.1415927410125732
angle_increment: 0.008714509196579456
time_increment: 0.00018529882072471082
scan_time: 0.13322985172271729
range_min: 0.15000000596046448
range_max: 12.0
ranges: [inf, 0.4059999883174896
```

2. Run Hector SLAM:
```
source ./devel/setup.bash
roslaunch hector_slam_launch tutorial.launch
```

# References
https://github.com/robopeak/rplidar_ros  
https://github.com/tu-darmstadt-ros-pkg/hector_slam

Make sure the following has been modified.
In `hector_slam-noetic-devel/hector_mapping/launch/mapping_default.launch` on line 5 , 6, and 55 to say that we will not have a base_footprint and that our baselink, that is we are on the ground and flat. The base link will be our odometry frame.

In `hector_slam-noetic-devel/hector_slam_launch/launch/tutorial.launch` to use real time instead of simulation on line 7.

