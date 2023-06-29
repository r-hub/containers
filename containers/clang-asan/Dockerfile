
FROM ubuntu:22.04

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl && \
    cd /tmp && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-ubuntu-2204-devel-asan_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    rm r-*.deb && \
    apt-get clean

# ------------------------------------------------------------------------------------
# clang 16, gfortran-12

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y gnupg curl && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" \
         > /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main" \
         >> /etc/apt/sources.list.d/llvm.list && \
    curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y clang-16 libc++abi-16-dev libc++-16-dev libomp-16-dev && \
    apt-get install -y gfortran-12 && \
    apt-get clean

# ------------------------------------------------------------------------------------
# system dependencies

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb https://r-hub.github.io/ppa/ jammy main" \
         > /etc/apt/sources.list.d/rhub.list && \
    curl -L https://raw.githubusercontent.com/r-hub/ppa/main/rhub.gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install protobuf-clang

# ------------------------------------------------------------------------------------
# Useful system packages, some are needed for R CMD check

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y pkg-config perl && \
    apt-get clean

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# ------------------------------------------------------------------------------------
# Update the system config, because the user Makevars is ignored
# for some packages
RUN app="-fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer"; \
    appxx="$app -frtti"; \
    makeconf="/opt/R/devel-asan/lib/R/etc/Makeconf"; \
    sed -i -E '/^CC ?=/ s/$/ '"$app"/ "${makeconf}" && \
    sed -i -E '/^CC[0-9][0-9] ?=/ s/$/ '"$app"/ "${makeconf}" && \
    sed -i -E '/^CXX ?=/ s/$/ '"$appxx"/ "${makeconf}" && \
    sed -i -E '/^CXX[0-9][0-9] ?=/ s/$/ '"$appxx"/ "${makeconf}"


# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-asan/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, we don't use P3M, because of the gcc <-> clang ABI
# differences. :(

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile

RUN if [ "$(uname -p)" = "x86_64" ]; then \
        echo 'options(pkg.current_platform = "x86_64-pc-linux-gnu-ubuntu-22.04-libc++")' \
            >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile; \
        echo 'options(repos = c(RHUB = "https://raw.githubusercontent.com/r-hub/repos/main/ubuntu-22.04/4.4/libc++", getOption("repos")))' \
            >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-asan/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
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

ENV OMP_THREAD_LIMIT=2
ENV R_DATATABLE_NUM_THREADS=2

# ------------------------------------------------------------------------------------
# Check config, only runtime checks

ENV CHECK_ARGS="--extra-arch --no-stop-on-test-error"
