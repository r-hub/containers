
FROM centos:7

WORKDIR /root

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

ENV R_VERSIONS="devel next 4.2.2 4.1.3 4.0.5 3.6.3 3.5.3"

RUN ARCH="$(arch)"; \
    if [ "$ARCH" = "x86_64" ]; then \
      for R_VERSION in $R_VERSIONS; do \
        curl -Os https://cdn.posit.co/r/centos-7/pkgs/R-${R_VERSION}-1-1.x86_64.rpm; \
        yum install -y R-${R_VERSION}-1-1.x86_64.rpm; \
        rm R-${R_VERSION}-1-1.x86_64.rpm; \
      done; \
    fi

RUN ARCH="$(arch)"; \
    if [ "$ARCH" = "aarch64" ]; then \
      for R_VERSION in $R_VERSIONS; do \
        curl -OLs https://github.com/r-hub/R/releases/download/v${R_VERSION}/r-rstudio-centos-7-${R_VERSION}-1-1.aarch64.rpm; \
        yum install -y r-rstudio-*.rpm; \
        rm r-rstudio-*.rpm; \
      done; \
    fi

# ------------------------------------------------------------------------------------
# Auto-install system requirements

ENV PKG_SYSREQS=true
ENV R_PKG_SYSREQS2=true

# ------------------------------------------------------------------------------------
# Set CRAN repo, no P3M for CentOS

RUN for R_VERSION in $R_VERSIONS; do \
      echo 'options(repos =c(CRAN = "https://cran.rstudio.com"))' \
      >> /opt/R/${R_VERSION}/lib/R/library/base/R/Rprofile; \
    done

# ------------------------------------------------------------------------------------
# Locale

RUN sed -i 's/^override_install_langs/# override_install_langs/' /etc/yum.conf
RUN yum -y -q reinstall glibc-common
ENV LANG en_US.UTF-8

# ------------------------------------------------------------------------------------
# Install pak

RUN for R_VERSION in $R_VERSIONS; do \
    /opt/R/${R_VERSION}/bin/R -q -e \
      'install.packages("pak", repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s", "devel", .Platform$pkgType, R.Version()$os, R.Version()$arch))'; \
    done

# ------------------------------------------------------------------------------------
# Use user's package library for the rest

RUN for R_VERSION in $R_VERSIONS; do \
      /opt/R/${R_VERSION}/bin/R -q -e \
        'dir.create(Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)'; \
    done

# ------------------------------------------------------------------------------------
# Copy check script

COPY r-check /usr/local/bin

# ------------------------------------------------------------------------------------
# Install rig, set default R version

RUN ARCH="$(arch)"; \
    if [ "$ARCH" = "aarch64" ]; then ARM64="-arm64"; else ARM64=""; fi; \
    curl -Ls https://github.com/r-lib/rig/releases/download/latest/rig-linux${ARM64}-latest.tar.gz | tar xz -C /usr/local && \
    rig default next

# ------------------------------------------------------------------------------------
# Check config, no need to check the PDF manual and vignettes here.
# We also avoid that bashism checks, as it needs external tools.

ENV _R_CHECK_TESTS_NLINES_="0"
ENV CHECK_ARGS="--no-manual --no-build-vignettes"
ENV _R_CHECK_BASHISMS_=false
