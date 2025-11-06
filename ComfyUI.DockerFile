FROM pytorch/pytorch:2.9.0-cuda13.0-cudnn9-runtime
# Downloads to user config dir
ADD https://ultralytics.com/assets/Arial.ttf https://ultralytics.com/assets/Arial.Unicode.ttf /root/.config/Ultralytics/
ENV DEBIAN_FRONTEND noninteractive
#RUN  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
RUN apt update
RUN TZ=Etc/UTC apt install -y tzdata
RUN apt install --no-install-recommends -y  git  libgl1-mesa-glx libglib2.0-0 build-essential python3-dev && apt clean
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
RUN  git clone https://github.com/comfyanonymous/ComfyUI.git
VOLUME ["/usr/src/ComfyUI/models/","/usr/src/output/"] 
WORKDIR /usr/src/ComfyUI
RUN cd custom_nodes &&  git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager && git clone https://github.com/kijai/ComfyUI-FluxTrainer comfyui-fluxtrainer \
 && git clone  https://github.com/kijai/ComfyUI-KJNodes && git clone https://github.com/aria1th/ComfyUI-LogicUtils && git clone https://github.com/rgthree/rgthree-comfy.git \
 && git clone https://github.com/pollockjj/ComfyUI-MultiGPU && git clone https://github.com/AlekPet/ComfyUI_Custom_Nodes_AlekPet
RUN  pip install --no-cache-dir -r custom_nodes/comfyui-manager/requirements.txt
RUN  pip install --no-cache-dir -r custom_nodes/comfyui-fluxtrainer/requirements.txt
RUN  pip install --no-cache-dir -r custom_nodes/ComfyUI-KJNodes/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt 
RUN pip install --no-cache-dir piexif dghs-imgutils[gpu] pycryptodome
EXPOSE 8888
CMD python main.py  --listen 0.0.0.0 --port 8888 
