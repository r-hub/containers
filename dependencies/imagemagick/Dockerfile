
FROM ubuntu:22.04

WORKDIR /root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl && \
    curl -LO https://imagemagick.org/archive/ImageMagick.tar.gz && \
    tar xzf ImageMagick.tar.gz && \
    rm ImageMagick.tar.gz

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
    apt-get install -y pkg-config make

RUN ln -s /usr/bin/clang-16 /usr/bin/clang && \
    ln -s /usr/bin/clang++-16 /usr/bin/clang++

# dependencies
RUN apt-get install -y libjpeg8-dev libpng-dev libtiff-4

RUN cd ImageMagick-* && \
    ./configure --prefix=/usr/local/clang CC=clang CXX=clang++ \
        'CXXFLAGS=-stdlib=libc++ -O3 -g' \
        LDFLAGS=-stdlib=libc++ 'LIBS=-lc++ -lc++abi' && \
    make

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y checkinstall && \
    cd ImageMagick-* && \
    mkdir -p /usr/share/doc/protobuf-clang/ && \
    cp LICENSE README.md /usr/share/doc/protobuf-clang/ && \
    echo /usr/share/doc/protobuf-clang/LICENSE > /tmp/xlist && \
    echo /usr/share/doc/protobuf-clang/README.md >> /tmp/xlist && \
    checkinstall -y -D --pkgname protobuf-clang \
    --maintainer "csardi.gabor@gmail.com" \
    --include /tmp/xlist \
    --requires 'libc++1-16,libc++abi1-16,libunwind-16,libc6,libgcc-s1' \
    --arch $(dpkg --print-architecture) \
    --pkglicense "See LICENSE file."

RUN cp protobuf-*/protobuf-clang*.deb /root/

COPY build.sh /root/build.sh
