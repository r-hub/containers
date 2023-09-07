
FROM ubuntu:22.04

# ------------------------------------------------------------------------------------
# MKL, based on https://github.com/intel/oneapi-containers/blob/master/images/docker/basekit/Dockerfile.ubuntu-22.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl

COPY intel-oneapi-archive-keyring.gpg /etc/apt/trusted.gpg.d/
COPY intel-graphics-archive-keyring.gpg /etc/apt/trusted.gpg.d/

RUN echo "deb https://apt.repos.intel.com/oneapi all main " > \
    /etc/apt/sources.list.d/oneAPI.list
RUN echo "deb https://repositories.intel.com/graphics/ubuntu jammy flex" > \
    /etc/apt/sources.list.d/intel-graphics.list

RUN apt-get update && apt-get install -y intel-oneapi-mkl-2023.2.0

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN export DEBIAN_FRONTEND=noninteractive && \
    cd /tmp && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-ubuntu-2204-mkl-devel-mkl_1_amd64.deb" && \
    apt install -y ./r-*.deb && \
    rm r-*.deb && \
    apt-get clean

# ------------------------------------------------------------------------------------
# system dependencies

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb https://ppa.r-pkg.org jammy main" \
         > /etc/apt/sources.list.d/rhub.list && \
    curl -L https://raw.githubusercontent.com/r-hub/ppa/main/rhub.gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install protobuf-clang

# ------------------------------------------------------------------------------------
# Useful system packages, some are needed for R CMD check

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y pkg-config perl qpdf tidy && \
    apt-get clean

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-mkl/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, use P3M on x86_64

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-mkl/lib/R/library/base/R/Rprofile
RUN if [ "$(uname -p)" = "x86_64" ]; then \
        echo 'options(repos = c(RHUB = "https://raw.githubusercontent.com/r-hub/repos/main/ubuntu-22.04/4.4", getOption("repos")))' \
            >> /opt/R/devel-mkl/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-mkl/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-mkl/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen en_US.UTF-8 && \
    update-locale
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-mkl/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Check config

ENV CHECK_ARGS="--no-manual --no-build-vignettes"
