
FROM ubuntu:24.04
ENV R_HUB=true

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y curl && \
    cd /tmp && \
    . /etc/os-release && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/r-rstudio-${ID}-$(echo $VERSION_ID | tr -d .)-devel_1_$(dpkg --print-architecture).deb" && \
    apt install -y ./r-*.deb && \
    rm r-*.deb && \
    apt-get clean

# System requirements that pak does not know about
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y patch && \
    apt-get clean

# ------------------------------------------------------------------------------------
# gcc 15, gfortran 15 from ubuntu-toolchain-r/test PPA
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update -y && \
    apt-get install -y gcc-15 g++-15 gfortran-15 && \
    apt-get clean

# We do not replace -lgfortran!
RUN sed -i 's/gcc/gcc-15/g' /opt/R/devel/lib/R/etc/Makeconf && \
    sed -i 's/g[+][+]/g++-15/g' /opt/R/devel/lib/R/etc/Makeconf && \
    sed -i 's/\bgfortran/gfortran-15/g' /opt/R/devel/lib/R/etc/Makeconf

# ------------------------------------------------------------------------------------
# Locale

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen C.UTF-8 en_GB.UTF-8 en_US.UTF-8 && \
    update-locale
ENV LC_COLLATE C
ENV LANG C.UTF-8

# ------------------------------------------------------------------------------------
# TinyTeX, only available for x86_64

RUN export DEBIAN_FRONTEND=noninteractive && \
    if [ "$(uname -m)" = "x86_64" ]; then \
      apt-get update -y && \
      apt-get install -y wget perl && \
      apt-get clean && \
      cd /root && \
      wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh -s - --admin --no-path && \
      ~/.TinyTeX/bin/*/tlmgr update --self || true && \
      ~/.TinyTeX/bin/*/tlmgr install makeindex; \
    fi

# we can't really query the arch here (FIXME!), but this should be ok
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:/root/.TinyTeX/bin/aarch64-linux:${PATH}"

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, use r-hub/repos

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel/lib/R/library/base/R/Rprofile
RUN if [ "$(uname -p)" = "x86_64" ]; then \
        . /etc/os-release; \
        RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
        echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}', getOption('repos')))" \
            >> /opt/R/devel/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Useful system packages, some are needed for R CMD check

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y pkg-config perl tidy qpdf git && \
    apt-get clean

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'

# ------------------------------------------------------------------------------------
# Check config

# From https://svn.r-project.org/R-dev-web/trunk/CRAN/QA/Kurt/.R/check.Renviron

### Defaults for '--as-cran": commented out where not appropriate for
### all KH checks.
ENV _R_CHECK_AUTOCONF_=true
## _R_CHECK_BASHISMS_=true
ENV _R_CHECK_BOGUS_RETURN_=true
ENV _R_CHECK_BROWSER_NONINTERACTIVE_=true
ENV _R_CHECK_CODE_USAGE_VIA_NAMESPACES_=true
ENV _R_CHECK_CODE_USAGE_WITH_ONLY_BASE_ATTACHED_=true
## _R_CHECK_CODOC_VARIABLES_IN_USAGES_=true
ENV _R_CHECK_COMPILATION_FLAGS_=true
## _R_CHECK_CONNECTIONS_LEFT_OPEN_=true
ENV _R_CHECK_DEPENDS_ONLY_DATA_=true
## _R_CHECK_DONTTEST_EXAMPLES_=true
ENV _R_CHECK_DOT_FIRSTLIB_=true
ENV _R_CHECK_FF_AS_CRAN_=true
ENV _R_CHECK_FUTURE_FILE_TIMESTAMPS_=true
ENV _R_CHECK_INSTALL_DEPENDS_=true
ENV _R_CHECK_LIMIT_CORES_=true
ENV _R_CHECK_MATRIX_DATA_=true
## _R_CHECK_NATIVE_ROUTINE_REGISTRATION_=true
ENV _R_CHECK_NO_RECOMMENDED_=true
ENV _R_CHECK_NO_STOP_ON_TEST_ERROR_=true
## _R_CHECK_ORPHANED_=true
ENV _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_=true
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_=true
## _R_CHECK_PACKAGES_USED_CRAN_INCOMING_NOTES_=true
ENV _R_CHECK_PACKAGES_USED_IGNORE_UNUSED_IMPORTS_=true
ENV _R_CHECK_PACKAGES_USED_IN_TESTS_USE_SUBDIRS_=true
ENV _R_CHECK_PRAGMAS_=true
## _R_CHECK_R_DEPENDS_=warn
ENV _R_CHECK_R_ON_PATH_=true
ENV _R_CHECK_RD_VALIDATE_RD2HTML_=true
## _R_CHECK_RD_CONTENTS_KEYWORDS_=true
ENV _R_CHECK_SCREEN_DEVICE_=stop
ENV _R_CHECK_S3_METHODS_NOT_REGISTERED_=true
ENV _R_CHECK_SHLIB_OPENMP_FLAGS_=true
ENV _R_CHECK_TIMINGS_=10
ENV _R_CHECK_THINGS_IN_CHECK_DIR_=true
## _R_CHECK_THINGS_IN_TEMP_DIR_=true
ENV _R_CHECK_VIGNETTE_TITLES_=true
## _R_CHECK_XREFS_PKGS_ARE_DECLARED_=true
## _R_CHECK_XREFS_MIND_SUSPECT_ANCHORS_=true
ENV _R_SHLIB_BUILD_OBJECTS_SYMBOL_TABLES_=true

ENV _R_OPTIONS_STRINGS_AS_FACTORS_=false

### Additional settings used for all KH checks.
ENV _R_CHECK_ALWAYS_LOG_VIGNETTE_OUTPUT_=true
ENV _R_CHECK_CODE_ASSIGN_TO_GLOBALENV_=true
ENV _R_CHECK_CODE_ATTACH_=true
ENV _R_CHECK_CODE_DATA_INTO_GLOBALENV_=true
ENV _R_CHECK_CODETOOLS_PROFILE_="suppressPartialMatchArgs=false"
## <FIXME> Remove eventually (not needed for R >= 4.3.0)
ENV _R_CHECK_COMPILATION_FLAGS_KNOWN_="-Wstrict-prototypes"
## </FIXME>
ENV _R_CHECK_CRAN_INCOMING_CHECK_URLS_IN_PARALLEL_=true
ENV _R_CHECK_DEPRECATED_DEFUNCT_=true
ENV _R_CHECK_DOC_SIZES2_=true
ENV _R_CHECK_DOTCODE_RETVAL_=true
ENV _R_CHECK_EXECUTABLES_EXCLUSIONS_=false
## _R_CHECK_FF_CALLS_=registration
ENV _R_CHECK_FUTURE_FILE_TIMESTAMPS_LEEWAY_=6h
ENV _R_GC_FAIL_ON_ERROR_=true
ENV _R_CHECK_LENGTH_1_CONDITION_="package:_R_CHECK_PACKAGE_NAME_,verbose"
## _R_CHECK_LENGTH_1_CONDITION_=warn
## _R_CHECK_LENGTH_1_LOGIC2_="package:_R_CHECK_PACKAGE_NAME_,verbose"
ENV _R_CHECK_OVERWRITE_REGISTERED_S3_METHODS_=true
ENV _R_CHECK_PACKAGE_DATASETS_SUPPRESS_NOTES_=true
ENV _R_CHECK_PKG_SIZES_=false
ENV _R_CHECK_R_DEPENDS_=true
ENV _R_CHECK_RD_LINE_WIDTHS_=true
ENV _R_CHECK_RD_MATH_RENDERING_=true
ENV _R_CHECK_REPLACING_IMPORTS_=true
ENV _R_CHECK_SERIALIZATION_=true
ENV _R_CHECK_SRC_MINUS_W_IMPLICIT_=true
ENV _R_CHECK_SUGGESTS_ONLY_=true
ENV _R_CHECK_SYSTEM_CLOCK_=false
ENV _R_CHECK_THINGS_IN_TEMP_DIR_EXCLUDE_="^(ompi|pulse|runtime-)"
ENV _R_CHECK_TOPLEVEL_FILES_=true
ENV _R_CHECK_VC_DIRS_=true
ENV _R_CHECK_VIGNETTES_SKIP_RUN_MAYBE_=true
ENV _R_CHECK_XREFS_USE_ALIASES_FROM_CRAN_=true
## Outputs
ENV _R_CHECK_TESTS_NLINES_=0
ENV _R_CHECK_VIGNETTES_NLINES_=10000
## Timings
ENV _R_CHECK_TIMINGS_=0
ENV _R_CHECK_EXAMPLE_TIMING_CPU_TO_ELAPSED_THRESHOLD_=2.5
ENV _R_CHECK_TEST_TIMING_=yes
ENV _R_CHECK_TEST_TIMING_CPU_TO_ELAPSED_THRESHOLD_=2.5
ENV _R_CHECK_VIGNETTE_TIMING_=yes
ENV _R_CHECK_VIGNETTE_TIMING_CPU_TO_ELAPSED_THRESHOLD_=2.5

## FIXME: remove eventually ...
## _R_CLASS_MATRIX_ARRAY_=${_R_CLASS_MATRIX_ARRAY_-true}
