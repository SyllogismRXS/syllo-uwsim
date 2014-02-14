#!/bin/bash

#sudo apt-get install ros-groovy-uwsim-bullet ros-groovy-uwsim-osgbullet ros-groovy-uwsim-osgocean ros-groovy-uwsim-osgworks
sudo apt-get install apt-get install ros-hydro-uwsim-bullet ros-hydro-uwsim-osgbullet ros-hydro-uwsim-osgocean ros-hydro-uwsim-osgworks


# Create and setup catkin workspace
mkdir -p ./uwsim/catkin_ws/src
pushd ./uwsim/catkin_ws/src >& /dev/null
catkin_init_workspace
popd >& /dev/null
pushd ./uwsim/catkin_ws >& /dev/null
catkin_make

# Copy rosinstall file to workspace
cp ../../rosinstall.tpl .rosinstall

rosws update

#rosdep install --from-paths src --ignore-src --rosdistro groovy -y
rosdep install --from-paths src --ignore-src --rosdistro hydro -y
catkin_make install

popd >& /dev/null
