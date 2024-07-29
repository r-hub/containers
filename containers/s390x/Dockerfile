
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

