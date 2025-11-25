FROM pytorch/pytorch:2.9.1-cuda12.8-cudnn9-devel
# Downloads to user config dir
ADD https://ultralytics.com/assets/Arial.ttf https://ultralytics.com/assets/Arial.Unicode.ttf /root/.config/Ultralytics/
ENV DEBIAN_FRONTEND noninteractive
#RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt update
RUN TZ=Etc/UTC apt install -y tzdata
RUN apt install --no-install-recommends -y gcc git zip unzip curl htop libgl1-mesa-glx libglib2.0-0 libpython3-dev gnupg wget aria2 p7zip-full nano
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
RUN python3 -m pip install --upgrade pip wheel

    # tensorflow tensorflowjs \
# Set environment variables
ENV OMP_NUM_THREADS=12

# Cleanup
ENV DEBIAN_FRONTEND teletype
RUN pip3 install --no-cache-dir jupyterlab ipywidgets jupyterlab-language-pack-zh-CN ipympl \
jupyterlab-drawio lckr-jupyterlab-variableinspector  "python-lsp-server[all]" && jupyter lab --generate-config &&\
echo "c.ServerApp.terminado_settings = {'shell_command' : ['/bin/bash']}">> /root/.jupyter/jupyter_lab_config.py
RUN  echo "c.ServerApp.root_dir = '/usr/src'">>/root/.jupyter/jupyter_lab_config.py && mkdir -p /usr/src
RUN  pip install  --no-cache-dir streamlit transformers jupyterlab_markup  
RUN pip install --extra-index-url https://pypi.anaconda.org/rapidsai-wheels-nightly/simple --pre jupyterlab_nvdashboard
RUN pip install --no-cache-dir git+https://github.com/VIRobotics/yiku-seg 
RUN pip install --no-cache-dir onnxruntime_gpu  
RUN pip install  --no-cache-dir albumentations comet gsutil notebook \
    coremltools onnx onnx-simplifier ultralytics "openvino>=2024.0.0" 
EXPOSE 8888
CMD jupyter lab --ip='*' --NotebookApp.token='' --NotebookApp.password='' --no-browser  --allow-root
