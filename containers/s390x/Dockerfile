
FROM --platform=linux/s390x ubuntu:24.04
ENV R_HUB=true

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y r-base && \
    apt-get clean

# Use R-hub repo
RUN echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/ubuntu-22.04-s390x/4.3', getOption('repos')))" \
      >> /usr/lib/R/library/base/R/Rprofile

# System requirements that pak does not know about
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y patch && \
    apt-get clean

# Install pak into system lib
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y libcurl4-openssl-dev && \
    apt-get clean
RUN R -q -e 'install.packages("pak", lib = .Library)'
RUN R -q -e 'library(pak)'

# Locale

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen en_GB.UTF-8 en_US.UTF-8 && \
    update-locale
ENV LC_ALL en_US.UTF-8
ENV LC_COLLATE C
ENV LANG en_US.UTF-8
ENV TZ UTC

# useful for R CMD check

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y devscripts && \
    apt-get clean

# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'

# Copy check script

COPY r-check /usr/local/bin

# check config

ENV _R_CHECK_BASHISMS_=false

WORKDIR /root
