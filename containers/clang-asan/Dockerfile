
FROM ubuntu:22.04

# ------------------------------------------------------------------------------------
# clang 15, gfortran-12

RUN apt-get update -y && \
    apt-get install -y gnupg curl && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main" \
         > /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main" \
         >> /etc/apt/sources.list.d/llvm.list && \
    curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y clang-15 libc++abi-15-dev libc++-15-dev libomp-15-dev && \
    apt-get install -y gfortran-12 pkg-config && \
    apt-get clean

RUN mkdir -p /root/.R
COPY Makevars /root/.R
# we need to set this, because GHA changes $HOME:
# https://github.com/actions/runner/issues/863
ENV R_MAKEVARS_USER=/root/.R/Makevars

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-ubuntu-2204-devel-asan_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    apt-get clean

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-asan/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, use P3M on x86_64

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile
RUN if [ "$(uname -p)" = "x86_64" ]; then \
        echo 'options(repos = c(RSPM="https://packagemanager.posit.co/cran/__linux__/jammy/latest", getOption("repos")))' \
            >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile; \
        curl -s https://api.r-hub.io/rversions/r-release | \
            sed 's/^.*version":"\([0-9.][0-9.]*\)".*$/\1/' >/tmp/rver; \
        echo 'options(HTTPUserAgent = sprintf("R/'$(cat /tmp/rver)' (ubuntu-22.04) R ('$(cat /tmp/rver)' %s)", paste(R.version$platform, R.version$arch, R.version$os)))' \
            >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-asan/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen en_GB.UTF-8 && \
    update-locale
ENV LC_COLLATE C
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-asan/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Check config

ENV ASAN_OPTIONS="detect_leaks=0"
ENV UBSAN_OPTIONS="print_stacktrace=1"
ENV RJAVA_JVM_STACK_WORKAROUND 0
ENV RGL_USE_NULL true
ENV R_DONT_USE_TK true

# ------------------------------------------------------------------------------------
# Check config, no need to check the PDF manual and vignettes here.
# We also avoid that bashism checks, as it needs external tools.

ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false
