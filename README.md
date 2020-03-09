TangoMan Dockerized Kali
========================

Awesome **TangoMan Dockerized Kali** is a fast and handy tool to spawn a dockerized Kali Linux host easily.

Official Kali Linux Offensive Security Docker images can be found here:

- [https://hub.docker.com/u/kalilinux](https://hub.docker.com/u/kalilinux)

|         kalilinux          |
|----------------------------|
| kali                       |
| kali-bleeding-edge         |
| kali-bleeding-experimental |
| kali-dev                   |
| kali-rolling               |

- Kali homepage: [https://www.kali.org](https://www.kali.org)
- Offensive Security homepage: [https://www.offensive-security.com](https://www.offensive-security.com)

Features
--------

**TangoMan Dockerized Kali** provides the following features:

- Install docker.io
- Spawn latest Kali rolling host

Dependencies
------------

**TangoMan Dockerized Kali** requires the following dpendencies:

- Make
- Docker

### Make

#### Install Make (Linux)

On linux machine enter following command

```bash
$ sudo apt-get install -y make
```

#### Install Make (Windows)

On windows machine you will need to install [cygwin](http://www.cygwin.com/) or [GnuWin make](http://gnuwin32.sourceforge.net/packages/make.htm) first to execute make script.

### Docker

#### Install Docker (Linux)

On linux machine enter following command

```bash
$ sudo apt-get install -y docker.io
```

#### Configure Docker (Linux)

Add current user to docker group

```bash
$ sudo usermod -a -G docker ${USER}
```
> You will need to log out and log back in current user to use docker

#### Install Docker (Windows)

Download docker installer

- [https://download.docker.com/win/static/stable/x86_64/docker-17.09.0-ce.zip](https://download.docker.com/win/static/stable/x86_64/docker-17.09.0-ce.zip)

#### Install Docker (OSX)

Download docker installer

- [https://download.docker.com/mac/static/stable/x86_64/docker-19.03.5.tgz](https://download.docker.com/mac/static/stable/x86_64/docker-19.03.5.tgz)
- [https://download.docker.com/mac/beta/Docker.dmg](https://download.docker.com/mac/beta/Docker.dmg)

Usage
-----

Run `make` to print help

```bash
$ make [command] adapter=[adapter] app_route=[app_route] command=[command] container=[container] image=[image] network=[network] workdir=[workdir] 
```

Valid commands are: help check start cmd shell status volumes logs stop kill remove up prod dev cli build open docker-install docker-remove top stop-all kill-all clean remove-all sysinfo 

Commands
--------

### help
```
$ make help
```
Print this help

### Check install
#### check
```
$ make check
```
Check correct environment installation

### Docker Container
#### start
```
$ make start
```
Start container and bind host CWD with given guest path

#### cmd
```
$ make cmd
```
Start container with given command binding host CWD with given guest path

#### shell
```
$ make shell
```
Open shell as root into running container

#### status
```
$ make status
```
Print image status

#### volumes
```
$ make volumes
```
Print container volumes

#### logs
```
$ make logs
```
Print container logs

#### stop
```
$ make stop
```
Stop container

#### kill
```
$ make kill
```
Kill container

#### remove
```
$ make remove
```
Stop and remove image

### Docker Image
#### up
```
$ make up
```
Start (build cmd status shell)

#### cli
```
$ make cli
```
Start in cli mode (build cmd status shell)

#### build
```
$ make build
```
Build container

#### open
```
$ make open
```
Open in default browser

### Docker Install Host
#### docker-install
```
$ make docker-install
```
Install docker locally

#### docker-remove
```
$ make docker-remove
```
Remove docker

### Docker Manager
#### top
```
$ make top
```
List images, volumes and network information

#### stop-all
```
$ make stop-all
```
Stop all running containers

#### kill-all
```
$ make kill-all
```
Kill all running containers

#### clean
```
$ make clean
```
Remove all unused system, images, containers, volumes and networks

#### remove-all
```
$ make remove-all
```
Kill and remove all system, images, containers, volumes and networks

### System
#### sysinfo
```
$ make sysinfo
```
Print system information

License
-------

Copyrights (c) 2020 &quot;Matthias Morin&quot; &lt;mat@tangoman.io&gt;

[![License](https://img.shields.io/badge/Licence-MIT-green.svg)](LICENCE)
Distributed under the MIT license.

If you like **TangoMan Dockerized Kali** please star, follow or tweet:

[![GitHub stars](https://img.shields.io/github/stars/TangoMan75/dockerized-kali?style=social)](https://github.com/TangoMan75/dockerized-kali/stargazers)
[![GitHub followers](https://img.shields.io/github/followers/TangoMan75?style=social)](https://github.com/TangoMan75)
[![Twitter](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2FTangoMan75%2Fdockerized-kali)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2FTangoMan75%2Fdockerized-kali)

... And check my other cool projects.

[![LinkedIn](https://img.shields.io/static/v1?style=social&logo=linkedin&label=LinkedIn&message=morinmatthias)](https://www.linkedin.com/in/morinmatthias)
