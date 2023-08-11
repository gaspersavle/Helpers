#!/bin/bash

source "/opt/ros/noetic/setup.bash"
export ROS_MASTER_URI=http://10.20.0.1:11311   


# now cd to the right directory
if [ -d "/ros_ws/src" ]; then
    export PATH=$PATH: "/ros_ws/src"
    cd "/ros_ws/src"
fi

exec "$@"
