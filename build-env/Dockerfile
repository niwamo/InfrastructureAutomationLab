FROM debian:latest

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt upgrade -y; \
    apt install curl wget iproute2 iputils-ping gnupg software-properties-common -y; \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/hashicorp.list; \
    apt update && apt install packer terraform -y; \
    mkdir /repo; \
    mkdir /vmware

ENV PATH="${PATH}:/vmware"
WORKDIR /repo

ENTRYPOINT ["/bin/bash"]