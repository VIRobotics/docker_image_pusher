#!/bin/bash
set -e

# 注入 SSH 公钥，支持三种方式（优先级从高到低）：
# 1. 环境变量：-e SSH_PUB_KEY="ssh-rsa AAAA..."
# 2. 挂载文件：-v /host/authorized_keys:/secrets/authorized_keys:ro
# 3. 直接挂载：-v /host/id_rsa.pub:/root/.ssh/authorized_keys
if [ -n "$SSH_PUB_KEY" ]; then
    echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys
elif [ -f /secrets/authorized_keys ]; then
    cp /secrets/authorized_keys /root/.ssh/authorized_keys
fi

# 修正权限（直接挂载单文件时 chmod 可能失败，忽略错误）
if [ -f /root/.ssh/authorized_keys ]; then
    chmod 700 /root/.ssh || true
    chmod 600 /root/.ssh/authorized_keys || true
    chown root:root /root/.ssh/authorized_keys || true
fi

# 生成 host key（已存在则跳过）
ssh-keygen -A >/dev/null 2>&1 || true
mkdir -p /run/sshd

exec "$@"
