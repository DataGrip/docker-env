create database guest;
grant all on *.* to 'guest'@'%' identified by 'guest' with grant option;