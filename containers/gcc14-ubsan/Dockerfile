FROM fedora:40

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN dnf -y upgrade && \
    dnf -y install dnf-plugins-core && \
    dnf -y install curl && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/R-rstudio-fedora-40-devel-gcc14-1-1.$(arch).rpm" && \
    yum install -y R-*.rpm && \
    rm R-*.rpm

# Extra system packages that pak does not know about
RUN dnf install -y flexiblas
RUN dnf install -y https://rpms.r-pkg.org/fedora-38/jags-4.3.2-1.$(arch).rpm

# ------------------------------------------------------------------------------------
# Install development tools and sanitizers

RUN dnf -y install libasan libubsan

# ------------------------------------------------------------------------------------
# Put R on PATH
# Auto-install system requirements

ENV PATH="/opt/R/devel-gcc14/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, no P3M for Fedora

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-gcc14/lib/R/library/base/R/Rprofile

RUN if [ "$(arch)" = "x86_64" ]; then \
        . /etc/os-release; \
        RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
        echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}', getOption('repos')))" \
            >> /opt/R/devel-gcc14/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-gcc14/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-gcc14/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Install pkgbuild, rcmdcheck, and decor

RUN /opt/R/devel-gcc14/bin/R -q -e \
    'install.packages(c("pkgbuild", "rcmdcheck", "decor"), repos = "https://cran.rstudio.com")'

# ------------------------------------------------------------------------------------
# Locale

RUN dnf install -y glibc-langpack-en

ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-gcc14/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Useful system packages

RUN dnf -y install pkg-config devscripts-checkbashisms qpdf git tidy

# ------------------------------------------------------------------------------------
# CRAN's config from https://www.stats.ox.ac.uk/pub/bdr/gcc14/README.txt
#
# > Installation checks with GCC 14.1, whose changelog is at
# > https://gcc.gnu.org/gcc-14/changes.html, and other details at
# > https://gcc.gnu.org/pipermail/gcc/2024-May/243921.html
#
# > Other details as https://www.stats.ox.ac.uk/pub/bdr/Rconfig/r-devel-linux-x86_64-fedora-gcc

ENV _R_CHECK_INSTALL_DEPENDS_ true
## the next is the default, but --as-cran has true
ENV _R_CHECK_SUGGESTS_ONLY_ false
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
ENV _R_CHECK_PKG_SIZES_ false
ENV _R_CHECK_SHLIB_OPENMP_FLAGS_ true

ENV _R_CHECK_LIMIT_CORES_ true
ENV _R_CHECK_LENGTH_1_CONDITION_ package:_R_CHECK_PACKAGE_NAME_,verbose
#ENV _R_CHECK_LENGTH_1_LOGIC2_="package:_R_CHECK_PACKAGE_NAME_,verbose"
ENV _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_ true
ENV _R_CHECK_COMPILATION_FLAGS_KNOWN_="-Wno-deprecated-declarations -Wno-ignored-attributes -Wno-parentheses -Werror=format-security -Wp,-D_FORTIFY_SOURCE=3 -Werror=implicit-function-declaration"
ENV _R_CHECK_AUTOCONF_ true
ENV _R_CHECK_THINGS_IN_CHECK_DIR_ true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_ true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_="^ompi"
ENV _R_CHECK_BASHISMS_ true
ENV _R_CHECK_DEPENDS_ONLY_DATA_ true
ENV _R_CHECK_MATRIX_DATA_ TRUE
ENV _R_CHECK_RD_VALIDATE_RD2HTML_ true
ENV _R_CHECK_RD_MATH_RENDERING_ true

# ------------------------------------------------------------------------------------
# Check config, no need to check the PDF manual and vignettes here.
# We also avoid that bashism checks, as it needs external tools.

ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false

# Support R CMD INSTALL --use-LTO ., similarly to CRAN at https://www.stats.ox.ac.uk/pub/bdr/LTO/README.txt
RUN echo -e '# Support --use-LTO\nLTO_OPT = -flto=10\nLTO_FC_OPT = -flto=10' >> /opt/R/devel-gcc14/lib/R/etc/Makeconf

# ------------------------------------------------------------------------------------
# UBSAN and ASAN configuration
# adapted from https://www.stats.ox.ac.uk/pub/bdr/memtests/README.txt

RUN mkdir -p ~/.R/ && echo -e 'CC=gcc -std=gnu11 -fsanitize=address,undefined -fno-omit-frame-pointer\nFC=gfortran -fsanitize=address' >> ~/.R/Makevars
ENV LD_PRELOAD=/usr/lib64/libasan.so.8
ENV ASAN_OPTIONS='detect_leaks=0'
ENV UBSAN_OPTIONS='print_stacktrace=1'
ENV RJAVA_JVM_STACK_WORKAROUND=0
ENV RGL_USE_NULL=true
ENV R_DONT_USE_TK=true
