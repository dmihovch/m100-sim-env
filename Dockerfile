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

RUN apt-get update && apt-get install -y curl xz-utils && \
    curl -L https://github.com/helix-editor/helix/releases/download/23.10/helix-23.10-x86_64-linux.tar.xz | tar -xJ -C /tmp && \
    mv /tmp/helix-23.10-x86_64-linux/hx /usr/local/bin/ && \
    mv /tmp/helix-23.10-x86_64-linux/runtime /usr/local/lib/helix-runtime && \
    rm -rf /tmp/helix-23.10-x86_64-linux

ENV HELIX_RUNTIME=/usr/local/lib/helix-runtime

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
