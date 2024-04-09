# Dockerfile_test_node
FROM osrf/ros:noetic-desktop-full
WORKDIR /app

# 1. Copy your src/ directory into the container
# should not copy the build/, devel/, or install/ directories from your host machine to your Docker container.
# These directories are generated when you build your Catkin workspace,
# and their contents are specific to the system where you did the build.
COPY ./src/hector_slam-noetic-devel ./src/hector_slam-noetic-devel
COPY ./src/rplidar_ros-master ./src/rplidar_ros-master

# 2. Install  mesa libraries
RUN apt-get update && \
  apt-get install -y libgl1-mesa-glx libgl1-mesa-dri libxcb-cursor0 libxcb-xinerama0 \
  '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
  && rm -rf /var/lib/apt/lists/*


# 4. Run catkin_make to build your workspace
# This command sources the setup script for the ROS environment.
# This script sets a number of environment variables that ROS uses,
# such as ROS_ROOT, ROS_PACKAGE_PATH, and ROS_MASTER_URI, among others.
# It also adds various ROS tools to your PATH.
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd /app; catkin_make clean; catkin_make'

# 5. This command sources the setup script for your catkin workspace
# - This will be overriden by command in docker-compose file if you build the container using compose
# - source /app/devel/setup.bash
# This sets up the environment variables for the packages in your catkin workspace.
# For example, it modifies ROS_PACKAGE_PATH to include the packages in your workspace,
# and it adds any executables in your workspace to your PATH.
CMD ["bash", "-c", "source /app/devel/setup.bash && roslaunch hector_slam_launch tutorial.launch"]

