
FROM ubuntu:26.04
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries
COPY --from=common common.Renviron /root/.Renviron

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl && \
    cd /tmp && \
    . /etc/os-release && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-${ID}-$(echo $VERSION_ID | tr -d .)-devel-asan_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    rm r-*.deb && \
    apt-get clean

# System requirements that pak does not know about
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y patch && \
    apt-get clean

# ------------------------------------------------------------------------------------
# clang 23

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y gpg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL --retry 5 --retry-all-errors https://apt.llvm.org/llvm-snapshot.gpg.key | \
      gpg --dearmor -o /etc/apt/keyrings/apt.llvm.org.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/apt.llvm.org.gpg] http://apt.llvm.org/resolute/ llvm-toolchain-resolute-23 main" \
    > /etc/apt/sources.list.d/llvm.list && \
    apt-get update -y && \
    apt-get install -y clang-23 libc++abi-23-dev libc++-23-dev libomp-23-dev flang-23 && \
    apt-get clean

# ------------------------------------------------------------------------------------
# system dependencies

RUN export DEBIAN_FRONTEND=noninteractive && \
    echo "deb [signed-by=/etc/apt/keyrings/rhub.gpg] https://repos-ppa.r-pkg.org resolute main" \
    > /etc/apt/sources.list.d/rhub.list && \
    curl -L https://raw.githubusercontent.com/r-hub/repos-ppa/main/rhub.gpg.key | \
        gpg --dearmor -o /etc/apt/keyrings/rhub.gpg && \
    apt-get update -y && \
    apt-get install -y protobuf-clang23 jags-clang23 imagemagick-clang23 poppler-clang23

# ------------------------------------------------------------------------------------
# Useful system packages, some are needed for R CMD check

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y pkg-config perl qpdf git tidy && \
    apt-get clean

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# ------------------------------------------------------------------------------------
# Update the system config, because the user Makevars is ignored
# for some packages
RUN app="-fsanitize=undefined -fno-sanitize=function -fno-omit-frame-pointer" \
    appxx="$app -frtti"; \
    makeconf="/opt/R/devel-asan/lib/R/etc/Makeconf"; \
    sed -i -E '/^CC ?=/ s/$/ '"$app"/ "${makeconf}" && \
    sed -i -E '/^CC[0-9][0-9] ?=/ s/$/ '"$app"/ "${makeconf}" && \
    sed -i -E '/^CXX ?=/ s/$/ '"$appxx"/ "${makeconf}" && \
    sed -i -E '/^CXX[0-9][0-9] ?=/ s/$/ '"$appxx"/ "${makeconf}" && \
    sed -i '/^SAN_LIBS[ ]*=/i UBSAN_DIR = /usr/lib/llvm-23/lib/clang/23/lib/linux' "${makeconf}" && \
    sed -i 's|^SAN_LIBS[ ]*=.*$|SAN_LIBS = -L$(UBSAN_DIR) -Wl,-rpath,$(UBSAN_DIR) -lclang_rt.ubsan_standalone-x86_64|' "${makeconf}"

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
    . /etc/os-release; \
    echo "options(pkg.current_platform = 'x86_64-pc-linux-gnu-${ID}-${VERSION_ID}-libc++')" \
    >> /opt/R/devel-asan/lib/R/library/base/R/Rprofile; \
    RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
    echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}/libc++', getOption('repos')))" \
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
    locale-gen en_GB.UTF-8 en_US.UTF-8 && \
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

ENV ASAN_OPTIONS="detect_leaks=0:alloc_dealloc_mismatch=0"
ENV UBSAN_OPTIONS="print_stacktrace=1"
ENV RJAVA_JVM_STACK_WORKAROUND 0
ENV RGL_USE_NULL true
ENV R_DONT_USE_TK true

ENV OMP_THREAD_LIMIT=2
ENV R_DATATABLE_NUM_THREADS=2

# ------------------------------------------------------------------------------------
# Check config, only runtime checks

ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--extra-arch --no-stop-on-test-error"

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'
