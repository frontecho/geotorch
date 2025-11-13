#!/bin/bash
exec > /dev/null 2>&1

if [ -n "${SSH_PUBKEY}" ]; then
    mkdir -p /root/.ssh
    if [ ! -f "/root/.ssh/authorized_keys" ]; then
        touch /root/.ssh/authorized_keys
    fi
    if ! grep -q "${SSH_PUBKEY}" /root/.ssh/authorized_keys 2>/dev/null; then
        echo -e "${SSH_PUBKEY}" >> /root/.ssh/authorized_keys
    fi
fi

if [ -n "${JUPYTER_PORT}" ]; then
    echo -e "{\"IdentityProvider\": {\"token\": \"${JUPYTER_PORT}\"}}" > /root/.jupyter/jupyter_server_config.json
else
    jupyter lab --allow-root --notebook-dir=/root
fi

if [ "$ZJU_MIRRORS" = "1" ]; then
    echo "10.203.1.201 mirrors.zju.edu.cn" >> /etc/hosts

    cat > /etc/apt/sources.list << 'EOF'
deb https://mirrors.zju.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.zju.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.zju.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.zju.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF

    cat > /root/.condarc << 'EOF'
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.zju.edu.cn/anaconda/pkgs/main
  - https://mirrors.zju.edu.cn/anaconda/pkgs/r
  - https://mirrors.zju.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.zju.edu.cn/anaconda/cloud
  msys2: https://mirrors.zju.edu.cn/anaconda/cloud
  bioconda: https://mirrors.zju.edu.cn/anaconda/cloud
  menpo: https://mirrors.zju.edu.cn/anaconda/cloud
  pytorch: https://mirrors.zju.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.zju.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.zju.edu.cn/anaconda/cloud
  nvidia: https://mirrors.zju.edu.cn/anaconda-r
EOF

    pip config set global.index-url https://mirrors.zju.edu.cn/pypi/web/simple
    
    apt-get update
    conda clean -i
    pip cache purge
fi
