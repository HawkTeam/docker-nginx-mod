#!/bin/bash

# make utf-8 enabled by default
apt-get install -y locales \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

DEBIAN_FRONTEND=noninteractive \
apt-get install -y build-essential \
    g++ flex bison \
    curl doxygen \
    libyajl-dev libgeoip-dev\
    libtool dh-autoreconf \
    libcurl4-gnutls-dev \
    libxml2 libpcre++-dev \
    libxml2-dev libpcre3-dev \
    git wget
    
mkdir -pv /tmp/build-nginx/
### Install library require for building nginx ###
#Install PCRE library
cd /tmp/build-nginx/
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.41.tar.gz && \
    tar -zxf pcre-8.41.tar.gz && rm pcre-8.41.tar.gz && \
    cd /tmp/build-nginx/pcre-8.41 && ./configure && make && make install

#Install zlib library
cd /tmp/build-nginx/
wget http://zlib.net/zlib-1.2.11.tar.gz && \
    tar -zxf zlib-1.2.11.tar.gz && rm zlib-1.2.11.tar.gz && \
    cd /tmp/build-nginx/zlib-1.2.11 && ./configure && make && make install

#Install OpenSSL library
cd /tmp/build-nginx/
wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz && \
    tar -zxf openssl-1.0.2l.tar.gz && rm openssl-1.0.2l.tar.gz && \
    cd /tmp/build-nginx/openssl-1.0.2l && ./config --prefix=/usr && make && make install

#Install lib modsecurity

cd /tmp/build-nginx/
git clone https://github.com/SpiderLabs/ModSecurity
cd /tmp/build-nginx/ModSecurity/
git checkout -b v3/master origin/v3/master
sh build.sh && git submodule init && git submodule update 
./configure
make && make install

#Get Mod security for Nginx V3

cd /tmp/build-nginx/ && \
    git clone https://github.com/SpiderLabs/ModSecurity-nginx


##### Download nginx stable version ######
# NGINX_STABLE_VERSION=1.12.2
NGINX_STABLE_VERSION=1.12.2
cd /tmp/build-nginx/
wget -q http://nginx.org/download/nginx-${NGINX_STABLE_VERSION}.tar.gz \
    -O nginx-${NGINX_STABLE_VERSION}.tar.gz \
    && tar -xzvf nginx-${NGINX_STABLE_VERSION}.tar.gz \
    && rm nginx-${NGINX_STABLE_VERSION}.tar.gz

cd /tmp/build-nginx/nginx-${NGINX_STABLE_VERSION}/

./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/wsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-stream \
    --with-mail=dynamic \
    --add-module=/tmp/build-nginx/ModSecurity-nginx

make && make install

# configure nginx
useradd -r nginx

rm -rf /etc/nginx
# tar xzf /tmp/build-nginx/nginx-config.tgz -C /etc/

mkdir -pv /var/www/html
mkdir -pv /var/cache/nginx/client_temp

# cleaning
DEBIAN_FRONTEND=noninteractive \
apt-get purge --auto-remove -y wget -q \
    gcc g++ make \
    zlib1g-dev  \
    libpcre3-dev \
    libssl-dev \
    libxslt1-dev \
    libxml2-dev \
    libgd-dev \
    libgd2-xpm-dev \
    libgeoip-dev \
    build-essential

rm -rf /tmp/* /var/tmp/*
