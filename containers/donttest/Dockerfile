
FROM ubuntu:22.04

COPY rig.gpg /etc/apt/trusted.gpg.d/rig.gpg
RUN echo "deb http://rig.r-pkg.org/deb rig main" > \
    /etc/apt/sources.list.d/rig.list
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y r-rig && \
    rig add devel --without-pak

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
# Install pak into system library

RUN /opt/R/devel/bin/R -q -e \
    'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch), lib = .Library)'

# ------------------------------------------------------------------------------------
# Locale

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y locales && \
    apt-get clean && \
    locale-gen en_US.UTF-8 en_US.UTF-8 && \
    update-locale
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Useful system packages, some are needed for R CMD check

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y pkg-config perl tidy qpdf curl && \
    apt-get clean

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# ------------------------------------------------------------------------------------
# Check config

ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--no-manual --no-build-vignettes"

ENV _R_CHECK_DONTTEST_EXAMPLES_=true
ENV _R_CHECK_THINGS_IN_OTHER_DIRS_=true

ENV _R_CHECK_THINGS_IN_OTHER_DIRS_EXCLUDE_=/opt/R/devel/lib/R/etc/exclude
RUN curl -L https://raw.githubusercontent.com/r-devel/r-dev-web/345a85338c9ecb31c6ea6a25e688833e232185aa/CRAN/QA/BDR/blackswan/exclude \
    -o /opt/R/devel/lib/R/etc/exclude
