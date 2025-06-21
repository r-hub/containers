
FROM fedora:38

# ------------------------------------------------------------------------------------
# onAPI, MKL

COPY oneAPI.repo /etc/yum.repos.d

# Need intel-oneapi-runtime-libs for https://github.com/r-hub/rhub/issues/616
RUN dnf install -y \
    intel-oneapi-mkl-devel-2024.2.0 \
    intel-oneapi-compiler-dpcpp-cpp-2024.2.x86_64 \
    intel-oneapi-compiler-fortran-2024.2.x86_64 \
    intel-oneapi-runtime-libs-2024.2.0 \
    intel-oneapi-mkl-devel-2024.2.0 && \
    dnf clean all

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN dnf -y upgrade && \
    dnf -y install dnf-plugins-core && \
    dnf -y install curl && \
    . /etc/os-release && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/R-rstudio-${ID}-${VERSION_ID}-devel-intel-1-1.$(arch).rpm" && \
    yum install -y R-*.rpm && \
    rm R-*.rpm && \
    dnf clean all

# Extra system packages that pak does not know about
RUN dnf install -y gawk patch && \
    dnf install -y https://rpms.r-pkg.org/fedora-38/jags-4.3.2-1.$(arch).rpm && \
    dnf clean all

# This is needed, according tp https://www.stats.ox.ac.uk/pub/bdr/Intel/README.txt
RUN echo 'ulimit -s 51200' > /etc/profile.d/ulimit.sh

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-intel/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, no P3M for Fedora

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-intel/lib/R/library/base/R/Rprofile

RUN if [ "$(uname -p)" = "x86_64" ] || [ "$(uname -m)" == "x86_64" ]; then \
        . /etc/os-release; \
        RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
        echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}', getOption('repos')))" \
            >> /opt/R/devel-intel/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-intel/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-intel/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN dnf install -y glibc-langpack-en && \
    dnf clean all

ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-intel/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Useful system packages
# openblas-threads is needed for binary packages linking to LAPACK, built on vanilla Fedora

RUN dnf install -y pkg-config devscripts-checkbashisms qpdf git tidy procps openblas-threads && \
    dnf clean all

# ------------------------------------------------------------------------------------
# Copy MKL environment

ENV SETVARS_ARGS --config=/opt/mklconfig.txt
COPY mklconfig.txt /opt/mklconfig.txt

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'

# ------------------------------------------------------------------------------------
# Check config

ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false
