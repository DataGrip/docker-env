# mysql 5.6 over ipv6
Docker-compose for mysql 5.6 with ipv6 support

### Build
`docker-compose up -d`

### Get ipv6 address
#### Windows (MacOs)
```bash
docker-machine ip
#192.168.99.100 (Default Windows)
ssh docker@<docker-machine-ip-address>
#password: tcuser
```
After successfull login:
```
ip addr
```

Find interface that uses your docker machine ip address, e.g.: 
```
 eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 08:00:27:f4:d6:c5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.99.100/24 brd 192.168.99.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fef4:d6c5/64 scope link
       valid_lft forever preferred_lft forever
```	   
	   
Your ipv6 address: `fe80::a00:27ff:fef4:d6c5`


#### Linux:
Just use your localhost, e.g.:
```
mysql -u guest -h ::1 -P 33016 -p guest
#password=guest
```
