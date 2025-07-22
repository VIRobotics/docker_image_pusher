FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu24.04
# Downloads to user config dir
RUN python3 -m pip install --upgrade pip wheel && mkdir -p /data
ENV FD_MODEL_CACHE=/data
RUN python -m pip install --no-cache-dir paddlepaddle-gpu==3.1.0 -i https://www.paddlepaddle.org.cn/packages/stable/cu129/
RUN python -m pip install --no-cache-dir fastdeploy-gpu -i https://www.paddlepaddle.org.cn/packages/stable/fastdeploy-gpu-86_89/ --extra-index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
EXPOSE 8180-8182
VOLUME [ "/data" ]
ENTRYPOINT [ "python", "-m" ,"fastdeploy.entrypoints.openai.api_server" ,"--port", "8180", "--metrics-port","8181","--engine-worker-queue-port" ,"8182" ]
