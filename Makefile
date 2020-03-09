#/**
# * TangoMan Dockerized Kali
# *
# * Spawn a dockerized Kali Linux host easily
# *
# * @version  0.1.0
# * @author   "Matthias Morin" <mat@tangoman.io>
# * @licence  MIT
# * @link     https://github.com/TangoMan75/dockerized-kali
# */

.PHONY: help check start cmd shell status volumes logs stop kill remove up prod dev cli build open docker-install docker-remove top stop-all kill-all clean remove-all sysinfo 

# Colors
TITLE     = \033[1;42m
CAPTION   = \033[1;44m
BOLD      = \033[1;34m
LABEL     = \033[1;32m
DANGER    = \033[31m
SUCCESS   = \033[32m
WARNING   = \033[33m
SECONDARY = \033[34m
INFO      = \033[35m
PRIMARY   = \033[36m
DEFAULT   = \033[0m
NL        = \033[0m\n

# https://hub.docker.com/u/kalilinux
# 
# |         kalilinux          |
# |----------------------------|
# | kali                       |
# | kali-bleeding-edge         |
# | kali-bleeding-experimental |
# | kali-dev                   |
# | kali-rolling               |

image?=dockerized-kali.dockerfile
container?=kali

# command to execute on container startup
command?=tail -f /dev/null

# Host network config
default_ethernet="$(shell ip token | cut -d\  -f4 | grep -E '^e' | head -n1)"
default_wifi="$(shell ip token | cut -d\  -f4 | grep -E '^w' | head -n1)"

adapter?=${default_ethernet}
# valid parameter = bridge, host, macvlan or none
network?=bridge

# Local operating system (Windows_NT, Darwin, Linux)
ifeq ($(OS),Windows_NT)
	SYSTEM=$(OS)
else
	SYSTEM=$(shell uname -s)
endif

## Print this help
help:
	@printf "${TITLE} TangoMan Dockerized Kali ${NL}\n"

	@printf "${CAPTION} Infos:${NL}"
	@printf "${PRIMARY} %-12s${INFO} %s${NL}"   "wifi"     ${default_wifi}
	@printf "${PRIMARY} %-12s${INFO} %s${NL}\n" "ethernet" ${default_ethernet}

	@printf "${CAPTION} Description:${NL}"
	@printf "${WARNING} Spawn a dockerized Kali Linux host easily${NL}\n"

	@printf "${CAPTION} Usage:${NL}"
	@printf "${WARNING} make [command] `awk -F '?' '/^[ \t]+?[a-zA-Z0-9_-]+[ \t]+?\?=/{gsub(/[ \t]+/,"");printf"%s=[%s]\n",$$1,$$1}' ${MAKEFILE_LIST}|sort|uniq|tr '\n' ' '`${NL}\n"

	@printf "${CAPTION} Config:${NL}"
	$(eval CONFIG:=$(shell awk -F '?' '/^[ \t]+?[a-zA-Z0-9_-]+[ \t]+?\?=/{gsub(/[ \t]+/,"");printf"$${PRIMARY}%-12s$${DEFAULT} $${INFO}$${%s}$${NL}\n",$$1,$$1}' ${MAKEFILE_LIST}|sort|uniq))
	@printf " ${CONFIG}\n"

	@printf "${CAPTION} Commands:${NL}"
	@awk '/^### /{printf"\n${BOLD}%s${NL}",substr($$0,5)} \
	/^[a-zA-Z0-9_-]+:/{HELP="";if(match(PREV,/^## /))HELP=substr(PREV, 4); \
		printf " ${LABEL}%-12s${DEFAULT} ${PRIMARY}%s${NL}",substr($$1,0,index($$1,":")),HELP \
	}{PREV=$$0}' ${MAKEFILE_LIST}

##################################################
### Kali Linux
##################################################

## Start in cli mode (build cmd status shell)
up: build cmd status shell

## Build container
build:
ifeq ($(shell test -f ./${image} && echo true),true)
	@printf "${INFO}docker build . -f ${image} -t ${container}${NL}"
	@docker build . -f ${image} -t ${container}
else
	@printf "${WARNING}Dockerfile not found, skipping${NL}"
endif

## Open in default browser
open:
ifeq ($(shell docker inspect -f '{{ .NetworkSettings.IPAddress }}' ${container} 2>/dev/null),)
	@printf "${INFO}xdg-open http://localhost${app_route}${NL}"
	@xdg-open http://localhost${app_route}
else
	@printf "${INFO}xdg-open http://`docker inspect -f '{{ .NetworkSettings.IPAddress }}' ${container}`${app_route}${NL}"
	@xdg-open http://`docker inspect -f '{{ .NetworkSettings.IPAddress }}' ${container}`${app_route}
endif

##################################################
### Docker Container
##################################################

## Start container and bind host CWD with given guest path
start:
ifeq (${workdir},)
	@printf "${INFO}docker run --detach --name ${container} --network ${network} --rm -P ${container}${NL}"
	@docker run --detach --name ${container} --network ${network} --rm -P ${container}
else
	@printf "${INFO}docker run --volume \"$(PWD)\":${workdir} --detach --name ${container} --network ${network} --rm -P ${container}${NL}"
	@docker run --volume "$(PWD)":${workdir} --detach --name ${container} --network ${network} --rm -P ${container}
endif

## Start container with given command binding host CWD with given guest path
cmd:
ifeq (${workdir},)
	@printf "${INFO}docker run --detach --name ${container} --network ${network} --rm -P ${container} tail -f /dev/null${NL}"
	@docker run --detach --name ${container} --network ${network} --rm -P ${container} tail -f /dev/null
else
	@printf "${INFO}docker run --volume \"$(PWD)\":${workdir} --detach --name ${container} --network ${network} --rm -P ${container} tail -f /dev/null${NL}"
	@docker run --volume "$(PWD)":${workdir} --detach --name ${container} --network ${network} --rm -P ${container} tail -f /dev/null
endif

## Open shell as root into running container
shell:
	@printf "${INFO}docker exec -u 0 -it ${container} /bin/bash${NL}"
	@docker exec -u 0 -it ${container} /bin/bash

## Print image status
status:
	@printf "${LABEL}image:      ${INFO}%s${NL}"        "`docker inspect --format '{{ .Config.Image }}' ${container} 2>/dev/null`"
	@printf "${LABEL}hostname:   ${INFO}%s${NL}"        "`docker inspect --format '{{ .Config.Hostname }}' ${container} 2>/dev/null`"
ifneq ($(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container}),)
	@printf "${LABEL}ip address: ${INFO}%s${NL}"        "`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container} 2>/dev/null`"
	@printf "${LABEL}open ports: ${INFO}%s${NL}"        "`docker port ${container} 2>/dev/null`"
	@printf "${LABEL}local url:  ${INFO}http://%s${NL}" "`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container} 2>/dev/null`"
else
	@if [ ${network} != 'host' ]; then \
		printf "${LABEL}ip address: ${DANGER}error${NL}"; \
		printf "${LABEL}open ports: ${DANGER}error${NL}"; \
	else \
		printf "${LABEL}ip address: ${INFO}127.0.0.1${NL}"; \
		printf "${LABEL}local url:  ${INFO}http://localhost${NL}"; \
	fi
endif

## Print container volumes
volumes:
ifeq ($(shell test -x `which python 2>/dev/null` && echo true),true)
	@printf "${INFO}docker inspect --format='{{ json .Mounts }}' ${container} ${NL}"
	@docker inspect --format='{{ json .Mounts }}' ${container} 2>/dev/null | python -m json.tool
else
	@printf "${INFO}docker inspect --format='{{ json .Mounts }}' ${container} ${NL}"
	@docker inspect --format='{{ json .Mounts }}' ${container} 2>/dev/null
endif

## Print container logs
logs:
	@printf "${INFO}docker logs ${container} --tail 5${NL}"
	@docker logs ${container} --tail 5

## Stop container
stop:
	@printf "${INFO}docker stop ${container}${NL}"
	@docker stop ${container}

## Kill container
kill:
	@printf "${INFO}docker kill ${container}${NL}"
	@docker kill ${container}
	@printf "${INFO}docker rm ${container} 2>/dev/null${NL}"
	@docker rm ${container} 2>/dev/null

## Stop and remove image
remove:
	-@make -s kill
	@printf "${INFO}docker image rm ${container}${NL}"
	@docker image rm ${container}

##################################################
### Docker Manager
##################################################

## List images, volumes and network information
top:
	@printf "${INFO}docker ps --all${NL}"
	@docker ps --all
	@printf "${INFO}docker images --all${NL}"
	@docker images --all
	@printf "${INFO}docker volume ls${NL}"
	@docker volume ls
	@printf "${INFO}docker network ls${NL}"
	@docker network ls
	@printf "${INFO}docker inspect --format '{{ .Name }}: {{ .NetworkSettings.IPAddress }}' `docker ps --quiet | tr '\n' ' '` 2>/dev/null${NL}"
	@docker inspect --format '{{ .Name }}: {{ .NetworkSettings.IPAddress }}' `docker ps --quiet | tr '\n' ' '` 2>/dev/null

## Stop all running containers
stop-all:
	@printf "${INFO}docker stop `docker ps --quiet`${NL}"
	@docker stop `docker ps --quiet`

## Kill all running containers
kill-all:
	@printf "${INFO}docker kill `docker ps --quiet | tr '\n' ' '` 2>/dev/null${NL}"
	@docker kill `docker ps --quiet | tr '\n' ' '` 2>/dev/null
	@printf "${INFO}docker rm `docker ps --all --quiet | tr '\n' ' '` 2>/dev/null${NL}"
	@docker rm `docker ps --all --quiet | tr '\n' ' '` 2>/dev/null

## Remove all unused system, images, containers, volumes and networks
clean:
	@printf "${INFO}docker system prune --force${NL}"
	@docker system prune --force
	@printf "${INFO}docker image prune --all --force${NL}"
	@docker image prune --all --force
	@printf "${INFO}docker container prune --force${NL}"
	@docker container prune --force
	@printf "${INFO}docker volume prune --force${NL}"
	@docker volume prune --force
	@printf "${INFO}docker network prune --force${NL}"
	@docker network prune --force

## Kill and remove all system, images, containers, volumes and networks
remove-all:
	-@make -s kill-all
	-@make -s clean

##################################################
### Docker Install Host
##################################################

## Install docker locally
docker-install:
ifeq (${SYSTEM},Linux)
	@printf "${INFO}sudo apt-get install -y docker.io${NL}"
	@sudo apt-get install -y docker.io
	@printf "${INFO}sudo usermod -a -G docker ${USER}${NL}"
	@sudo usermod -a -G docker ${USER}
	@printf "${INFO}sudo su ${USER}${NL}"
	@sudo su ${USER}
endif

## Remove docker
docker-remove:
ifeq (${SYSTEM},Linux)
	@printf "${INFO}sudo apt-get remove -y docker.io${NL}"
	@sudo apt-get remove -y docker.io
endif

##################################################
### System
##################################################

## Print system information
sysinfo:
	@printf "${INFO}whoami${NL}"
	@whoami
	@printf "${INFO}id --user${NL}"
	@id --user
	@printf "${INFO}id --groups --name${NL}"
	@id --groups --name
	@printf "${INFO}id --groups${NL}"
	@id --groups
	@if [ -n "$(shell lsb_release -a 2>/dev/null)" ]; then \
		printf "${INFO}lsb_release -a${NL}"; \
		lsb_release -a; \
	else \
		printf "${WARNING}\"lsb_release\" not available${NL}"; \
	fi
	@if [ -n "$(shell uname -a 2>/dev/null)" ]; then \
		printf "${INFO}uname -a${NL}"; \
		uname -a; \
	else \
		printf "${WARNING}\"uname\" not available${NL}"; \
	fi
	@if [ -n "$(shell hostname 2>/dev/null)" ]; then \
		printf "${INFO}hostname -i${NL}"; \
		hostname -i; \
		printf "${INFO}hostname -I${NL}"; \
		hostname -I; \
	else \
		printf "${WARNING}\"hostname\" not available${NL}"; \
	fi
	@if [ -n "$(shell ip -V 2>/dev/null)" ]; then \
		printf "${INFO}ip addr${NL}"; \
		ip addr; \
	else \
		printf "${WARNING}\"ip\" not available${NL}"; \
	fi
	@if [ -n "$(shell ifconfig 2>/dev/null)" ]; then \
		printf "${INFO}ifconfig${NL}"; \
		ifconfig; \
	else \
		printf "${WARNING}\"ifconfig\" not available${NL}"; \
	fi
	@if [ -n "$(shell netstat 2>/dev/null)" ]; then \
		printf "${INFO}netstat -tulpn${NL}"; \
		netstat -tulpn; \
	else \
		printf "${WARNING}\"netstat\" not available${NL}"; \
	fi
	@if [ -n "$(shell lshw 2>/dev/null)" ]; then \
		printf "${INFO}lshw -short${NL}"; \
		lshw -short; \
	else \
		printf "${WARNING}\"lshw\" not available${NL}"; \
	fi
	@if [ -n "$(shell df 2>/dev/null)" ]; then \
		printf "${INFO}df -h | grep -vP \"/dev/loop\d+\"${NL}"; \
		df -h | grep -vP "/dev/loop\d+"; \
	else \
		printf "${WARNING}\"df\" not available${NL}"; \
	fi
	@if [ -n "$(shell service 2>/dev/null)" ]; then \
		printf "${INFO}service --status-all${NL}"; \
		service --status-all; \
	else \
		printf "${WARNING}\"service\" not available${NL}"; \
	fi
	@if [ -n "$(shell systemctl 2>/dev/null)" ]; then \
		printf "${INFO}systemctl | grep running | sed -E 's/\s+/ /g' | sed 's/ loaded active running /\t/'${NL}"; \
		systemctl | grep running | sed -E 's/\s+/ /g' | sed 's/ loaded active running /\t/'; \
	else \
		printf "${WARNING}\"systemctl\" not available${NL}"; \
	fi

##################################################
### Check install
##################################################

## Check correct environment installation
check:
	@if [ -n "$(shell ansible --version 2>/dev/null)" ]; then \
		printf "${INFO}ansible --version${NL}"; \
		ansible --version; \
	else \
		printf "${WARNING}ansible is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell apache2 --version 2>/dev/null)" ]; then \
		printf "${INFO}apache2 --version${NL}"; \
		apache2 --version; \
	else \
		printf "${WARNING}apache2 is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell aws --version 2>/dev/null)" ]; then \
		printf "${INFO}aws --version${NL}"; \
		aws --version; \
	else \
		printf "${WARNING}aws is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell bundle --version 2>/dev/null)" ]; then \
		printf "${INFO}bundle --version${NL}"; \
		bundle --version; \
	else \
		printf "${WARNING}bundle is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell chef --version 2>/dev/null)" ]; then \
		printf "${INFO}chef --version${NL}"; \
		chef --version; \
	else \
		printf "${WARNING}chef is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell php --version 2>/dev/null)" ]; then \
		if [ -x "$(shell which composer 2>/dev/null)" ]; then \
			printf "${INFO}$(shell which composer) --version${NL}"; \
			$(shell which composer) --version; \
		else \
			printf "${WARNING}composer is not installed on your system${NL}"; \
		fi; \
	else \
		printf "${WARNING}unable to show composer version, php not installed${NL}"; \
	fi
	@if [ -n "$(shell curl --version 2>/dev/null)" ]; then \
		printf "${INFO}curl --version$ | head -n1${NL}"; \
		curl --version | head -n1; \
	else \
		printf "${WARNING}curl is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell docker --version 2>/dev/null)" ]; then \
		printf "${INFO}docker --version${NL}"; \
		docker --version; \
	else \
		printf "${WARNING}docker is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell docker-compose --version 2>/dev/null)" ]; then \
		printf "${INFO}docker-compose --version${NL}"; \
		docker-compose --version; \
	else \
		printf "${WARNING}docker-compose is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell gem --version 2>/dev/null)" ]; then \
		printf "${INFO}gem --version${NL}"; \
		gem --version; \
	else \
		printf "${WARNING}gem is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell git --version 2>/dev/null)" ]; then \
		printf "${INFO}git --version${NL}"; \
		git --version; \
	else \
		printf "${WARNING}git is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell ip -V 2>/dev/null)" ]; then \
		printf "${INFO}ip -V${NL}"; \
		ip -V; \
	else \
		printf "${WARNING}ip is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell iptables --version 2>/dev/null)" ]; then \
		printf "${INFO}iptables --version${NL}"; \
		iptables --version; \
	else \
		printf "${WARNING}iptables is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell mysql --version 2>/dev/null)" ]; then \
		printf "${INFO}mysql --version${NL}"; \
		mysql --version; \
	else \
		printf "${WARNING}mysql is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell nginx --version 2>/dev/null)" ]; then \
		printf "${INFO}nginx --version${NL}"; \
		nginx --version; \
	else \
		printf "${WARNING}nginx is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell nodejs --version 2>/dev/null)" ]; then \
		printf "${INFO}nodejs --version${NL}"; \
		nodejs --version; \
	else \
		printf "${WARNING}nodejs is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell npm --version 2>/dev/null)" ]; then \
		printf "${INFO}npm --version${NL}"; \
		npm --version; \
	else \
		printf "${WARNING}npm is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell openssl version 2>/dev/null)" ]; then \
		printf "${INFO}openssl version${NL}"; \
		openssl version; \
	else \
		printf "${WARNING}openssl is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell php --version 2>/dev/null)" ]; then \
		printf "${INFO}php --version${NL}"; \
		php --version; \
		printf "${INFO}php -m${NL}"; \
		php -m; \
	else \
		printf "${WARNING}php is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell pip --version 2>/dev/null)" ]; then \
		printf "${INFO}pip --version${NL}"; \
		pip --version; \
	else \
		printf "${WARNING}pip is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell pip3 --version 2>/dev/null)" ]; then \
		printf "${INFO}pip3 --version${NL}"; \
		pip3 --version; \
	else \
		printf "${WARNING}pip3 is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell psql --version 2>/dev/null)" ]; then \
		printf "${INFO}psql --version${NL}"; \
		psql --version; \
	else \
		printf "${WARNING}postgresql is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell python --version 2>/dev/null)" ]; then \
		printf "${INFO}python --version${NL}"; \
		python --version; \
	else \
		printf "${WARNING}python is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell python2 --version 2>/dev/null)" ]; then \
		printf "${INFO}python2 --version${NL}"; \
		python2 --version; \
	else \
		printf "${WARNING}python2 is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell python3 --version 2>/dev/null)" ]; then \
		printf "${INFO}python3 --version${NL}"; \
		python3 --version; \
	else \
		printf "${WARNING}python3 is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell ruby --version 2>/dev/null)" ]; then \
		printf "${INFO}ruby --version${NL}"; \
		ruby --version; \
	else \
		printf "${WARNING}ruby is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell rvm --version 2>/dev/null)" ]; then \
		printf "${INFO}rvm --version${NL}"; \
		rvm --version; \
	else \
		printf "${WARNING}rvm is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell sqlite3 --version 2>/dev/null)" ]; then \
		printf "${INFO}sqlite3 --version${NL}"; \
		sqlite3 --version; \
	else \
		printf "${WARNING}sqlite3 is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell ufw --version 2>/dev/null)" ]; then \
		printf "${INFO}ufw --version${NL}"; \
		ufw --version; \
	else \
		printf "${WARNING}ufw is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell vagrant --version 2>/dev/null)" ]; then \
		printf "${INFO}vagrant --version${NL}"; \
		vagrant --version; \
	else \
		printf "${WARNING}vagrant is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell vboxmanage --version 2>/dev/null)" ]; then \
		printf "${INFO}vboxmanage --version${NL}"; \
		vboxmanage --version; \
	else \
		printf "${WARNING}vboxmanage is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell virtualenv --version 2>/dev/null)" ]; then \
		printf "${INFO}virtualenv --version${NL}"; \
		virtualenv --version; \
	else \
		printf "${WARNING}virtualenv is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell wget --version 2>/dev/null)" ]; then \
		printf "${INFO}wget --version | head -n1${NL}"; \
		wget --version | head -n1; \
	else \
		printf "${WARNING}wget is not installed on your system${NL}"; \
	fi
	@if [ -n "$(shell which yarn 2>/dev/null)" ]; then \
		printf "${INFO}yarn --version${NL}"; \
		yarn --version; \
	else \
		printf "${WARNING}yarn is not installed on your system${NL}"; \
	fi
