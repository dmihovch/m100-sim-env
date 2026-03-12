#!/usr/bin/env bash
set -e

echo "Building Workspace File Structure"
mkdir -p workspace/src



cd workspace/src


#echo "Cloning Core Swarm Engine"
#git clone https://github.com/dmihovch/flie_swarm_core.git

echo "Cloning DJI Repos"
git clone https://github.com/dji-m100-ros/dji_m100_gazebo.git
git clone https://github.com/dji-m100-ros/dji_m100_description.git
git clone https://github.com/dji-m100-ros/dji_m100_controllers_gazebo.git
git clone https://github.com/dji-sdk/Onboard-SDK-ROS.git

echo "Cloning Physics Engines (Hector & RotorS)"
git clone -b noetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_quadrotor.git
git clone https://github.com/tu-darmstadt-ros-pkg/hector_localization.git
git clone https://github.com/tu-darmstadt-ros-pkg/hector_models.git 
git clone https://github.com/tu-darmstadt-ros-pkg/hector_gazebo.git 
git clone https://github.com/ethz-asl/rotors_simulator.git 
git clone https://github.com/ethz-asl/mav_comm.git 


echo "Applying XML Fixes"

# fixing the dogshit (kidding!) code that these idiots (again, kidding!) wrote before me
sed -i 's/<revolute_gimbal_joint/<xacro:revolute_gimbal_joint/g' dji_m100_description/urdf/gimbal.urdf.xacro

echo "Creating swarm.launch..."
cat << 'EOF' > dji_m100_gazebo/launch/swarm.launch
<?xml version="1.0"?>
<launch>
  <include file="$(find gazebo_ros)/launch/empty_world.launch">
    <arg name="paused" value="false"/>
    <arg name="use_sim_time" value="true"/>
    <arg name="gui" value="true"/>
    <arg name="headless" value="false"/>
    <arg name="debug" value="false"/>
  </include>

  <group ns="swarm_member_1">
    <param name="robot_description" command="$(find xacro)/xacro '$(find dji_m100_description)/urdf/dji_m100.urdf.xacro' robot_namespace:=swarm_member_1" />
    <node name="spawn_robot" pkg="gazebo_ros" type="spawn_model" args="-param robot_description -urdf -x 0 -y 0 -z 0.5 -model swarm_member_1" respawn="false" output="screen" />
    <node name="robot_state_publisher" pkg="robot_state_publisher" type="robot_state_publisher">
      <param name="publish_frequency" type="double" value="50.0" />
      <param name="tf_prefix" value="swarm_member_1" /> 
    </node>
  </group>
</launch>
EOF

echo "Complete!"
