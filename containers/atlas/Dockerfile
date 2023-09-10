
FROM fedora:38

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN dnf -y upgrade && \
    dnf -y install dnf-plugins-core && \
    dnf -y install curl && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/R-rstudio-fedora-38-devel-gcc-1-1.$(arch).rpm" && \
    yum install -y R-*.rpm && \
    rm R-*.rpm

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-gcc/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, no P3M for Fedora

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-gcc/lib/R/library/base/R/Rprofile

RUN if [ "$(uname -p)" = "x86_64" ]; then \
        echo 'options(repos = c(RHUB = "https://raw.githubusercontent.com/r-hub/repos/main/fedora-38/4.4", getOption("repos")))' \
            >> /opt/R/devel-gcc/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-gcc/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-gcc/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN dnf install -y glibc-langpack-en

ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-gcc/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Useful system packages

RUN dnf install -y pkg-config devscripts-checkbashisms qpdf tidy

# ------------------------------------------------------------------------------------
# Check config

ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false

# ------------------------------------------------------------------------------------
# ATLAS

RUN dnf install -y atlas

RUN blas=$(R -s -q -e 'cat(La_library())') && \
    mv $blas $blas.bak && \
    ln -s /usr/lib64/atlas/libsatlas.so.*.* $blas

RUN R -q -e 'extSoftVersion()["BLAS"]'
RUN R -q -e 'La_library()'

# ------------------------------------------------------------------------------------
# Check config

ENV _R_CHECK_TESTS_NLINES_="0"
