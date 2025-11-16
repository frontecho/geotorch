FROM pytorch/pytorch:2.7.1-cuda11.8-cudnn9-devel
WORKDIR /root

COPY ./image_components /tmp/image_components/

RUN apt-get update \
    && apt-get install -y openssh-client \
    && apt-get install -y openssh-server \
    && mkdir -p /run/sshd \
    && /usr/bin/ssh-keygen -A \
    && cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new \
    && echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new \
    && cat /etc/ssh/sshd_config | grep -v  PermitRootLogin > /etc/ssh/sshd_config.new \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.new \
    && mv -f /etc/ssh/ssh_config.new /etc/ssh/ssh_config \
    && mv -f /etc/ssh/sshd_config.new /etc/ssh/sshd_config > /dev/null 2>&1

RUN apt-get install -y fonts-noto-cjk \
    && pip install -r /tmp/image_components/requirements.txt \
    && mkdir /root/.jupyter \
    && cp -rf /tmp/image_components/jupyter_configure/* /root/.jupyter

RUN cat /tmp/image_components/start.sh > /start.sh \
    && chmod +x /start.sh \
    && rm -rf /tmp/image_components \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip cache purge

EXPOSE 8888

CMD ["/start.sh"]
