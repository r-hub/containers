
FROM ubuntu:22.04

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN apt-get update -y && \
    apt-get install -y curl && \
    cd /tmp && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-ubuntu-2204-devel-nold_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    apt-get clean

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-nold/bin:${PATH}"
ENV PKG_SYSREQS=true

# ------------------------------------------------------------------------------------
# Use P3M, set CRAN repo

RUN echo 'options(repos = c(RSPM="https://packagemanager.posit.co/cran/__linux__/jammy/latest", CRAN="https://cran.rstudio.com", getOption("repos")))' \
    >> /opt/R/devel-nold/lib/R/library/base/R/Rprofile
RUN curl -s https://api.r-hub.io/rversions/r-release | sed 's/^.*version":"\([0-9.][0-9.]*\)".*$/\1/' >/tmp/rver && \
    echo 'options(HTTPUserAgent = sprintf("R/'$(cat /tmp/rver)' (ubuntu-22.04) R ('$(cat /tmp/rver)' %s)", paste(R.version$platform, R.version$arch, R.version$os)))' \
    >> /opt/R/devel-nold/lib/R/library/base/R/Rprofile


# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-nold/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN apt-get update -y && \
    apt-get install locales && \
    apt-get clean && \
    locale-gen en_US.UTF-8 && \
    update-locale
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-nold/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Check config

ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false
