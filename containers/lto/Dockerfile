
FROM ghcr.io/r-hub/containers/ubuntu-release:latest
COPY --from=common common.Renviron /root/.Renviron

RUN makeconf="/opt/R/release/lib/R/etc/Makeconf"; \
    sed -i -E '/^LTO ?=/ s/$/ '"-flto"/ "${makeconf}" && \
    sed -i -E '/^LTO_FC ?=/ s/$/ '"-flto"/ "${makeconf}" && \
    sed -i -E '/^LTO_OPT ?=/ s/$/ '"-flto"/ "${makeconf}" && \
    sed -i -E '/^LTO_FC_OPT ?=/ s/$/ '"-flto"/ "${makeconf}"
