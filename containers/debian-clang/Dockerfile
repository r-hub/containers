
FROM debian:trixie
COPY --from=common common.Renviron /root/.Renviron

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements
# rig also sets up the CRAN mirror, we don't install pak, because rig
# installs it into the user lib, and we want it in the system lib.
# R-devel builds are not published on P3M/RSPM, so --without-rspm is needed.

RUN export DEBIAN_FRONTEND=noninteractive && \
    ARCH="$(arch)"; \
    if [ "$ARCH" = "aarch64" ]; then ARM64="-arm64"; else ARM64=""; fi; \
    apt-get update -y && \
    apt-get install -y curl && \
    curl -Ls https://github.com/r-lib/rig/releases/download/latest/rig-linux${ARM64}-latest.tar.gz | tar xz -C /usr/local && \
    rig add devel --without-pak --without-rspm && \
    rm -rf /tmp/rig && \
    apt-get clean

# System requirements that pak does not know about
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y patch && \
    apt-get clean

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel/bin/R -q -e \
    'install.packages("pak", lib = .Library, repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale, matches CRAN's debian-clang flavor
# https://cran.r-project.org/web/checks/check_flavors.html

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen C.UTF-8 && \
    update-locale
ENV LC_ALL C.UTF-8
ENV LC_COLLATE C
ENV LANG C.UTF-8

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
    apt-get install -y pkg-config perl qpdf git tidy && \
    apt-get clean

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# ------------------------------------------------------------------------------------
# clang 23, flang 23

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y gpg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl https://apt.llvm.org/llvm-snapshot.gpg.key | \
      gpg --dearmor -o /etc/apt/keyrings/apt.llvm.org.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/apt.llvm.org.gpg] http://apt.llvm.org/trixie/ llvm-toolchain-trixie-23 main" | \
  tee -a /etc/apt/sources.list.d/llvm.list

RUN apt-get update -y && \
    apt-get install -y clang-23 libc++abi-23-dev libc++-23-dev libomp-23-dev flang-23 && \
    apt-get clean

RUN mkdir -p /root/.R
COPY Makevars /root/.R
# we need to set this, because GHA changes $HOME:
# https://github.com/actions/runner/issues/863
ENV R_MAKEVARS_USER=/root/.R/Makevars

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

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'
