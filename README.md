# Prerequisites
## 1. Install Ubuntu OS for your Pi
The easisest way to set this is to use raspberry pi imager.
you can install it using:
```
sudo snap install rpi-imager
```
1. Select the hardware: Raspberry Pi4
2. Select Ubuntu 20.04.5 (64 bits) as the OS.
3. Once the write is done, unplug ssd and replug. 
4. Then check into the files under the directory:
`/media/sherly/system-boot`

5. Run `lsblk` to list all block devices and their partitions. You should see something like:
```
sdb      8:16   1  59.7G  0 disk 
├─sdb1   8:17   1   256M  0 part /media/sherly/system-boot
└─sdb2   8:18   1   3.1G  0 part /media/sherly/writable

```
## TODO:
6. Go into the `system-boot` directory and change the wifi settings in the `network-setting` file.
7. Enable `ssh` by manually change the file in the SSD card.
8.
9.
10.
11. Check that you can now `ssh` into your Raspberry PI from your PC.

NOTE:
1. If you encounter an error `Lzma library error: Corrupted input data` while writing the image to the SD card, this means the downloaded ubuntu OS image stored in cache is corrupted. To fix this, you can either try to find the cached image and delete them, or uninstall thre rpi-imager using `sudo snap remove rpi-imager`, then reinstall it so that the image will be redownloaded fresh.
2. Credits to: https://www.youtube.com/watch?v=P_-_1Ab5jFM

## 2. Clone this github repo on your Pi.

# Build the workspace and Run master and the LiDAR Driver.
## 1. In your PC

1. Build the workspace
```
catkin_make
```

2. Then to ensure that your shell environment is updated to include the latest changes made to your ROS packages, including any new executables, libraries, or environment variables that were generated or modified during the build process, run:
```
source ./devel/setup.bash
```

3. Run master node:
```
roscore
```


## 2. In Raspberry Pi
1. ssh into your Pi from your PC terminal:


2. Add the authority to write to USB serial:
```
ls -l /dev |grep ttyUSB
sudo chmod 666 /dev/ttyUSB0
```

3. In your workspace directory, run:
```
catkin_make
source ./devel/setup.bash
```

4. Run RP lidar without RVIZ:
```
roslaunch rplidar_ros rplidar.launch
```
If you connect LiDAR directly to you PC you can visualize with RVIZ:
```
roslaunch rplidar_ros rplidar.launch
```

## 3. Run Hector SLAM on PC
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
roslaunch hector_slam_launch tutorial.launch
```

# References
https://github.com/robopeak/rplidar_ros  
https://github.com/tu-darmstadt-ros-pkg/hector_slam

Make sure the following has been modified.
In `hector_slam-noetic-devel/hector_mapping/launch/mapping_default.launch` on line 5 , 6, and 55 to say that we will not have a base_footprint and that our baselink, that is we are on the ground and flat. The base link will be our odometry frame.

In `hector_slam-noetic-devel/hector_slam_launch/launch/tutorial.launch` to use real time instead of simulation on line 7.

