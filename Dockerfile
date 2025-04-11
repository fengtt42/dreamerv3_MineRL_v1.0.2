# docker build -f Dockerfile -t dreamer:v1 .
# docker run -it --rm -v ~/logdir:/root/logdir -v ~/dreamerv3_MineRL_v1.0.2:/app dreamer:v1  /bin/bash
#   python dreamerv3/main.py --logdir ~/logdir/{timestamp} --configs minecraft debug --task minecraft_diamond

# export CUDA_VISIBLE_DEVICES=0
# xvfb-run python dreamerv3/main.py --logdir logdir/{timestamp} --configs minecraft debug --task minecraft_diamond

FROM ghcr.io/nvidia/driver:1ca43390-535.230.02-ubuntu22.04

# System
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/San_Francisco
RUN apt-get update && apt-get install -y \
  ffmpeg git vim curl software-properties-common grep \
  libglew-dev x11-xserver-utils xvfb wget \
  && apt-get clean

# Python (DMLab needs <=3.11)
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_ROOT_USER_ACTION=ignore
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3.11-dev python3.11-venv && apt-get clean
RUN python3.11 -m venv /venv --upgrade-deps
ENV PATH="/venv/bin:$PATH"
RUN pip install -U pip setuptools

# Envs
ENV USE_BAZEL_VERSION=8.0.0
RUN wget -O - https://gist.githubusercontent.com/danijar/ca6ab917188d2e081a8253b3ca5c36d3/raw/install-dmlab.sh | sh
RUN pip install ale_py==0.9.0 autorom[accept-rom-license]==0.6.1
RUN pip install procgen_mirror
RUN pip install crafter
RUN pip install dm_control
RUN pip install memory_maze
ENV MUJOCO_GL=egl
RUN apt-get update && apt-get install -y openjdk-8-jdk && apt-get clean
# RUN pip install https://github.com/danijar/minerl/archive/refs/tags/v1.0.tar.gz
RUN pip install git+https://github.com/minerllabs/minerl
# COPY minerl-1.0.2-cp311-cp311-linux_x86_64.whl /tmp/
# RUN pip install /tmp/minerl-1.0.2-cp311-cp311-linux_x86_64.whl
RUN chown -R 1000:root /venv/lib/python3.11/site-packages/minerl

# Requirements
# RUN pip install jax[cuda]==0.5.0
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
RUN pip install numpy==1.23.5

# Source
RUN mkdir /app
WORKDIR /app
COPY . .
RUN chown -R 1000:root .

ENTRYPOINT ["sh", "entrypoint.sh"]
