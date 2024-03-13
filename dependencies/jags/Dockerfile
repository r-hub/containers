
FROM ubuntu:22.04

WORKDIR /root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl && \
    curl -L -o jags.tar.gz \
        https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/JAGS-4.3.2.tar.gz/download && \
    tar xzf jags.tar.gz && \
    rm jags.tar.gz

# ------------------------------------------------------------------------------------
# clang 16, gfortran-12

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y gnupg curl && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" \
         > /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" \
         >> /etc/apt/sources.list.d/llvm.list && \
    curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y clang-16 libc++abi-16-dev libc++-16-dev libomp-16-dev && \
    apt-get install -y pkg-config make gfortran

RUN ln -s /usr/bin/clang-16 /usr/bin/clang && \
    ln -s /usr/bin/clang++-16 /usr/bin/clang++

# dependencies
RUN apt-get install -y libopenblas-dev

RUN cd JAGS-* && \
    ./configure --prefix=/usr/local/clang CC=clang CXX=clang++ \
        'CXXFLAGS=-stdlib=libc++ -O3 -g' \
        LDFLAGS=-stdlib=libc++ 'LIBS=-lc++ -lc++abi' && \
    make

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y checkinstall && \
    cd JAGS-* && \
    mkdir -p /usr/share/doc/jags-clang/ && \
    cp COPYING README INSTALL AUTHORS NEWS /usr/share/doc/jags-clang/ && \
    echo /usr/share/doc/jags-clang/COPYING > /tmp/xlist && \
    echo /usr/share/doc/jags-clang/README >> /tmp/xlist && \
    echo /usr/share/doc/jags-clang/INSTALL >> /tmp/xlist && \
    echo /usr/share/doc/jags-clang/AUTHORS >> /tmp/xlist && \
    echo /usr/share/doc/jags-clang/NEWS >> /tmp/xlist && \
    checkinstall -y -D --pkgname jags-clang \
    --pkgversion $(basename `pwd` | sed 's/^[^-]*-//') \
    --maintainer "csardi.gabor@gmail.com" \
    --include /tmp/xlist \
    --requires 'libc++1-16,libc++abi1-16,libunwind-16,libc6,libgcc-s1' \
    --arch $(dpkg --print-architecture) \
    --pkglicense "See COPYING file."

RUN cp JAGS-*/jags-clang*.deb /root/

COPY build.sh /root/build.sh
