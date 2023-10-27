FROM debian:latest

RUN apt update && apt upgrade -y; \
    apt install git vim dos2unix curl wget iproute2 iputils-ping gnupg software-properties-common netcat-traditional lsof procps iptables -y; \
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
        tee /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/hashicorp.list; \
    apt update && apt install packer terraform -y; 

COPY build-env/bashrc /root/.bashrc
