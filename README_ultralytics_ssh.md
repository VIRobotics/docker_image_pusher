# pytorch + CUDA runtime + ultralytics + SSH 镜像

基于 `pytorch/pytorch:2.13.0-cuda13.0-cudnn9-runtime` 构建，预装 ultralytics 和 openssh-server，
容器启动时注入 SSH 公钥，仅允许公钥登录。

## 构建并推送(华为云)

通过 GitHub Action 手动触发：

1. 确认仓库 Secrets 已配置(与项目其他 workflow 共用)：
   - `HWC_USER` 华为云 SWR 登录用户名
   - `HWC_PWD` 华为云 SWR 登录密码
   - `HWC_REG` 华为云 SWR 仓库地址，例如 `swr.cn-north-4.myhuaweicloud.com`
2. 进入 Actions -> `build_ultralytics_ssh` -> Run workflow
3. 构建完成后镜像地址为：

```
$HWC_REG/hetong/pytorch-ultralytics-ssh:2.13.0-cu130
```

也可本地构建：

```bash
docker build -t pytorch-ultralytics-ssh:2.13.0-cu130 -f ultralytics_ssh.Dockerfile .
```

## 运行容器

拉取镜像：

```bash
docker pull swr.cn-north-4.myhuaweicloud.com/hetong/pytorch-ultralytics-ssh:2.13.0-cu130
```

注入 SSH 公钥支持三种方式，任选其一：

### 方式1：挂载公钥文件(推荐)

```bash
docker run -d --name yolo --gpus all -p 2222:22 \
  -v ~/.ssh/id_rsa.pub:/secrets/authorized_keys:ro \
  swr.cn-north-4.myhuaweicloud.com/hetong/pytorch-ultralytics-ssh:2.13.0-cu130
```

### 方式2：环境变量传入公钥

```bash
docker run -d --name yolo --gpus all -p 2222:22 \
  -e SSH_PUB_KEY="$(cat ~/.ssh/id_rsa.pub)" \
  swr.cn-north-4.myhuaweicloud.com/hetong/pytorch-ultralytics-ssh:2.13.0-cu130
```

### 方式3：直接挂载到 authorized_keys

```bash
docker run -d --name yolo --gpus all -p 2222:22 \
  -v ~/.ssh/id_rsa.pub:/root/.ssh/authorized_keys \
  swr.cn-north-4.myhuaweicloud.com/hetong/pytorch-ultralytics-ssh:2.13.0-cu130
```

说明：

- `--gpus all` 需要宿主机已安装 NVIDIA 驱动和 nvidia-container-toolkit，不需要 GPU 时可去掉
- `-p 2222:22` 将容器 SSH 端口映射到宿主机 2222，可按需修改
- 可追加 `-v /宿主机目录:/workspace` 挂载数据目录(容器工作目录为 `/workspace`)

## 连接容器

```bash
ssh root@<宿主机IP> -p 2222
```

验证 GPU 和 ultralytics：

```bash
python -c "import torch; print(torch.cuda.is_available())"
yolo checks
```

## 常见问题

- **连接提示 Permission denied (publickey)**：确认挂载的公钥与本地私钥配对；
  方式3 直接挂载时文件权限可能被宿主机影响，建议改用方式1或2
- **容器启动后立即退出**：查看日志 `docker logs yolo`，通常为公钥未注入，
  但 sshd 无 authorized_keys 时仍会正常启动，请优先检查端口映射
- **修改镜像版本**：编辑 `.github/workflows/build_ultralytics_ssh.yaml` 中的
  `VERSION` 环境变量，并同步修改 `ultralytics_ssh.Dockerfile` 第一行的基础镜像 tag
