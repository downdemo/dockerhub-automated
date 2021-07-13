FROM ubuntu:20.04

WORKDIR /shared

# update apt source
ARG UBUNTU_SOURCE="mirrors.aliyun.com"
RUN sed -i "s/archive.ubuntu.com/${UBUNTU_SOURCE}/g" /etc/apt/sources.list \
    && sed -i "s/security.ubuntu.com/${UBUNTU_SOURCE}/g" /etc/apt/sources.list \
    && apt update \
    && apt upgrade -y

# set time zone
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

# install tools
RUN apt install -y \
    sudo \
    git \
    vim \
    net-tools \
    tcpdump \
    inetutils-ping \
    tree \
    wget \
    curl \
    axel \
    cron \
    jq \
    sqlite3 \
    build-essential \
    gdb \
    cmake \
    clang-format \
    libevent-dev

# install zsh
ARG GITHUB_PROXY="https://github.com.cnpmjs.org"
RUN apt install -y zsh \
    && git clone ${GITHUB_PROXY}/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh \ 
    && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
    && git clone ${GITHUB_PROXY}/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone ${GITHUB_PROXY}/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone ${GITHUB_PROXY}/zsh-users/zsh-history-substring-search.git ~/.oh-my-zsh/custom/plugins/zsh-history-substring-search \
    && touch ~/.z \
    && sed -i 's/^plugins=.*/plugins=(git z zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/' ~/.zshrc \
    && sed -i 's/^ZSH_THEME=.*/ZSH_THEME="robbyrussell"/' ~/.zshrc \
    && chsh -s /bin/zsh
ENTRYPOINT [ "zsh" ]

# install go
ARG GO_VERSION="1.16.5"
ARG GO_INSTALLER_URL="https://studygolang.com/dl/golang/go${GO_VERSION}.linux-amd64.tar.gz"
RUN wget -c ${GO_INSTALLER_URL} -O - | tar -xz -C /usr/local
ENV PATH=$PATH:/usr/local/go/bin 
RUN go env -w GO111MODULE=on
RUN go env -w GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

# install nodejs
ARG NODE_VERSION="16.4.2"
ARG NODE_INSTALLER_URL="https://npm.taobao.org/mirrors/node/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz"
RUN wget -c ${NODE_INSTALLER_URL} -O node.tar.xz \
    && mkdir /usr/local/nodejs \
    && tar xvf node.tar.xz -C /usr/local/nodejs --strip-components 1 \
    && rm node.tar.xz
ENV PATH=$PATH:/usr/local/nodejs/bin
ARG NPM_SOURCE="https://registry.npm.taobao.org"
RUN npm config set registry ${NPM_SOURCE}
RUN npm install -g tldr

# install pip
RUN apt install -y pip
ARG PIP_SOURCE="https://mirrors.aliyun.com/pypi/simple/"
RUN mkdir ~/.pip && echo "[global]\nindex-url = ${PIP_SOURCE}" > ~/.pip/pip.conf
RUN pip install --upgrade setuptools pip && pip install --upgrade sslyze

# start sshd
# RUN apt install -y openssh-server && service ssh start

# clear package cache
RUN rm -rf /var/lib/apt/lists/*
RUN apt update
