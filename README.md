# Docker Build and Run Container

Build tested on Ubuntu22.04 with CUDA Version 12.2

## How to start build

If **Docker Desktop** is installed, make sure the image is built with `sudo` privilege. If `sudo` privilege is not used, the image will not be visible to the local docker engine.

```[bash]
# Make sure you have 'nvidia-container-toolkit' installed on your host computer
sudo docker build --build-arg user=${USER} -t openpose:base .
```

- Check the Dockerfile for build details.

[Install NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Docker run container with shell attached (Linux and WSL)

```[bash]
sudo docker run -it --gpus all splat:base
```

- May need to look at OpenPose documentation to run instructions without GUI.

## How to start GUI compatible container with built image on Linux

The following instruction will allow execution of OpenPose commands with GUI.

### X Server Forwarding Prerequisite

Install [x11docker](https://github.com/mviereck/x11docker)

```[bash]
curl -fsSL https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker | sudo bash -s -- --update
```

### Run the container

```[bash]
sudo x11docker -i --sudouser --gpu --runtime=nvidia --xwayland openpose:base
```

### Sudo Privileges (Important)

Conda is only available with root user. Set user to `root` when attached to a running container.

```[bash]
# Password is always x11docker
username@9ceb007da3a5:~$ su
Password: x11docker
```
