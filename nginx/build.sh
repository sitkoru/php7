#!/bin/bash
mkdir -p /nginx
cd /nginx
apt-get source nginx=${NGINX_VERSION}-1
mkdir -p nginx-${NGINX_VERSION}/debian/modules
cd nginx-${NGINX_VERSION}/debian/modules

cd /nginx/nginx-${NGINX_VERSION}
wget https://www.openssl.org/source/openssl-${OSSL_VERSION}.tar.gz
tar -xf openssl-${OSSL_VERSION}.tar.gz

cd /nginx/nginx-${NGINX_VERSION}

sed -i "0,/CFLAGS\=\\\"\\\"/{/CFLAGS\=\\\"\\\"/ s/$/ --with-openssl=\/nginx\/nginx-${NGINX_VERSION}\/openssl-${OSSL_VERSION}/}" /nginx/nginx-${NGINX_VERSION}/debian/rules
sed -i "s/CFLAGS\=\\\"\\\"/CFLAGS\=\\\"-Wno-missing-field-initializers\\\"/" /nginx/nginx-${NGINX_VERSION}/debian/rules

dpkg-buildpackage -b
