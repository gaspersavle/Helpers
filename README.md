# ROS Docker build failing on raspberry pi (tutorial)
## 1. Pulling the docker 
  ROS made a fucky wucky with some images on Dockerhub, so we need to pull the docker to our machine before it gets pulled in the Dockerfile
  - This will not work on it's own:

```Dockerfile
FROM <docker image of choice>

###Example################
FROM ros:noetic-ros-core 
##########################
```
  - So we pull the docker we need to use

```shell
docker pull <docker image of choice>

#Example
docker pull ros:noetic-ros-core
```
## 2. First apt command fails, update libraries
  The first apt command will fail and the terminal output will look similar to this:
```shell
pi@worker1:~/TEST/docker-files $ docker build . -t niceo:ti
[+] Building 5.1s (5/13)                                                                                                                                                                            docker:default
 => [internal] load build definition from Dockerfile                                                                                                                                                          0.1s
 => => transferring dockerfile: 478B                                                                                                                                                                          0.0s
 => [internal] load .dockerignore                                                                                                                                                                             0.2s
 => => transferring context: 2B                                                                                                                                                                               0.0s
 => [internal] load metadata for docker.io/library/ros:noetic-ros-core                                                                                                                                        1.3s
 => CACHED [ 1/10] FROM docker.io/library/ros:noetic-ros-core@sha256:71e696e9c52fdd2c59491ec41255aef1bef838699c6785bc49fd3e481f15da5d                                                                         0.0s
 => ERROR [ 2/10] RUN apt-get update && apt-get install -y     neovim     python3-pip     git                                                                                                                 3.2s
------                                                                                                                                                                                                             
 > [ 2/10] RUN apt-get update && apt-get install -y     neovim     python3-pip     git:                                                                                                                            
0.943 Get:1 http://ports.ubuntu.com/ubuntu-ports focal InRelease [265 kB]                                                                                                                                          
1.129 Get:2 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease [114 kB]                                                                                                                                  
1.178 Get:3 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease [108 kB]                                                                                                                                
1.220 Get:4 http://packages.ros.org/ros/ubuntu focal InRelease [4679 B]                                                                                                                                            
1.229 Get:5 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease [114 kB]
1.452 Err:1 http://ports.ubuntu.com/ubuntu-ports focal InRelease
1.452   At least one invalid signature was encountered.
1.701 Err:2 http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease
1.701   At least one invalid signature was encountered.
1.948 Err:3 http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease
1.948   At least one invalid signature was encountered.
2.293 Err:4 http://packages.ros.org/ros/ubuntu focal InRelease
2.294   At least one invalid signature was encountered.
2.602 Err:5 http://ports.ubuntu.com/ubuntu-ports focal-security InRelease
2.602   At least one invalid signature was encountered.
2.619 Reading package lists...
2.678 W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal InRelease: At least one invalid signature was encountered.
2.678 E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal InRelease' is not signed.
2.678 W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease: At least one invalid signature was encountered.
2.678 E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-updates InRelease' is not signed.
2.678 W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease: At least one invalid signature was encountered.
2.678 E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-backports InRelease' is not signed.
2.678 W: GPG error: http://packages.ros.org/ros/ubuntu focal InRelease: At least one invalid signature was encountered.
2.678 E: The repository 'http://packages.ros.org/ros/ubuntu focal InRelease' is not signed.
2.678 W: GPG error: http://ports.ubuntu.com/ubuntu-ports focal-security InRelease: At least one invalid signature was encountered.
2.678 E: The repository 'http://ports.ubuntu.com/ubuntu-ports focal-security InRelease' is not signed.
------
Dockerfile:5
--------------------
   4 |     
   5 | >>> RUN apt-get update && apt-get install -y \
   6 | >>>     neovim \
   7 | >>>     python3-pip \
   8 | >>>     git
   9 |     
--------------------
ERROR: failed to solve: process "/bin/bash -c apt-get update && apt-get install -y     neovim     python3-pip     git" did not complete successfully: exit code: 100

```
This happens because of some libseccomp2 error, #TODO: write more about the error (summon the Mihael)
We need to adress this issue by installing the missing dependancy.

### 2.1 Downloading dependancy at fault
First we need to download the dependency, which can be done either:
1. Graphicaly:
  By visiting [[!https://packages.debian.org/sid/armhf/libseccomp2/download]] and downloading the version appropriate for your hardware, **for raspberries, this is the** `..._armhf.deb` **version**, then transferring it to your device (if downloaded on workstation becuse of a headless raspian install)

3. Using curl 
  By visiting the previously mentioned link and copying the link of the version you want, and then using the following curl syntax to download the file into your current working directory
```shell
curl -O <the link to your desired file>

# Example
curl -O http://ftp.de.debian.org/debian/pool/main/libs/libseccomp/libseccomp2_2.5.4-1+b3_armhf.deb
```

### Depackaging the dependency
  Run the following command to depackage the `.deb` file you downloaded:
```shell
sudo dpkg -i <the name of your downloaded dependancy file>

# Example
sudo dpkg -i libseccomp2_2.5.4-1+b3_armhf.deb
```

### 2.3 Installing the previously downloaded dependency
Run the following command to install the dependancy (you should be working in the directory where the file is located):
```shell
sudo apt install buster-backports libseccomp2
```

The missing dependancy should be installed and you can now try building the Dockerfile again
