#!/bin/bash

basedir=$(pwd)

# install strongswan
yum install http://ftp.nluug.nl/pub/os/Linux/distr/fedora-epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
yum install strongswan openssl

# wget .sh 
cd /etc/strongswan/ipsec.d
wget https://raw.githubusercontent.com/michael-loo/strongswan_config/for_vultr/server_key.sh
chmod a+x server_key.sh
wget https://raw.githubusercontent.com/michael-loo/strongswan_config/for_vultr/client_key.sh
chmod a+x client_key.sh

read -p 'Input the machine IP address:  ' address

./server_key.sh $address

read -p "User's name:  " username
read -p "User's email:  " email
./client_key.sh $username $email

# configure strongswan
cd /etc/strongswan
mv $basedir/ipsec.conf ipsec.conf
mv $basedir/strongswan.conf strongswan.conf

# configure account and pwd
read -p "Account name:  " name
read -p "Pwd:  " pwd
sed -i '' "s/name/$name/g" $basedir/ipsec.secrets
sed -i '' "s/pwd/$pwd/g" $basedir/ipsec.secrets
mv $basedir/ipsec.secrets ipsec.secrets

# open ipv4
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# configure firewall
firewall-cmd --permanent --add-service="ipsec"
firewall-cmd --permanent --add-port=4500/udp
firewall-cmd --permanent --add-masquerade
firewall-cmd --reload

# start strongswan
systemctl start strongswan
systemctl enable strongswan
