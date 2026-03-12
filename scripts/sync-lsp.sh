#!/usr/bin/env bash
set -e
set sudo

if ! docker ps | grep -q matrice_dev; then
    echo "Error: matrice_dev container is not running."
    exit 1
fi

echo "Generating compile_commands.json"
docker exec -it matrice_dev bash -c "source /opt/ros/noetic/setup.bash && cd /workspace && catkin_make -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

echo "Syncing ROS headers to host"
mkdir -p ~/.local/share/ros/noetic
docker cp matrice_dev:/opt/ros/noetic/include ~/.local/share/ros/noetic/

echo "Extracting build artifacts"
docker cp matrice_dev:/workspace/build/compile_commands.json ./workspace/src/flie_swarm_core/
docker cp matrice_dev:/workspace/devel ./workspace/ 

echo "Patching absolute paths for host resolution..."

HOST_REPO_PATH=$(realpath ../flie_swarm_core)
HOST_WORKSPACE_PATH=$(realpath ./workspace)
HOST_ROS_PATH="$HOME/.local/share/ros/noetic"

# Move execution context to the standalone repo
cd ../flie_swarm_core

# Update system headers
sed -i "s|/opt/ros/noetic|$HOST_ROS_PATH|g" compile_commands.json
# Update direct repository includes to point to your standalone repo
sed -i "s|/workspace/src/flie_swarm_core|$HOST_REPO_PATH|g" compile_commands.json
# Update generated headers (like messages/services in the devel space)
sed -i "s|/workspace|$HOST_WORKSPACE_PATH|g" compile_commands.json

echo "LSP synchronization complete."
