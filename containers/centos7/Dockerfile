
FROM centos:7

WORKDIR /root

RUN yum install -y https://dl.fedoraproject.org/pub/archive/epel/7/$(arch)/Packages/e/epel-release-7-14.noarch.rpm || \
    yum install -y https://dl.fedoraproject.org/pub/archive/epel/7/$(arch)/Packages/e/epel-release-7-12.noarch.rpm

# Use vault.centos.org since CentOS 7 is EOL and the official mirrors are no longer available
RUN sed -i -e 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/*

# ------------------------------------------------------------------------------------
# Install pre-built R and requirements

RUN yum install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm

ENV R_VERSIONS="devel next release oldrel/1 oldrel/2 oldrel/3 oldrel/4"

RUN for R_VERSION in $R_VERSIONS; do \
        rig add ${R_VERSION}; \
        rm -rf /tmp/rig; \
      done
RUN rig default release

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
