# Set the ARGs
ARG BASE_IMAGE=ubuntu:18.04

FROM ${BASE_IMAGE}
LABEL email="yij1126@gmial.com"
LABEL name="iron"
LABEL version="1.0"
LABEL description="personal dockerfile for nlp study"

ARG PYTHON_VER=3.7.9

ENV USER user
ENV UID 1000
ENV HOME /home/${USER}

RUN apt-get update && apt-get install -y \
    sudo \
    apt-utils \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    git \
    libffi-dev \
    liblzma-dev \
    locales \
    g++ \
    libpcre3-dev \
    tar \
    bash \
    rsync \
    gcc \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libpng-dev \
    libzmq3-dev \
    unzip \
    pkg-config \
    software-properties-common \
    graphviz \
    locales \
    vim \
    language-pack-ko \
    openjdk-8-jdk \
    git-core

# Set language
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get install -y locales language-pack-ko
ENV LANGUAGE ko_KR:en
ENV LC_ALL ko_KR.UTF-8
ENV LANG ko_KR.UTF-8
RUN locale-gen ko_KR.UTF-8 \
 && update-locale LANG=ko_KR.UTF-8 \
 && dpkg-reconfigure locales


# Setting user
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${UID} \
    ${USER}

RUN adduser ${USER} sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install Python
USER ${USER}
WORKDIR ${HOME}

ENV PYENV_ROOT ${HOME}/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN git clone https://github.com/pyenv/pyenv.git .pyenv

RUN pyenv install ${PYTHON_VER} && \
    pyenv global ${PYTHON_VER}

RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Setup pyenv 
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc

USER root
RUN chown -R ${UID} ${HOME}

RUN mkdir ${HOME}/workspace
RUN mkdir ${HOME}/workspace/notebooks

RUN mkdir ${HOME}/workspace/protobuf-3.7.1 \
 && wget https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protobuf-all-3.7.1.tar.gz \
 && tar -zxvf protobuf-all-3.7.1.tar.gz \
 && pwd \
 && ls -al \
 && cd protobuf-3.7.1 \
 && ./configure && make && make install && ldconfig \
 && rm -rf ${HOME}/workspace/protobuf-3.7.1

RUN wget https://cmake.org/files/v3.14/cmake-3.14.3-Linux-x86_64.sh \
 && mkdir /opt/cmake \
 && sh cmake-3.14.3-Linux-x86_64.sh --prefix=/opt/cmake --skip-license \
 && ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake

RUN pip install --upgrade pip
RUN pip install konlpy cmake
RUN pip install gensim soynlp soyspacing bokeh networkx selenium lxml pyldavis sentencepiece
RUN pip install transformers datasets tokenizers
RUN pip install torch==1.8.1+cpu torchvision==0.9.1+cpu torchaudio==0.8.1 -f https://download.pytorch.org/whl/torch_stable.html

WORKDIR ${HOME}/workspace/notebooks
RUN wget https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh \
 && bash mecab.sh
RUN rm -rf /notebooks/*

WORKDIR ${HOME}/workspace/notebooks
RUN git clone https://github.com/kakao/khaiii.git \
 && mkdir khaiii/build \
 && cd khaiii/build \
 && cmake .. && make all && make resource && make install && make package_python \
 && cd package_python \
 && pip install  . \
 && PATH=$PATH:/notebooks/khaiii/build/lib

WORKDIR ${HOME}/workspace/notebooks
RUN git clone http://github.com/stanfordnlp/glove \
 && cd glove && make

WORKDIR ${HOME}/workspace/notebooks
RUN git clone https://github.com/facebookresearch/fastText.git \
 && cd fastText && make \
 && pip install .

WORKDIR ${HOME}/workspace/notebooks
RUN git clone https://github.com/ratsgo/embedding.git \
 && cd embedding/models/swivel \
 && make -f fastprep.mk

WORKDIR ${HOME}/workspace
RUN git clone https://github.com/lassl/tokenizer.git \
 && cd tokenizer \
 && pip install -r requirements.txt

WORKDIR ${HOME}/workspace
RUN mv notebooks/fastText notebooks/embedding/models \
 && mv notebooks/glove notebooks/embedding/models

WORKDIR ${HOME}/workspace/notebooks
RUN apt-get install fonts-nanum* \
 && rm -rf /usr/share/fonts/truetype/dejavu \
 && fc-cache -fv \
 && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && mv phantomjs-2.1.1-linux-x86_64 /usr/local/share \
 && rm phantomjs-2.1.1-linux-x86_64.tar.bz2 \
 && ln -sf /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen

USER ${USER}
WORKDIR ${HOME}/workspace
