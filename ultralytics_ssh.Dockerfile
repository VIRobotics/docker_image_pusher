FROM pytorch/pytorch:2.13.0-cuda13.0-cudnn9-runtime
# Downloads to user config dir
ADD https://ultralytics.com/assets/Arial.ttf https://ultralytics.com/assets/Arial.Unicode.ttf /root/.config/Ultralytics/
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN TZ=Etc/UTC apt-get install -y tzdata
RUN apt-get install --no-install-recommends -y openssh-server gcc git zip unzip curl htop libgl1 libglx-mesa0 libglib2.0-0 libpython3-dev gnupg wget

# Create working directory
WORKDIR /workspace

# Create default venv with access to system site-packages (torch, torchvision, etc.)
# using the uv preinstalled in the base image
RUN uv venv --seed --system-site-packages /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set environment variables
ENV OMP_NUM_THREADS=12

# Install ultralytics
RUN uv pip install --no-cache-dir ultralytics

# sshd 配置：只允许公钥登录，允许 root 以公钥方式登录
RUN mkdir -p /run/sshd /root/.ssh && chmod 700 /root/.ssh \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

# 容器启动时注入挂载的 SSH 公钥，再启动 sshd
COPY ssh-entrypoint.sh /usr/local/bin/ssh-entrypoint.sh
RUN chmod +x /usr/local/bin/ssh-entrypoint.sh

# Cleanup
ENV DEBIAN_FRONTEND=teletype

EXPOSE 22
ENTRYPOINT ["ssh-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
