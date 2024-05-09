## Emacs, make this -*- mode: sh; -*-

FROM ubuntu:22.04 as build

WORKDIR /root

# -------------------------------------------------------------------------
# Install rchk

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && sed -i "s|# deb-src|deb-src|g" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y git make clang llvm-dev '^clang++$' llvm \
               libllvm14 libc++-dev libc++abi-dev \
    && apt-get clean

RUN set -x \
    && git clone -b llvm14 https://github.com/kalibera/rchk.git \
    && cd rchk/src \
    && echo 'export WLLVM=/usr/local/bin'    > ../scripts/config.inc \
    && echo 'export LLVM=/usr/lib/llvm-14' >> ../scripts/config.inc \
    && echo 'export RCHK=/root/rchk' >> ../scripts/config.inc \
    && CXX=clang++ make

RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y python3-pip \
    && pip3 install wllvm \
    && apt-get clean

## Get R sources and configure rchk
RUN set -x \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y subversion rsync file \
    && mkdir /root/R-svn/ && \
    svn checkout https://svn.r-project.org/R/trunk /root/R-svn

ENV WLLVM=/usr/local/bin
ENV LLVM=/usr/lib/llvm-14
ENV RCHK=/root/rchk

RUN set -x \
    && cd /root/R-svn/ \
    && /root/rchk/scripts/build_r.sh
