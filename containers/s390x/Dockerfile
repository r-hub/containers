
FROM --platform=linux/s390x ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y r-base && \
    apt-get clean

# Use R-hub repo
RUN echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/ubuntu-22.04-s390x/4.1', getOption('repos')))" \
      >> /usr/lib/R/library/base/R/Rprofile

# Install pak into system lib
RUN R -q -e 'install.packages("https://github.com/cran/pak/releases/download/0.7.2/pak_0.7.2_b1_R4.1_s390x-ibm-linux-gnu-ubuntu-22.04.tar.gz", repos = NULL, lib = .Library)'

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
