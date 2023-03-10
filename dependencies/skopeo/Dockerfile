
FROM ubuntu:22.04

WORKDIR /root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl libgpgme-dev libassuan-dev libbtrfs-dev \
        libdevmapper-dev pkg-config

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y golang-1.18 go-md2man

ENV GOROOT="/usr/lib/go-1.18"

RUN curl -L https://github.com/containers/skopeo/archive/refs/tags/v1.11.1.tar.gz \
    -o skopeo-1.11.1.tar.gz && \
    mkdir -p $GOROOT/src/github.com/containers && \
    tar xzf skopeo-*.tar.gz -C $GOROOT/src/github.com/containers

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y make checkinstall

RUN cd $GOROOT/src/github.com/containers/skopeo-* && \
    export PATH=/usr/lib/go-1.18/bin:$PATH && \
    make bin/skopeo

RUN cd $GOROOT/src/github.com/containers/skopeo-* && \
    export PATH=/usr/lib/go-1.18/bin:$PATH && \
    checkinstall -y -D --pkgname skopeo \
    --maintainer "csardi.gabor@gmail.com" \
    --requires 'libc6 (>= 2.34), libdevmapper1.02.1 (>= 2:1.02.97), libgpgme11 (>= 1.4.1), libassuan0 (>= 2.5.5), libselinux1 (>= 3.3), libudev1 (>= 249.11), libpcre2-8-0 (>= 10.39)' \
    --arch $(dpkg --print-architecture) \
    --pkglicense "Apache-2.0"

RUN cp $GOROOT/src/github.com/containers/skopeo-*/*.deb /root

COPY build.sh /root/build.sh
