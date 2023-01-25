
FROM ubuntu:22.04

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements
# rig also sets up the CRAN mirror, we don't install pak, because rig
# installs it into the user lib, and we want it in the system lib.

RUN ARCH="$(arch)"; \
    if [ "$ARCH" = "aarch64" ]; then ARM64="-arm64"; else ARM64=""; fi; \
    apt-get update -y && \
    apt-get install -y curl && \
    curl -Ls https://github.com/r-lib/rig/releases/download/latest/rig-linux${ARM64}-latest.tar.gz | tar xz -C /usr/local && \
    rig add devel --without-pak && \
    rm -rf /tmp/rig && \
    apt-get clean

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Use P3M on x86_64

RUN if [ "$(uname -p)" = "x86_64" ]; then \
        curl -s https://api.r-hub.io/rversions/r-release | \
            sed 's/^.*version":"\([0-9.][0-9.]*\)".*$/\1/' >/tmp/rver; \
        echo 'options(HTTPUserAgent = sprintf("R/'$(cat /tmp/rver)' (ubuntu-22.04) R ('$(cat /tmp/rver)' %s)", paste(R.version$platform, R.version$arch, R.version$os)))' \
            >> /opt/R/devel/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen en_GB.UTF-8 && \
    update-locale
ENV LC_ALL en_GB.UTF-8
ENV LC_COLLATE C
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# clang 16

RUN apt-get update -y && \
    apt-get install -y gnupg && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy main" \
         > /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy main" \
         >> /etc/apt/sources.list.d/llvm.list && \
    curl -L https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-get update -y && \
    apt-get install -y clang-16 libc++abi-16-dev libc++-16-dev && \
    apt-get install -y gfortran-12 && \
    apt-get clean

RUN mkdir -p /root/.R
COPY Makevars /root/.R

# ------------------------------------------------------------------------------------
# Check config

ENV _R_CHECK_INSTALL_DEPENDS_ true
## next is the same as --as-cran, but fedora-gcc has false
ENV _R_CHECK_SUGGESTS_ONLY_ true
ENV _R_CHECK_NO_RECOMMENDED_ true
ENV _R_CHECK_DOC_SIZES2_ true
ENV _R_CHECK_DEPRECATED_DEFUNCT_ true
ENV _R_CHECK_SCREEN_DEVICE_ warn
ENV _R_CHECK_REPLACING_IMPORTS_ true
ENV _R_CHECK_TOPLEVEL_FILES_ true
ENV _R_CHECK_DOT_FIRSTLIB_ true
ENV _R_CHECK_RD_LINE_WIDTHS_ true
ENV _R_CHECK_S3_METHODS_NOT_REGISTERED_ true
ENV _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_ true
ENV _R_CHECK_CODE_USAGE_WITH_ONLY_BASE_ATTACHED_ TRUE
ENV _R_CHECK_NATIVE_ROUTINE_REGISTRATION_ true
ENV _R_CHECK_FF_CALLS_ registration
ENV _R_CHECK_PRAGMAS_ true
ENV _R_CHECK_COMPILATION_FLAGS_ true
ENV _R_CHECK_R_DEPENDS_ true
ENV _R_CHECK_PACKAGES_USED_IN_TESTS_USE_SUBDIRS_ true
ENV _R_CHECK_SHLIB_OPENMP_FLAGS_ true
ENV _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_ true
ENV _R_CHECK_CODE_DATA_INTO_GLOBALENV_ true
ENV _R_CHECK_PKG_SIZES_ true

ENV _R_CHECK_LIMIT_CORES_ true
ENV _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_ true
ENV _R_CHECK_AUTOCONF_ true
ENV _R_CHECK_THINGS_IN_CHECK_DIR_ true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_ true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_ "^ompi"
ENV _R_CHECK_BASHISMS_ true
ENV _R_CHECK_ORPHANED_ true
ENV _R_CHECK_DEPENDS_ONLY_DATA_ true
ENV _R_CHECK_XREFS_PKGS_ARE_DECLARED_ true
ENV _R_CHECK_MATRIX_DATA_ TRUE
ENV _R_CHECK_RD_VALIDATE_RD2HTML_ true
ENV _R_CHECK_RD_MATH_RENDERING_ true

# ------------------------------------------------------------------------------------
# Check config, no need to check the PDF manual and vignettes here.
# We also avoid that bashism checks, as it needs external tools.

ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false
