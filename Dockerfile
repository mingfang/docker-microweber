FROM ubuntu:16.04 as base

ENV DEBIAN_FRONTEND=noninteractive TERM=xterm
RUN echo "export > /etc/envvars" >> /root/.bashrc && \
    echo "export PS1='\[\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" | tee -a /root/.bashrc /etc/skel/.bashrc && \
    echo "alias tcurrent='tail /var/log/*/current -f'" | tee -a /root/.bashrc /etc/skel/.bashrc

RUN apt-get update
RUN apt-get install -y locales && locale-gen en_US.UTF-8 && dpkg-reconfigure locales
ENV LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Runit
RUN apt-get install -y --no-install-recommends runit
CMD bash -c 'export > /etc/envvars && /usr/sbin/runsvdir-start'

# Utilities
RUN apt-get install -y --no-install-recommends vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc iproute python ssh rsync gettext-base

RUN apt-get install -y nginx

# HHVM
RUN apt-get install -y software-properties-common apt-transport-https && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xB4112585D386EB94 && \
    add-apt-repository https://dl.hhvm.com/ubuntu && \
    apt-get update && \
    apt-get install -y hhvm

RUN mkdir -p microweber
RUN cd microweber && \
    wget https://github.com/microweber/microweber/releases/download/1.0.7-fix1/microweber-1.0.7.zip && \
    unzip microweber*.zip && \
    rm microweber*.zip
RUN cd microweber && \
    php artisan microweber:install admin@site.com admin pass 127.0.0.1 site_db root secret sqlite -p site_

RUN rm /etc/nginx/sites-enabled/default
COPY microweber.conf /etc/nginx/sites-enabled/microweber.conf

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

