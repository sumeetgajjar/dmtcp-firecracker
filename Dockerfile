FROM ubuntu:14.04

MAINTAINER Sumeet Gajjar<gajjar.s@northeastern.edu>

RUN apt-get update -q && apt-get -qy install \
      build-essential \
      git-core \
      make

COPY dmtcp-2.6.0.tar.gz /firecracker/dmtcp/
WORKDIR /firecracker/dmtcp
RUN tar -xvzf dmtcp-2.6.0.tar.gz --strip-components=1 && ./configure --prefix=/usr && make -j 12 && make install
COPY vmlinux /firecracker/kernel/
COPY rootfs-utils.sh /firecracker/