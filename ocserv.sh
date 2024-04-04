#!/bin/bash

echo -e enter your email address : 
read emailAddress

echo -e enter your domain :
read domain

interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

systemctl disable firewalld
systemctl stop firewalld


yum install epel-release
yum install ufw
yum install ocserv

systemctl start ocserv
systemctl enable ufw
systemctl start ufw

ufw allow 80,443,22/tcp

yum install certbot
certbot certonly --standalone --preferred-challenges http --agree-tos --email $emailAddress -d $domain
rm /etc/ocserv/ocserv.conf

wget https://raw.githubusercontent.com/bef001/openconnect/main/ocserv.conf
sed -i "126s/your-domain/${domain}/" ./ocserv.conf
sed -i "127s/your-domain/${domain}/" ./ocserv.conf
sed -i "467s/your-domain/${domain}/" ./ocserv.conf
mv ocserv.conf /etc/ocserv/

systemctl restart ocserv

echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/60-custom.conf
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/60-custom.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/60-custom.conf
sysctl -p /etc/sysctl.d/60-custom.conf

rm /etc/ufw/before.rules
wget https://raw.githubusercontent.com/bef001/openconnect/main/before.rules
sed -i "78s/eth0/${interface}/" ./before.rules 
mv before.rules /etc/ufw/

ufw enable
systemctl restart ufw

echo -e enter a username : 
read username

ocpasswd -c /etc/ocserv/ocpasswd $username

echo "your vpn is configured successfully!!!"
