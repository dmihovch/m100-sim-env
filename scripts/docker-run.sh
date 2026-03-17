#!/usr/bin/env bash
xhost +local:root

sudo docker build -t m100_ros1_env .
sudo docker rm -f matrice_dev 2>/dev/null

sudo docker run -it --privileged \
  --name matrice_dev \
  --gpus all \
  --env="DISPLAY=$DISPLAY" \
  --env="QT_X11_NO_MITSHM=1" \
  --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  --volume="$PWD":"$PWD":rw \
  --volume="$HOME/.config/nvim:/root/.config/nvim:ro" \
  --volume="$HOME/.local/share/nvim:/root/.local/share/nvim:rw" \
  --workdir="$PWD" \
  --network host \
  m100_ros1_env \
  bash
