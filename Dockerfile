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
    libgoogle-glog-dev \
    libyaml-cpp-dev \
    git cmake build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/dji-sdk/Onboard-SDK.git /tmp/Onboard-SDK && \
    mkdir -p /tmp/Onboard-SDK/build && \
    cd /tmp/Onboard-SDK/build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    rm -rf /tmp/Onboard-SDK

WORKDIR /workspace
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc
