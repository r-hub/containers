FROM registry.access.redhat.com/ubi7/ubi

ARG R_VERSION=release

RUN rm /etc/rhsm-host

# To work around a rig bug and a pak bug
ENV RIG_PLATFORM=rhel-7
ENV PKG_SYSREQS_PLATFORM=redhat-7

# ## Notes
#
# * Need to do this in a single step, so no layer is registered.
#   (Although I am not sure if that would be a real problem.)
# * Need to supply two secrets, for the RedHat Org and the activation key:
#   REDHAT_ORG_RHEL7=... REDHAT_ACTIVATION_KEY_RHEL7=... \
#     docker build --platform linux/amd64 \
#     --secret id=REDHAT_ORG_RHEL7 --secret id=REDHAT_ACTIVATION_KEY_RHEL7 .
# * There is no RHEL7 for linux/arm64, you need to supply `--platform` when
#   building on a non-x86_64 platform.
# * We install a couple of packages that allow installing the tidyverse
#   without registration.
# * You can use rig to install more R versions, but this currently needs
#   registration: https://github.com/r-lib/rig/issues/247

RUN --mount=type=secret,id=REDHAT_ORG_RHEL7 \
    --mount=type=secret,id=REDHAT_ACTIVATION_KEY_RHEL7 \
    subscription-manager register \
        --org `cat /run/secrets/REDHAT_ORG_RHEL7` \
        --activationkey `cat /run/secrets/REDHAT_ACTIVATION_KEY_RHEL7` && \
    yum install -y https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm && \
    yum install -y https://github.com/r-lib/rig/releases/download/latest/r-rig-latest-1.$(arch).rpm && \
    rig add ${R_VERSION} && \
    yum install -y harfbuzz-devel fribidi-devel libtiff-devel && \
    yum clean all && \
    rm -rf /tmp/* && \
    subscription-manager unregister
