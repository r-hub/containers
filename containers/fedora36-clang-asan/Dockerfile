FROM fedora:36 AS builder

# ------------------------------------------------------------------------------------
# Install dependencies for building clang and R from source

RUN dnf update -y && \
    dnf install -y gcc gcc-c++ make cmake python3 git dnf-plugins-core && \
    dnf config-manager --set-enabled fedora-modular && \
    dnf groupinstall "Development Tools" -y && \
    dnf install -y ninja-build which && \
    dnf clean all

# ------------------------------------------------------------------------------------
# Build and install clang 19 from source

RUN cd /tmp && \
    git clone https://github.com/llvm/llvm-project.git && \
    cd llvm-project && \
    git checkout release/19.x && \
    mkdir -p build && \
    cd build && \
    cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="clang" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-19 && \
    ninja && \
    ninja install && \
    cd /tmp && \
    rm -rf llvm-project

# ------------------------------------------------------------------------------------
# Build R from source

ENV R_VERSION="2024-11-08_r87310"
RUN dnf builddep -y R && \
    curl -O https://cran.r-project.org/src/base-prerelease/R-devel_${R_VERSION}.tar.gz && \
    tar -xzvf R-devel_${R_VERSION}.tar.gz && \
    cd R-devel && \
    ./configure \
    --prefix=/opt/R/${R_VERSION} \
    --enable-R-shlib \
    --enable-memory-profiling && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && \
    rm -rf R-devel

# ------------------------------------------------------------------------------------
# Final stage: Create a minimal image with only the necessary components

FROM fedora:36

# Copy Clang and R from the builder stage
COPY --from=builder /usr/local/llvm-19 /usr/local/llvm-19
COPY --from=builder /opt/R /opt/R

# Install runtime dependencies
RUN dnf update -y && \
    dnf install -y glibc-langpack-en protobuf ImageMagick poppler pkg-config \
        perl qpdf tidy libgfortran libicu which && \
    dnf clean all

# Set environment variables
ENV R_VERSION="2024-11-08_r87310"
ENV PATH="/usr/local/llvm-19/bin:/opt/R/${R_VERSION}/bin:${PATH}"
ENV LC_COLLATE=C
ENV LANG=en_GB.UTF-8
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true
ENV ASAN_OPTIONS="detect_leaks=0"
ENV UBSAN_OPTIONS="print_stacktrace=1"
ENV RJAVA_JVM_STACK_WORKAROUND=0
ENV RGL_USE_NULL=true
ENV R_DONT_USE_TK=true
ENV OMP_THREAD_LIMIT=2
ENV R_DATATABLE_NUM_THREADS=2
ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--extra-arch --no-stop-on-test-error"

# Configure R
RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/${R_VERSION}/lib64/R/library/base/R/Rprofile && \
    if [ "$(uname -p)" = "x86_64" ]; then \
    echo "options(pkg.current_platform = 'x86_64-pc-linux-gnu-fedora-36-libc++')" \
    >> /opt/R/${R_VERSION}/lib64/R/library/base/R/Rprofile; \
    RVER="4.5"; \
    echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/fedora-36/${RVER}/libc++', getOption('repos')))" \
    >> /opt/R/${R_VERSION}/lib64/R/library/base/R/Rprofile; \
    echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
    >> /opt/R/${R_VERSION}/lib64/R/library/base/R/Rprofile; \
    fi

# Use user's package library
RUN Rscript -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# Copy check script
COPY r-check /usr/local/bin

# # Update the system config
RUN app="-fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-sanitize=alignment -fno-omit-frame-pointer -fsanitize=pointer-overflow -fsanitize-trap=pointer-overflow -fsanitize=signed-integer-overflow"; \
    appxx="$app -frtti"; \
    makeconf="/opt/R/${R_VERSION}/lib64/R/etc/Makeconf"; \
    sed -i -E '/^CC ?=/ s/$/ '"$app"/ "${makeconf}" && \
    sed -i -E '/^CC[0-9][0-9] ?=/ s/$/ '"$app"/ "${makeconf}" && \
    sed -i -E '/^CXX ?=/ s/$/ '"$appxx"/ "${makeconf}" && \
    sed -i -E '/^CXX[0-9][0-9] ?=/ s/$/ '"$appxx"/ "${makeconf}"

# # Set compiler options
RUN mkdir -p /root/.R && \
    echo 'CLANGLIB=-stdlib=libc++' >> /root/.R/Makevars && \
    echo 'CXX=$(CCACHE) clang++ $(CLANGLIB)' >> /root/.R/Makevars && \
    echo 'CC=$(CCACHE) clang' >> /root/.R/Makevars && \
    echo 'SHLIB_CXXLD=clang++ $(CLANGLIB)' >> /root/.R/Makevars && \
    echo 'CXXFLAGS=-Wall -O0 -pedantic' >> /root/.R/Makevars

# # Install pak
RUN Rscript -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

RUN dnf clean all -y

# Check compiler
RUN Rscript -e "pak::pkg_install('pkgbuild')" && \
    Rscript -e "pkgbuild::check_build_tools(debug = TRUE)"
