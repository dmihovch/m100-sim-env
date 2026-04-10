FROM osrf/ros:noetic-desktop-full

RUN apt-get update && apt-get install -y \
    ros-noetic-nmea-msgs \
    libsdl2-dev \
    ros-noetic-rviz-visual-tools \
    ros-noetic-gazebo-ros-control \
    ros-noetic-geographic-msgs \
    ros-noetic-hardware-interface \
    ros-noetic-controller-interface \
    ros-noetic-octomap-msgs \
    ros-noetic-octomap-ros \
	ros-noetic-ros-control \
	ros-noetic-ros-controllers \
    libgoogle-glog-dev \
    libyaml-cpp-dev \
    git cmake build-essential \
	clangd \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y curl gnupg2 && \
    curl -fsSL "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x27642B9FD7F1A161FC2524E3355A4FA515D7C855" | apt-key add - && \
    echo "deb http://ppa.launchpadcontent.net/maveonair/helix-editor/ubuntu focal main" > /etc/apt/sources.list.d/maveonair-helix.list && \
    apt-get update && \
    apt-get install -y helix \
    rm -rf /tmp/helix-23.10-x86_64-linux

RUN apt-get update && apt-get install -y ninja-build gettext cmake unzip curl nodejs npm build-essential git

RUN git clone https://github.com/dji-sdk/Onboard-SDK.git /tmp/Onboard-SDK && \
    mkdir -p /tmp/Onboard-SDK/build && \
    cd /tmp/Onboard-SDK/build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    rm -rf /tmp/Onboard-SDK

WORKDIR /workspace
COPY workspace/src /workspace/src

RUN sed -i 's/<revolute_gimbal_joint/<xacro:revolute_gimbal_joint/g' /workspace/src/dji_m100_description/urdf/gimbal.urdf.xacro
RUN sed -i '/<plugin name=.hitl_controller./,/<\/plugin>/d' /workspace/src/dji_m100_description/urdf/dji_m100_base.xacro

COPY config/swarm.launch /workspace/src/dji_m100_gazebo/launch/swarm.launch

RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

RUN echo "source /workspace/devel/setup.bash" >> /root/.bashrc
