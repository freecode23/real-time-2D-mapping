# Prerequsites
## 1. Set the OS for your Pi
The easisest way to set this is to use raspberry pi imager.
you can install it using:
```
sudo snap install rpi-imager
```
1. Select the hardware: Raspberry Pi4
2. Select Ubuntu 20.04.5 (64 bits) as the OS.
3. Enable ssh by manually change the file in the SSD
4. Set up the wifi and password by manually change the file in SSD

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


## 2.In RPi:
1. ssh into your Pi:


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
1. Check the scan topic:
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

2. Run hector slam:
```
roslaunch hector_slam_launch tutorial.launch
```

# References
https://github.com/robopeak/rplidar_ros
https://github.com/tu-darmstadt-ros-pkg/hector_slam

Make sure the following has been modified.
In `hector_slam-noetic-devel/hector_mapping/launch/mapping_default.launch` on line 5 , 6, and 55 to say that we will not have a base_footprint and that our baselink, that is we are on the ground and flat. The base link will be our odometry frame.

In `hector_slam-noetic-devel/hector_slam_launch/launch/tutorial.launch` to use real time instead of simulation on line 7.

