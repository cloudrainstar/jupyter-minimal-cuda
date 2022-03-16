#!/bin/bash

CUDA_VERSION="11.3.1"
MINIMAL_TAG="2022-03-14"

# Get cuda container git
git clone https://gitlab.com/nvidia/container-images/cuda.git

# sed files
sed -i "s/ubuntu:20.04/temp\/jupyter:$MINIMAL_TAG/g" cuda/dist/$CUDA_VERSION/ubuntu2004/base/Dockerfile
sed -i 's/${TARGETARCH}/amd64/g' cuda/dist/$CUDA_VERSION/ubuntu2004/base/Dockerfile
sed -i 's/${TARGETARCH}/amd64/g' cuda/dist/$CUDA_VERSION/ubuntu2004/runtime/Dockerfile
sed -i 's/${TARGETARCH}/amd64/g' cuda/dist/$CUDA_VERSION/ubuntu2004/devel/Dockerfile
sed -i 's/${TARGETARCH}/amd64/g' cuda/dist/$CUDA_VERSION/ubuntu2004/devel/cudnn8/Dockerfile

# Build base
docker build \
  --build-arg MINIMAL_TAG=$MINIMAL_TAG \
  -f Dockerfile.start \
  -t temp/jupyter:$MINIMAL_TAG \
  .

# Build cuda-base
docker build \
  -f cuda/dist/$CUDA_VERSION/ubuntu2004/base/Dockerfile \
  -t temp/jupyter:$CUDA_VERSION-base-ubuntu20.04 \
  cuda

# Build cuda-runtime
docker build \
  --build-arg IMAGE_NAME=temp/jupyter \
  -f cuda/dist/$CUDA_VERSION/ubuntu2004/runtime/Dockerfile \
  -t temp/jupyter:$CUDA_VERSION-runtime-ubuntu20.04 \
  cuda

# Build cuda-devel
docker build --build-arg TARGETARCH=amd64 \
  --build-arg IMAGE_NAME=temp/jupyter \
  -f cuda/dist/$CUDA_VERSION/ubuntu2004/devel/Dockerfile \
  -t temp/jupyter:$CUDA_VERSION-devel-ubuntu20.04 \
  cuda

# Build cuda-devel-cudnn8
docker build --build-arg TARGETARCH=amd64 \
  --build-arg IMAGE_NAME=temp/jupyter \
  -f cuda/dist/$CUDA_VERSION/ubuntu2004/devel/cudnn8/Dockerfile \
  -t temp/jupyter:$CUDA_VERSION-devel-cudnn8-ubuntu20.04 \
  cuda

# Finalize
docker build \
  --build-arg IMAGE_NAME=temp/jupyter:$CUDA_VERSION-devel-cudnn8-ubuntu20.04 \
  -f Dockerfile.final \
  -t cloudrainstar/jupyter:$MINIMAL_TAG-cuda-$CUDA_VERSION \
  .

# cleanup
rm -rf cuda
