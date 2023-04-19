# syntax=docker/dockerfile:1.4
ARG BASE_IMAGE=ubuntu:22.04
ARG BASE_RUNTIME_IMAGE=nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

FROM ${BASE_IMAGE} AS python-env

ARG DEBIAN_FRONTEND=noninteractive
ARG PYENV_VERSION=v2.3.17
ARG PYTHON_VERSION=3.10.6

RUN <<EOF
    set -eu

    apt-get update

    apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        curl \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
        git

    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
    set -eu

    git clone https://github.com/pyenv/pyenv.git /opt/pyenv
    cd /opt/pyenv
    git checkout "${PYENV_VERSION}"

    PREFIX=/opt/python-build /opt/pyenv/plugins/python-build/install.sh
    /opt/python-build/bin/python-build -v "${PYTHON_VERSION}" /opt/python

    rm -rf /opt/python-build /opt/pyenv
EOF


FROM ${BASE_RUNTIME_IMAGE} AS runtime-env

ARG DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH=/home/user/.local/bin:/opt/python/bin:${PATH}

COPY --from=python-env /opt/python /opt/python

RUN <<EOF
    set -eu

    apt-get update
    apt-get install -y \
        git \
        tk \
        libglib2.0-0 \
        gosu
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
    set -eu

    groupadd -o -g 1000 user
    useradd -m -o -u 1000 -g user user
EOF

ARG LETS_URL=https://github.com/derrian-distro/LoRA_Easy_Training_Scripts
ARG LETS_VERSION=5f2a257a0bba8bb476ebac06008861dddd3ddb04

RUN <<EOF
    set -eu

    mkdir -p /code
    chown -R user:user /code

    gosu user git clone "${LETS_URL}" /code/LoRA_Easy_Training_Scripts
    cd /code/LoRA_Easy_Training_Scripts
    gosu user git checkout "${LETS_VERSION}"
    gosu user git submodule update --init
EOF

WORKDIR /code/LoRA_Easy_Training_Scripts
ADD ./requirements-torch.txt /code/LoRA_Easy_Training_Scripts/sd_scripts/
RUN <<EOF
    set -eu

    cd /code/LoRA_Easy_Training_Scripts/sd_scripts/
    gosu user pip3 install --no-cache-dir -r ./requirements-torch.txt
    gosu user pip3 install --no-cache-dir -r ./requirements.txt
EOF

RUN <<EOF
    set -eu

    cd /code/LoRA_Easy_Training_Scripts/sd_scripts/
    # gosu user accelerate config
    gosu user mkdir -p /home/user/.cache/huggingface/accelerate
    gosu user tee /home/user/.cache/huggingface/accelerate/default_config.yaml <<EOT
command_file: null
commands: null
compute_environment: LOCAL_MACHINE
deepspeed_config: {}
distributed_type: 'NO'
downcast_bf16: 'no'
dynamo_backend: 'NO'
fsdp_config: {}
gpu_ids: all
machine_rank: 0
main_process_ip: null
main_process_port: null
main_training_function: main
megatron_lm_config: {}
mixed_precision: fp16
num_machines: 1
num_processes: 1
rdzv_backend: static
same_network: true
tpu_name: null
tpu_zone: null
use_cpu: false
EOT

EOF

# Workaround: PIL image size limit; OSError: image file is truncated
RUN <<EOF
    set -eu

    # prepend two lines to prevent error
    gosu user tee main.py.new <<EOT
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True
EOT

    cat main.py | gosu user tee -a main.py.new

    gosu user mv main.py.new main.py
EOF

ENTRYPOINT [ "gosu", "user", "accelerate", "launch", "main.py" ]
