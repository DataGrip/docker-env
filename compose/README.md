## Install Docker
https://docs.docker.com/engine/installation/

https://docs.docker.com/compose/install/ – Docker Compose

Required versions:
Docker 1.12
Compose 1.8

## Install Docker for Windows
For Windows under version 10 use Docker Toolbox https://docs.docker.com/toolbox/overview/
* Install the latest Oracle Virtual box https://www.virtualbox.org/ using default location
* Install all Docker Toolbox components without changing default locations
* Clone this repo
* See below instructions for docker-compose to start/stop containers

## Start
Execute `docker-compose up -d --no-recreate <service>` for setting up some particular services
e.g.
`docker-compose up -d --no-recreate pg94 mysql51`
or just
`docker-compose up -d --no-recreate`.

## Remove
`docker-compose stop <service> && docker-compose rm --force <service>`
e.g.
`docker-compose stop pg94 && docker-compose rm --force pg94`

## Update images
`docker-compose pull <service>`
e.g.
`docker-compose pull mysql51 mysql55 mysql56`

## Statefull services
For saving a state of a service you can use the stop command:
`docker-compose stop <service>`
e.g.
`docker-compose stop pg94`

## Useful links
1. https://docs.docker.com/compose/
1. https://github.com/docker/compose
1. https://github.com/sdurrheimer/docker-compose-zsh-completion
1. http://stackoverflow.com/a/32023104/1553664
1. https://github.com/chadoe/docker-cleanup-volumes – remove unused images
1. https://github.com/brogersyh/Dockerfiles-for-windows

# Additional recipes

## PostgreSQL 9.3 with SSH with key auth
```
read MY_SSH_KEY < ~/.ssh/id_rsa.pub
docker run -ti -d -p 22223:22 -p 54032:5432 --name pg93ssh -e "PG_USERNAME=guest" -e "PG_PASSWORD=guest" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql93
```

## MySQL and PostgreSQL via SSH with password auth
```
git clone https://github.com/scotch-io/scotch-box.git
cd scotch-box
vagrant up
```

```
192.168.33.10:22 vagrant/vagrant – proxy server
localhost:3306/scotchbox root/root – MySQL
localhost:5432/scotchbox root/root – PostgreSQL

```

## Dumps
Sample databases dumps mostly based on Sakila db sample