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
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y ninja-build gettext cmake unzip curl nodejs npm build-essential git
RUN git clone -b stable https://github.com/neovim/neovim.git /tmp/neovim && \
    cd /tmp/neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    rm -rf /tmp/neovim

RUN git clone https://github.com/dji-sdk/Onboard-SDK.git /tmp/Onboard-SDK && \
    mkdir -p /tmp/Onboard-SDK/build && \
    cd /tmp/Onboard-SDK/build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    rm -rf /tmp/Onboard-SDK

WORKDIR /workspace
COPY workspace/src /workspace/src

RUN sed -i 's/<revolute_gimbal_joint/<xacro:revolute_gimbal_joint/g' /workspace/src/dji_m100_description/urdf/gimbal.urdf.xacro

COPY config/swarm.launch /workspace/src/dji_m100_gazebo/launch/swarm.launch

RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

RUN echo "source /workspace/devel/setup.bash" >> /root/.bashrc
