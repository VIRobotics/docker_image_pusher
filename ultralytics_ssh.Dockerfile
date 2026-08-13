FROM pytorch/pytorch:2.13.0-cuda13.0-cudnn9-runtime

ENV DEBIAN_FRONTEND=noninteractive

# Ultralytics 绘图字体，避免运行时告警
ADD https://ultralytics.com/assets/Arial.ttf https://ultralytics.com/assets/Arial.Unicode.ttf /root/.config/Ultralytics/

RUN apt-get update && apt-get install --no-install-recommends -y \
    openssh-server git curl wget zip unzip htop libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 安装 ultralytics（runtime 镜像自带 conda 环境的 pip）
RUN pip install --no-cache-dir ultralytics

# sshd 配置：只允许公钥登录，允许 root 以公钥方式登录
RUN mkdir -p /run/sshd /root/.ssh && chmod 700 /root/.ssh \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

COPY ssh-entrypoint.sh /usr/local/bin/ssh-entrypoint.sh
RUN chmod +x /usr/local/bin/ssh-entrypoint.sh

WORKDIR /workspace

EXPOSE 22
ENTRYPOINT ["ssh-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
