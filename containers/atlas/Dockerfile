
FROM fedora:38

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN dnf -y upgrade && \
    dnf -y install dnf-plugins-core && \
    dnf -y install curl && \
    . /etc/os-release && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/R-rstudio-${ID}-${VERSION_ID}-devel-gcc-1-1.$(arch).rpm" && \
    yum install -y R-*.rpm && \
    rm R-*.rpm

# Extra system packages that pak does not know about
RUN dnf install -y awk && \
    dnf install -y https://rpms.r-pkg.org/fedora-38/jags-4.3.2-1.$(arch).rpm

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
        . /etc/os-release; \
        RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
        echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}', getOption('repos')))" \
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

RUN dnf install -y pkg-config devscripts-checkbashisms qpdf git tidy

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
ENV _R_CHECK_BROWSER_NONINTERACTIVE_ true

ENV _R_CHECK_LIMIT_CORES_ true
ENV _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_ true
ENV _R_CHECK_COMPILATION_FLAGS_KNOWN_ "-Wno-deprecated-declarations -Wno-ignored-attributes -Wno-parentheses -Werror=format-security -Wp,-D_FORTIFY_SOURCE=3 -Werror=implicit-function-declaration -Wstrict-prototypes"
ENV _R_CHECK_AUTOCONF_ true
ENV _R_CHECK_THINGS_IN_CHECK_DIR_ true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_ true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_ "^ompi"
ENV _R_CHECK_BASHISMS_ true
ENV _R_CHECK_DEPENDS_ONLY_DATA_ true
ENV _R_CHECK_MATRIX_DATA_ TRUE
ENV _R_CHECK_RD_VALIDATE_RD2HTML_ true
ENV _R_CHECK_RD_MATH_RENDERING_ true
ENV _R_DEPRECATED_IS_R_ error

# ------------------------------------------------------------------------------------
# Check config, no need to check the PDF manual and vignettes here.
# We also avoid that bashism checks, as it needs external tools.

ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'
