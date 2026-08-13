FROM pytorch/pytorch:2.13.0-cuda13.0-cudnn9-devel
# Downloads to user config dir
ADD https://ultralytics.com/assets/Arial.ttf https://ultralytics.com/assets/Arial.Unicode.ttf /root/.config/Ultralytics/
ENV DEBIAN_FRONTEND noninteractive
#RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt update
RUN TZ=Etc/UTC apt install -y tzdata
RUN apt install --no-install-recommends -y gcc git zip unzip curl htop libgl1 libglx-mesa0 libglib2.0-0 libpython3-dev gnupg wget aria2 p7zip-full nano
# RUN alias python=python3

# Security updates
# https://security.snyk.io/vuln/SNYK-UBUNTU1804-OPENSSL-3314796
#RUN apt upgrade --no-install-recommends -y openssl

# Create working directory
WORKDIR /usr/src/

# Copy contents
# COPY . /usr/src/app  (issues as not a .git directory)
#RUN git clone https://github.com/ultralytics/yolov5 /usr/src/yolov5 

# Install pip packages
#COPY requirements.txt .
# Install uv via standalone installer (system python is PEP 668 externally-managed on Ubuntu 24.04)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# Create default venv with access to system site-packages (torch, torchvision, etc.)
RUN /root/.local/bin/uv venv --seed --system-site-packages /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:/root/.local/bin:$PATH"

    # tensorflow tensorflowjs \
# Set environment variables
ENV OMP_NUM_THREADS=12

# Cleanup
ENV DEBIAN_FRONTEND teletype
RUN uv pip install --no-cache-dir jupyterlab ipywidgets jupyterlab-language-pack-zh-CN ipympl \
jupyterlab-drawio lckr-jupyterlab-variableinspector  nbconvert "python-lsp-server[all]" && jupyter lab --generate-config &&\
echo "c.ServerApp.terminado_settings = {'shell_command' : ['/bin/bash']}">> /root/.jupyter/jupyter_lab_config.py
RUN  echo "c.ServerApp.root_dir = '/usr/src'">>/root/.jupyter/jupyter_lab_config.py && mkdir -p /usr/src
RUN uv pip install --no-cache-dir streamlit transformers jupyterlab_markup  tensorboard 
RUN pip install --extra-index-url https://pypi.anaconda.org/rapidsai-wheels-nightly/simple --pre jupyterlab_nvdashboard
RUN pip install --no-cache-dir git+https://github.com/VIRobotics/yiku-seg 
RUN pip install --no-cache-dir onnxruntime_gpu  
RUN pip install  --no-cache-dir albumentations comet gsutil notebook \
    coremltools onnx onnx-simplifier ultralytics "openvino>=2024.0.0"  
EXPOSE 8888
CMD jupyter lab --ip='*' --IdentityProvider.token='' --ServerApp.password='' --no-browser  --allow-root
