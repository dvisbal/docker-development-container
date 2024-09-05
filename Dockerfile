FROM ubuntu:latest AS base

ARG USER_NAME
ENV USER_NAME=${USER_NAME}

# Install Packages for dev image
RUN apt-get update && \
    apt-get install -y g++ make automake git wget lsof curl docker.io \
    docker-compose nano vim zip python3-pip openssh-server xauth xclip xsel \
    sudo x11-utils iproute2 pass pass-git-helper libgdal-dev gdal-bin \
    libproj-dev

# Packages for Media Server
# maybe split the Media Server into it's own docker image
# Not sure, but I think the dockerfile can be configured to only install packages
# for the Media Server image vs. Dev image
# Although, might just be easier to have two seperate dockerfiles, or
# even give the two images their own project folders
RUN apt-get install -y ffmpeg 

FROM base

RUN useradd -rm -d /home/${USER_NAME} -s /bin/bash -g root -G sudo -u 1000 ${USER_NAME}
RUN echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install AWS CLI
COPY awscli-exe-linux-x86_64.zip /home/${USER_NAME}
WORKDIR /home/${USER_NAME}
RUN unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install

COPY dotfiles/.bash_aliases /home/${USER_NAME}/.bash_aliases
RUN chmod 777 /home/${USER_NAME}/.bash_aliases

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}

RUN pip install awsebcli --upgrade --user

ENTRYPOINT [ "/bin/bash" ]