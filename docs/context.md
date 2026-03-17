# Project Context: DJI M100 Swarm Simulation and Deployment

## Objective
Develop swarm logic for multiple physical DJI M100 drones. The current phase is building a reliable ROS Noetic/Gazebo simulation environment to test the swarm logic before deploying to real hardware. 

## Environment
* **OS:** Ubuntu 20.04, running in Docker Container (running as root in `/workspace`)
* **ROS Version:** Noetic (rosversion: 1.17.4)
* **Simulation Engine:** Gazebo (gazebo_ros)
* **Target Hardware:** DJI M100

## Current State & Issues
We have successfully spawned a simulated drone and commanded it to take off (`Cmd Z: 0.3` via `geometry_msgs/Twist`), but the underlying architecture is fractured. 

The launch file (`roslaunch flie_swarm_core swarm.launch`) is currently mashing together incompatible hardware abstractions:
1.  **Hector Quadrotor Controllers:** Providing the actual physics and PID loops keeping the drone stable in Gazebo.
2.  **DJI ROS Control Plugin:** Loaded via the URDF, but its hardware interface is either crashing or being completely bypassed because Hector is handling the movement.

**The Deployment Blocker:** The custom swarm logic (`ros_swarm_adapter_node`) is currently publishing directly to Hector's `/swarm_member_1/command/twist` topic. Since a physical DJI M100 uses its own N1 flight controller and expects commands via the DJI ROS SDK (e.g., `sensor_msgs/Joy` to `/dji_sdk/flight_control_setpoint_ENUvelocity_yawrate`), code written for the current simulation setup will fail on the real hardware.

## Proposed Architecture: The "API Mimic" Strategy
To ensure a 1-to-1 code transfer from simulation to physical drones without using DJI Assistant 2 (which only supports single-drone HITL), the architecture must be restructured:

1.  **Hardware-Agnostic Swarm Logic:** The `ros_swarm_adapter_node` must be rewritten to broadcast and subscribe *only* to standard DJI ROS SDK topics. It should not know Gazebo or Hector exists.
2.  **Physics Layer (Simulation Only):** Retain Hector Quadrotor to handle Gazebo physics and generic flight stability in the simulation. Strip out broken or conflicting DJI Gazebo plugins from the URDF.
3.  **Bridge Node (Simulation Only):** Implement a dedicated translator node that subscribes to the DJI-formatted topics from the swarm logic and converts them into the `geometry_msgs/Twist` format that Hector requires to move the simulated model.

## Next Steps for Development
1.  Remove the DJI ROS Control plugin from the simulation URDF to stop the controller conflicts.
2.  Build the Bridge Node to map DJI SDK velocity/yaw rate commands to Hector's `/command/twist`.
3.  Refactor `ros_swarm_adapter_node` to output standard DJI SDK topics.
