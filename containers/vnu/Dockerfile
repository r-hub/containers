
FROM ubuntu:24.04
ENV R_HUB=true

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl jq && \
    R_VERSION=$(curl -sL https://api.r-hub.io/rversions/r-release | jq -r .version) && \
    cd /tmp && \
    . /etc/os-release && \
    curl -LO "https://cdn.posit.co/r/${ID}-$(echo $VERSION_ID | tr -d .)/pkgs/r-${R_VERSION}_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    rm r-*.deb && \
    ln -s /opt/R/* /opt/R/release && \
    apt-get clean

# System requirements that pak does not know about
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y patch git default-jdk && \
    apt-get clean

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/release/bin:${PATH}"

# ------------------------------------------------------------------------------------
# Set CRAN repo, R-hub repo

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/release/lib/R/library/base/R/Rprofile

# ------------------------------------------------------------------------------------
# Locale

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen en_GB.UTF-8 en_US.UTF-8 && \
    update-locale
ENV LC_COLLATE C
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Install pak, vnu

RUN /opt/R/release/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch)); st <- pak::lib_status()'

RUN R CMD javareconf
RUN R -e 'pak::pkg_install("W3CMarkupValidator")'
RUN R -e 'pak::repo_add(DC = "https://datacube.wu.ac.at/"); pak::pkg_install("vnu.jar")'

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin
COPY vnu.sh /usr/local/bin

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'

# ------------------------------------------------------------------------------------
# Config for r-hub/actions

ENV RHUB_ACTIONS_DEPS_DEPENDENCIES='"hard"'
ENV RHUB_ACTIONS_CHECK_SCRIPT=vnu.sh
