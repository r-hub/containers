FROM redhat/ubi9:latest

ARG R_VERSION=release

# To work around a rig bug and a pak bug
ENV RIG_PLATFORM=rhel-9
ENV PKG_SYSREQS_PLATFORM=redhat-9
ENV LANG=en_US.UTF-8
ENV TZ=UTC

# ## Notes
#
# * Need to do this in a single step, so no layer is registered.
#   (Although I am not sure if that would be a real problem.)
# * Need to supply two secrets, for the RedHat Org and the activation key:
#   REDHAT_ORG_RHEL9=... REDHAT_ACTIVATION_KEY_RHEL9=... \
#     docker build --secret id=REDHAT_ORG_RHEL9 \
#     --secret id=REDHAT_ACTIVATION_KEY_RHEL9 .
# * We install a couple of packages that allow installing the tidyverse
#   without registration.
# * You can use rig to install more R versions, but this currently needs
#   registration: https://github.com/r-lib/rig/issues/247
# * The sed line fixes this bug: https://github.com/r-lib/rig/issues/248

RUN --mount=type=secret,id=REDHAT_ORG_RHEL9 \
    --mount=type=secret,id=REDHAT_ACTIVATION_KEY_RHEL9 \
    subscription-manager register \
        --org `cat /run/secrets/REDHAT_ORG_RHEL9` \
        --activationkey `cat /run/secrets/REDHAT_ACTIVATION_KEY_RHEL9` && \
    yum install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm && \
    rig add ${R_VERSION} && \
    sed -i 's|/rhel8/|/rhel9/|g' /opt/R/current/lib/R/library/base/R/Rprofile && \
    yum install -y --allowerasing fribidi-devel glibc-langpack-en diffutils perl libcurl && \
    yum clean all && \
    rm -rf /tmp/* && \
    subscription-manager unregister

# For R CMD check

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms

# Very minimal test
RUN R -e 'for (p in getOption("defaultPackages")) { library(p, character.only=TRUE) }'
