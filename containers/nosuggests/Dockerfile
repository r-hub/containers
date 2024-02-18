
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

RUN if [ "$(uname -m)" = "x86_64" ]; then \
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
# Useful system packages

RUN dnf install -y pkg-config devscripts-checkbashisms qpdf tidy

# ------------------------------------------------------------------------------------
# TinyTeX

RUN dnf install -y perl wget which && \
    cd /root && \
    if [ "$(uname -m)" = "x86_64" ]; then \
      wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh -s - --admin --no-path && \
        ~/.TinyTeX/bin/*/tlmgr install makeindex; \
    else \
      wget -qO- "https://yihui.org/tinytex/install-unx.sh" | sh -s - --admin --no-path && \
        ~/.TinyTeX/bin/*/tlmgr install makeindex; \
    fi
# we can't really query the arch here (FIXME!), but this should be ok
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:/root/.TinyTeX/bin/aarch64-linux:${PATH}"

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Check config
# https://github.com/r-devel/r-dev-web/blob/master/CRAN/QA/BDR/gannet/packages/incoming/check-noSuggests

# -----------------------------------------------------

ENV OMP_THREAD_LIMIT=2

ENV _R_CHECK_FORCE_SUGGESTS_=false
ENV LC_CTYPE=en_GB.utf8
## ENV MYSQL_USER ripley
## ENV POSTGRES_USER ripley
## ENV POSTGRES_DATABASE ripley
## ENV RMPI_INCLUDE /usr/include/openmpi-x86_64
## ENV RMPI_LIB_PATH /usr/lib64/openmpi/lib
## ENV RMPI_TYPE OPENMPI
ENV R_BROWSER=false
ENV R_PDFVIEWER=false
ENV _R_CHECK_INSTALL_DEPENDS_=true
#ENV _R_CHECK_SUGGESTS_ONLY_=true
ENV _R_CHECK_NO_RECOMMENDED_=true
ENV _R_CHECK_DOC_SIZES2_=true
#ENV R_C_BOUNDS_CHECK yes
ENV _R_CHECK_DEPRECATED_DEFUNCT_=true
ENV _R_CHECK_SCREEN_DEVICE_=warn
ENV _R_CHECK_REPLACING_IMPORTS_=true
ENV _R_CHECK_TOPLEVEL_FILES_=true
ENV _R_CHECK_DOT_FIRSTLIB_=true
ENV _R_CHECK_RD_LINE_WIDTHS_=true
ENV _R_CHECK_S3_METHODS_NOT_REGISTERED_=true
ENV _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_=true
ENV _R_CHECK_CODE_USAGE_WITH_ONLY_BASE_ATTACHED_=TRUE
ENV _R_CHECK_NATIVE_ROUTINE_REGISTRATION_=true
ENV _R_CHECK_FF_CALLS_=registration
ENV _R_CHECK_PRAGMAS_=true
ENV _R_CHECK_COMPILATION_FLAGS_=true
ENV _R_CHECK_R_DEPENDS_=true
ENV _R_CHECK_PACKAGES_USED_IN_TESTS_USE_SUBDIRS_=true
#ENV _R_CHECK_PKG_SIZES_=false
ENV _R_CHECK_SHLIB_OPENMP_FLAGS_=true
ENV _R_CHECK_BROWSER_NONINTERACTIVE_=true

#ENV _R_CHECK_CODE_ATTACH_=true
#ENV _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_=true
#ENV _R_CHECK_CODE_DATA_INTO_GLOBALENV_=true

ENV _R_CHECK_VIGNETTES_SKIP_RUN_MAYBE_=true
ENV _R_CHECK_VIGNETTES_NLINES_=0
ENV _R_CHECK_TESTS_NLINES_=0

ENV _R_CHECK_LIMIT_CORES_=true

ENV _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_=true
ENV _R_CHECK_COMPILATION_FLAGS_KNOWN_="-Wno-deprecated-declarations -Wno-ignored-attributes -Wno-parentheses -Werror=format-security -Wp,-D_FORTIFY_SOURCE=3 -fanalyzer -Werror=implicit-function-declaration -Wstrict-prototypes"
ENV _R_CHECK_AUTOCONF_=true
ENV _R_CHECK_THINGS_IN_CHECK_DIR_=true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_=true
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_="^ompi.gannet"
ENV _R_CHECK_BASHISMS_=true
ENV _R_CHECK_DEPENDS_ONLY_DATA_=true
ENV _R_CHECK_BOGUS_RETURN_=true
ENV _R_CHECK_MATRIX_DATA_=TRUE

## no timeouts please
## ENV _R_CHECK_ELAPSED_TIMEOUT_=30m
## ENV _R_CHECK_INSTALL_ELAPSED_TIMEOUT_=180m
## ENV _R_CHECK_TESTS_ELAPSED_TIMEOUT_=90m
## ENV _R_CHECK_BUILD_VIGNETTES_ELAPSED_TIMEOUT_=90m
## ENV _R_CHECK_ONE_VIGNETTE_ELAPSED_TIMEOUT_=60m

ENV _R_CHECK_XREFS_USE_ALIASES_FROM_CRAN_=TRUE

ENV _R_CHECK_RD_VALIDATE_RD2HTML_=true
ENV _R_CHECK_RD_MATH_RENDERING_=true

## ENV WNHOME /usr/share/wordnet-3.0

## ENV R_CRAN_WEB file:///data/gannet/ripley/R
#ENV R_CRAN_WEB https://cran.r-project.org

# -----------------------------------------------------

ENV _R_CHECK_DEPENDS_ONLY_=true

ENV CHECK_ARGS="--extra-arch"
ENV BUILD_ARGS="--no-build-vignettes"
