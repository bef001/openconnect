#!/bin/bash

echo -e enter your email address : 
read emailAddress

echo -e enter your domain :
read domain

interface=$(ip route get 8.8.8.8 | awk -- '{printf $5}')

systemctl disable firewalld
systemctl stop firewalld


# sudo yum update
sudo yum install epel-release
sudo yum install ufw
sudo yum install ocserv


sudo systemctl start ocserv
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw allow 80,443,22/tcp


sudo yum install certbot
sudo certbot certonly --standalone --preferred-challenges http --agree-tos --email $emailAddress -d $domain


sudo rm /etc/ocserv/ocserv.conf
sudo wget https://raw.githubusercontent.com/bef001/openconnect/main/ocserv.conf
sudo sed -i "126s/your-domain/${domain}/" ./ocserv.conf
sudo sed -i "127s/your-domain/${domain}/" ./ocserv.conf
sudo sed -i "467s/your-domain/${domain}/" ./ocserv.conf
sudo mv ocserv.conf /etc/ocserv/

sudo systemctl restart ocserv

sudo echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/60-custom.conf
sudo echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/60-custom.conf
sudo echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/60-custom.conf
sudo sysctl -p /etc/sysctl.d/60-custom.conf


sudo rm /etc/ufw/before.rules
sudo wget https://raw.githubusercontent.com/bef001/openconnect/main/before.rules
sudo sed -i "78s/eth0/${interface}/" ./before.rules 
sudo mv before.rules /etc/ufw/


sudo ufw enable
sudo systemctl restart ufw

echo -e enter a username : 
read username

sudo ocpasswd -c /etc/ocserv/ocpasswd $username

echo "your vpn is configured successfully!!!"
