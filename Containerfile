ARG ALPINE_VERSION=3.21
ARG RCLONE_VERSION=1.69.0
ARG RCLONE_WEBUI_VERSION=2.0.5
ARG S6_OVERLAY_VERSION=3.2.0.0
ARG STARTUP_TIMEOUT=30

FROM alpine:${ALPINE_VERSION} AS base

ARG S6_OVERLAY_VERSION

RUN apk add --virtual .build-deps \
        xz \
    && case "$(uname -m)" in \
        aarch64|arm*) \
            CPU_ARCHITECTURE="aarch64" \
        ;; x86_64) \
            CPU_ARCHITECTURE="x86_64" \
        ;; *) echo "Unsupported architecture: $(uname -m)"; exit 1; ;; \
    esac \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
    | tar -xpJf- -C / \
    && wget -qO- "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${CPU_ARCHITECTURE}.tar.xz" \
    | tar -xpJf- -C / \
    && apk del .build-deps

FROM rclone/rclone:${RCLONE_VERSION} AS rclone

FROM base AS rclone-webui

ARG RCLONE_WEBUI_VERSION

WORKDIR /build/rclone-webui

RUN wget -qO- "https://github.com/rclone/rclone-webui-react/releases/download/v${RCLONE_WEBUI_VERSION}/currentbuild.zip" \
    | unzip - \
    && mkdir -p /var/rclone/webgui \
    && mv -T build /var/rclone/webgui

FROM base

ARG STARTUP_TIMEOUT

RUN apk add \
        fuse3 \
        nfs-utils

COPY --link --from=rclone /usr/local/bin/rclone /usr/bin/
COPY --link --from=rclone-webui /var/rclone/webgui/ /var/rclone/webgui/

COPY /rootfs/ /

ENV STARTUP_TIMEOUT="$STARTUP_TIMEOUT"

ENTRYPOINT ["/entrypoint.sh"]

# NFS
EXPOSE 2049

# Rclone
EXPOSE 5572/tcp

VOLUME /var/rclone

HEALTHCHECK \
    --start-period=15s \
    CMD nc -z 127.0.0.1 2049
