```
sudo yum update
wget https://raw.githubusercontent.com/bef001/openconnect/main/ocserv.sh 
chmod +x ocserv.sh 
sudo ./ocserv.sh 
```
in order to add more user you can run this command bellow
```
ocpasswd -c /etc/ocserv/ocpasswd
```
