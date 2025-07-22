FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu24.04
# Downloads to user config dir
ENV DEBIAN_FRONTEND noninteractive
#RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt update
RUN TZ=Etc/UTC apt install -y tzdata
RUN apt install --no-install-recommends -y gcc python3-pip git zip unzip curl htop libgl1-mesa-glx libglib2.0-0 libpython3-dev gnupg wget aria2 p7zip-full nano && apt clean
RUN pip3 install --upgrade pip wheel && mkdir -p /data
ENV FD_MODEL_CACHE /data
RUN  pip3 install --no-cache-dir paddlepaddle-gpu==3.1.0 -i https://www.paddlepaddle.org.cn/packages/stable/cu129/
RUN  pip3 install --no-cache-dir fastdeploy-gpu -i https://www.paddlepaddle.org.cn/packages/stable/fastdeploy-gpu-86_89/ --extra-index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
EXPOSE 8180-8182
VOLUME [ "/data" ]
ENTRYPOINT [ "python", "-m" ,"fastdeploy.entrypoints.openai.api_server" ,"--port", "8180", "--metrics-port","8181","--engine-worker-queue-port" ,"8182" ]
