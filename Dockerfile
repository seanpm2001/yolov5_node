ARG BASE_IMAGE
FROM nvcr.io/nvidia/pytorch:20.11-py3

RUN curl -sSL https://gist.githubusercontent.com/b01/0a16b6645ab7921b0910603dfb85e4fb/raw/5186ea07a06eac28937fd914a9c8f9ce077a978e/download-vs-code-server.sh | sed "s/server-linux-x64/server-linux-$(dpkg --print-architecture)/" | sed "s/amd64/x64/" | sh

ENV VSCODE_SERVER=/root/.vscode-server/bin/*/server.sh

RUN $VSCODE_SERVER --install-extension ms-python.vscode-pylance \
    $VSCODE_SERVER --install-extension ms-python.python \
    $VSCODE_SERVER --install-extension himanoa.python-autopep8 \
    $VSCODE_SERVER --install-extension esbenp.prettier-vscode \
    $VSCODE_SERVER --install-extension littlefoxteam.vscode-python-test-adapter

RUN apt update && apt install -y zip htop screen libgl1-mesa-glx && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install seaborn thop

WORKDIR /

# install mish-cuda to use mish activation
# https://github.com/thomasbrandon/mish-cuda
# https://github.com/JunnYu/mish-cuda
RUN git clone https://github.com/JunnYu/mish-cuda && cd mish-cuda && python setup.py build install

# install pytorch_wavelets to use dwt down-sampling module
# https://github.com/fbcotter/pytorch_wavelets
RUN git clone https://github.com/fbcotter/pytorch_wavelets && cd pytorch_wavelets && pip install .

# fetch yolor code
RUN git clone https://github.com/WongKinYiu/yolor.git

RUN python3 -m pip install "learning_loop_node==0.3.2" autopep8 debugpy gunicorn pyyaml

WORKDIR /app

RUN ln -s /data /app/data

EXPOSE 80

CMD ./app/start.sh
