FROM ros:noetic
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -qqy xpra ros-noetic-rviz
CMD /bin/bash -c 'xpra start --exec-wrapper="vglrun" --no-daemon --start="rosrun rviz rviz"'

FROM ros:noetic
VOLUME /tmp/.X11-unix
RUN apt update \
 && DEBIAN_FRONTEND=noninteractive apt install -y wget x11-xserver-utils ca-certificates ros-noetic-rviz mesa-utils libegl1-mesa\
 && echo "deb [arch=amd64] https://xpra.org/ focal main" > /etc/apt/sources.list.d/xpra.list \
 && wget -q https://xpra.org/gpg.asc -O- | apt-key add - \
 && apt update \
 && DEBIAN_FRONTEND=noninteractive apt install -y xpra \
 && wget https://sourceforge.net/projects/virtualgl/files/3.0/virtualgl_3.0_amd64.deb/download -O VirtualGL.deb \
 && dpkg -i VirtualGL.deb \
 && mkdir -p /run/user/0/xpra
ENTRYPOINT ["/bin/bash", "-c", "source /opt/ros/noetic/setup.bash && xpra start --mdns=no --webcam=no --no-daemon --exec-wrapper='vglrun' --start='rosrun rviz rviz'"]