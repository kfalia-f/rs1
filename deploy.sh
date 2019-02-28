#!/bin/bash

dhclient
git clone https://github.com/unstableperson/rs1.git
tar -xf /home/kfalia-f/rs1/web.tar

rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum install nginx
systemctl start nginx
systemctl enable nginx

cp /home/kfalia-f/nginx.conf /etc/nginx/
cp /home/kfalia-f/default.conf /etc/nginx/conf.d/
cp /home/kfalia-f/animate-custom.css /usr/share/nginx/html/
cp /home/kfalia-f/index.html /usr/share/nginx/html/
cp /home/kfalia-f/style.css /usr/share/nginx/html/
cp /home/kfalia-f/ifcfg-enp0s3 /etc/sysconfig/network-scripts/

rm -rf rs1
rm -rf nginx.conf animate-custom.css index.html style.css ifcfg-enp0s3
reboot
