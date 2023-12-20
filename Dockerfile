FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# Do not check for keyboard response and answer with default choice
ENV DEBIAN_FRONTEND=noninteractive

# Set up CUDA environment variables
ENV PATH="/usr/local/cuda-11.7/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.7/lib64:${LD_LIBRARY_PATH}"
ENV CUDA_PATH="/usr/local/cuda-11.7"
ENV CUDA_HOME="/usr/local/cuda-11.7"

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
    && apt-get install -y \
    git gcc g++ locate unzip \
    software-properties-common \
    ninja-build build-essential \
    wget bzip2 tar qtbase5-dev \
    libcanberra-gtk-module libcanberra-gtk3-module \
    libatlas-base-dev libboost-all-dev libeigen3-dev \
    libprotobuf-dev libleveldb-dev libsnappy-dev \
    libhdf5-serial-dev protobuf-compiler libopencv-dev \
    libgflags-dev libgoogle-glog-dev liblmdb-dev

# Since python3.7 is no longer the default python version in Ubuntu22.04
# Add repository that holds python3.7 to Ubuntu
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y python3.7-dev python3-pip python3.7-distutils
# Link python binary to python3.7
RUN ln -s /usr/bin/python3.7 /usr/bin/python

# Build and install cmake version 3.24.4 to build and install project binary files
RUN wget https://github.com/Kitware/CMake/releases/download/v3.24.4/cmake-3.24.4.tar.gz \
    && tar -xzf cmake-3.24.4.tar.gz \
    && cd cmake-3.24.4 \
    && ./bootstrap && make && make install

# Clean-up
RUN rm -rf cmake-3.24.4 && rm cmake-3.24.4.tar.gz

# Install Ceres-solver
RUN wget http://ceres-solver.org/ceres-solver-2.1.0.tar.gz \
    && tar zxf ceres-solver-2.1.0.tar.gz \
    && mkdir ceres-bin \
    && cd ceres-bin \
    && cmake ../ceres-solver-2.1.0 -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_CUDA_ARCHITECTURES=native \
    && make -j3 \
    && make test \
    && make install

# Clean-up
RUN rm -rf ceres-solver-2.1.0 && rm -rf ceres-bin && rm ceres-solver-2.1.0.tar.gz

# Clone repository
WORKDIR /root/

RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git --recursive

WORKDIR /root/openpose

# Install pip dependencies
RUN pip3 install numpy opencv-python gdown

# Download trained model data
# CAUTION: This file can be removed or no longer shared from my Google Drive
RUN gdown --fuzzy 'https://drive.google.com/file/d/1RFcQF8XIldjt_Qxf9iXk0xF0h83tYleF/view?usp=sharing'

RUN unzip -o openpose_pretrained_models.zip

# Clean-up and get ready to build OpenPose
RUN rm -f openpose_pretrained_models.zip && mkdir -p build

WORKDIR /root/openpose/build

# Build OpenPose
RUN cmake .. -B . -DBUILD_PYTHON=ON -DBUILD_python=ON -DGPU_MODE=CUDA -DUSE_OPENCV=ON \
    -DDOWNLOAD_BODY_25_MODEL=OFF -DDOWNLOAD_BODY_COCO_MODEL=OFF -DDOWNLOAD_BODY_MPI_MODEL=OFF \
    -DDOWNLOAD_FACE_MODEL=OFF -DDOWNLOAD_HAND_MODEL=OFF \
    # After identifying CUDA version installed natively on your computer,
    # add or remove numbers from CUDA_ARCH_BIN as needed.
    # NOTE: NVIDIA GPU and CUDA must be compatible with ARCH_BIN listed.
    # Refer to this page for more information:
    # (https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/)
    -DCUDA_ARCH="Manual" -DCUDA_ARCH_BIN="60 61 70 75 80 86"

WORKDIR /root/openpose

RUN make -C "./build" -j`proc`

# Clean up
RUN pip3 cache purge
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=dialog

SHELL [ "/bin/bash", "-c" ]