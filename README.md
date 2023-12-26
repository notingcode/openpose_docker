# Docker Build and Run Container

Build tested on Ubuntu22.04 with CUDA Version 12.2

## How to start build

If **Docker Desktop** is installed, make sure the image is built with `sudo` privilege. If `sudo` privilege is not used, the image will not be visible to the local docker engine.

```[bash]
# Make sure you have 'nvidia-container-toolkit' installed on your host computer
sudo docker build --build-arg user=${USER} -t openpose:base .
```

[Install NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## X Server Forwarding Prerequisite

### Install x11docker (Linux and Windows Subsystem for Linux)

```[bash]
curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | sudo bash -s -- --update
```

## How to start container with built image

```[bash]
sudo x11docker -i --sudouser --gpu --runtime=nvidia --xwayland openpose:base
```

### Sudo Privileges

If access is denied to certain files or directories, get sudo privileges inside container.

```[bash]
# Password is always x11docker
username@9ceb007da3a5:~$ su
Password: x11docker
```
