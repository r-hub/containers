
FROM fedora:38

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN dnf -y upgrade && \
    dnf -y install dnf-plugins-core && \
    dnf -y install curl && \
    . /etc/os-release && \
    curl -LO "https://github.com/r-hub/containers/releases/download/latest/R-rstudio-${ID}-${VERSION_ID}-devel-valgrind-1-1.$(arch).rpm" && \
    yum install -y R-*.rpm && \
    rm R-*.rpm

# Extra system packages that pak does not know about
RUN dnf install -y awk && \
    dnf install -y https://rpms.r-pkg.org/fedora-38/jags-4.3.2-1.$(arch).rpm

# ------------------------------------------------------------------------------------
# Put R on PATH
# AUto-install system requirements

ENV PATH="/opt/R/devel-valgrind/bin:${PATH}"
ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, no P3M for Fedora

RUN echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
    >> /opt/R/devel-valgrind/lib/R/library/base/R/Rprofile

RUN if [ "`arch`" = "x86_64" ]; then \
        echo "Setting up R-hub repo"; \
        . /etc/os-release; \
        RVER=$(R -s -e 'cat(paste(getRversion()[,1:2]))'); \
        echo "options(repos = c(RHUB = 'https://raw.githubusercontent.com/r-hub/repos/main/${ID}-${VERSION_ID}/${RVER}', getOption('repos')))" \
            >> /opt/R/devel-valgrind/lib/R/library/base/R/Rprofile; \
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' \
            >> /opt/R/devel-valgrind/lib/R/library/base/R/Rprofile; \
    fi

# ------------------------------------------------------------------------------------
# Install pak

RUN /opt/R/devel-valgrind/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'

# ------------------------------------------------------------------------------------
# Locale

RUN dnf install -y glibc-langpack-en

ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN /opt/R/devel-valgrind/bin/R -q -e 'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Useful system packages

RUN dnf -y install pkg-config devscripts-checkbashisms qpdf tidy valgrind git

# ------------------------------------------------------------------------------------
# valgrind config

COPY valgrind.supp .
RUN cat valgrind.supp >> /usr/libexec/valgrind/default.supp && \
    rm valgrind.supp
ENV VALGRIND_OPTS="--track-origins=yes --leak-check=full"

# ------------------------------------------------------------------------------------
# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'

# ------------------------------------------------------------------------------------
# Check config

ENV RJAVA_JVM_STACK_WORKAROUND 0
ENV R_DONT_USE_TK true

ENV OMP_THREAD_LIMIT=2
ENV R_DATATABLE_NUM_THREADS=2

# ------------------------------------------------------------------------------------
# Check config, only runtime checks

ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--use-valgrind --extra-arch --no-stop-on-test-error"
