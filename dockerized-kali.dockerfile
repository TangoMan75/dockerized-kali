#/**
# * TangoMan dockerized-kali.dockerfile
# *
# * @version  0.1.0
# * @author   "Matthias Morin" <mat@tangoman.io>
# * @licence  MIT
# * @link     https://github.com/TangoMan75/dockerized-kali
# */

# https://hub.docker.com/u/kalilinux
# 
# |         kalilinux          |
# |----------------------------|
# | kali                       |
# | kali-bleeding-edge         |
# | kali-bleeding-experimental |
# | kali-dev                   |
# | kali-rolling               |

FROM kalilinux/kali-rolling

# install tangoman
RUN apt-get update \
    && apt-get install -y curl git make nmap vim \
    && apt-get install -y --no-install-recommends apt-utils \
    && echo "printf \"\\033[0;36m _____%17s_____\\n|_   _|___ ___ ___ ___|%5s|___ ___\\n  | | | .'|   | . | . | | | | .'|   |\\n  |_| |__,|_|_|_  |___|_|_|_|__,|_|_|\\n%14s|___|%6stangoman.io\033[0m\n\"" >> ~/.bashrc \
    && echo "alias ll='ls -alFh'\nalias cc='clear'\nalias xx='exit'\nalias ..='cd ..'" >> ~/.bashrc

# metasploit-framework dependencies
RUN apt-get install -y autoconf build-essential libpcap-dev libpq-dev zlib1g-dev libsqlite3-dev

# install ruby
RUN apt-get install -y ruby-full

WORKDIR /opt/metasploit-framework

# install metasploit-framework
RUN git clone https://github.com/rapid7/metasploit-framework.git . \
    && rm -rf .git \
    && rm -f Gemfile.lock \
    && gem install bundler \
    && bundle config set without 'test development' \
    && bundle install

# make msf commands available everywhere
RUN bash -c 'for MSF in $(ls msf*); do ln -s /opt/metasploit-framework/${MSF} /usr/local/bin/${MSF}; done'

EXPOSE 80

WORKDIR /root

COPY . /root