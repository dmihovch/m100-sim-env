#Gazebo Classic Simulator w/ ROS1 integration

##Dependencies
###Hardware
- GPU (possibly only NVIDIA)
###Software
- Linux environment
- Docker
- 

##Setup

Execute these commands on your local machine
```bash
  git clone --recursive git@github.com:dmihovch/m100-sim-env.git 
  cd m100-sim-env.git
  ./scripts/docker-run.sh
```

Once you have been dropped into the docker container, run these
```bash
  cd workspace
  catkin_make
  source devel/setup.bash
  ./src/flie_swarm_core/scripts/generate-swarm.sh <swarm_size> <formation>
  roslaunch flie_swarm_core swarm_generated.launch
```
swarm_size can be any number, I have personally tested up to 20. I put no sanitation in the script, so if you put something like -1 in that is on you! Current valid formations are "flying_v", "helix", "carousel"

##Development
The container is pulling down with the helix editor, so you can edit right from inside the container! Updates you make outside the container are not immediately reflected inside the container, but edits made inside are immediately reflected outside.
To update the commit pointer for `flie_swarm_core` in `m100-sim-env`, run `./scripts/update-core.sh`
