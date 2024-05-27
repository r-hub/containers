
FROM ubuntu:22.04

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl && \
    cd /tmp && \
    . /etc/os-release && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-${ID}-$(echo $VERSION_ID | tr -d .)-devel-rchk_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    rm r-*.deb && \
    apt-get clean

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-rchk/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, R-hub repo

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-rchk/lib/R/library/base/R/Rprofile

RUN if [ "$(uname -p)" = "x86_64" ]; then \
        . /etc/os-release; \
        RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
        echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}', getOption('repos')))" \
            >> /opt/R/devel-rchk/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-rchk/lib/R/library/base/R/Rprofile; \
    fi
# ------------------------------------------------------------------------------------
# Install pak, our build is not compatible with this image, so install from source
# install.packages() does not fail, so fail explicitly

RUN apt-get install -y libcurl4-openssl-dev

RUN /opt/R/devel-rchk/bin/R -q -e \
    'install.packages("pak", repos = "https://cloud.r-project.org")'

RUN /opt/R/devel-rchk/bin/R -q -e 'pak::lib_status()'

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
# Use user's package library for the rest

RUN /opt/R/devel-rchk/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Config for r-hub/actions

ENV RHUB_ACTIONS_DEPS_DEPENDENCIES='list(direct = "LinkingTo", indirect = "hard")'
ENV RHUB_ACTIONS_CHECK_SCRIPT=rchk.sh
