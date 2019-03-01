#!/bin/bash

dhclient
git clone https://github.com/unstableperson/rs1.git
tar -xf /home/kfalia-f/rs1/web.tar

rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum install nginx
systemctl start nginx
systemctl enable nginx

cp /root/nginx.conf /etc/nginx/
cp /root/default.conf /etc/nginx/conf.d/
cp /root/animate-custom.css /usr/share/nginx/html/
cp /root/index.html /usr/share/nginx/html/
cp /root/index1.html /usr/share/nginx/html/
cp /root/index2.html /usr/share/nginx/html/
cp /root/index3.html /usr/share/nginx/html/
cp /root/style.css /usr/share/nginx/html/
cp /root/ifcfg-enp0s3 /etc/sysconfig/network-scripts/

sh /root/iptables.sh

rm -rf rs1
rm -rf nginx.conf animate-custom.css index.html index1.html index2.html index3.html style.css ifcfg-enp0s3
reboot
