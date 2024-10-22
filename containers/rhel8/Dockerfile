FROM redhat/ubi8:latest

ARG R_VERSION=release

# To work around a rig bug and a pak bug
ENV RIG_PLATFORM=rhel-8
ENV PKG_SYSREQS_PLATFORM=redhat-8
ENV LANG=en_US.UTF-8

# ## Notes
#
# * Need to do this in a single step, so no layer is registered.
#   (Although I am not sure if that would be a real problem.)
# * Need to supply two secrets, for the RedHat Org and the activation key:
#   REDHAT_ORG_RHEL8=... REDHAT_ACTIVATION_KEY_RHEL8=... \
#     docker build --secret id=REDHAT_ORG_RHEL8 \
#     --secret id=REDHAT_ACTIVATION_KEY_RHEL8 .
# * We install a couple of packages that allow installing the tidyverse
#   without registration.
# * You can use rig to install more R versions, but this currently needs
#   registration: https://github.com/r-lib/rig/issues/247

RUN --mount=type=secret,id=REDHAT_ORG_RHEL8 \
    --mount=type=secret,id=REDHAT_ACTIVATION_KEY_RHEL8 \
    subscription-manager register \
        --org `cat /run/secrets/REDHAT_ORG_RHEL8` \
        --activationkey `cat /run/secrets/REDHAT_ACTIVATION_KEY_RHEL8` && \
    yum install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm && \
    rig add ${R_VERSION} && \
    yum install -y harfbuzz-devel fribidi-devel glibc-langpack-en diffutils perl && \
    yum clean all && \
    rm -rf /tmp/* && \
    subscription-manager unregister

# For R CMD check

RUN curl -o /usr/local/bin/checkbashisms \
    https://raw.githubusercontent.com/r-hub/containers/main/dependencies/checkbashisms/checkbashisms && \
    chmod +x /usr/local/bin/checkbashisms
