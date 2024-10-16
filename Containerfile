ARG ALPINE_VERSION=3.20
ARG RCLONE_VERSION=1.67.0
ARG RCLONE_WEBUI_VERSION=2.0.5
ARG STARTUP_TIMEOUT=30

FROM rclone/rclone:${RCLONE_VERSION} AS rclone

FROM alpine:${ALPINE_VERSION} AS rclone-webui

ARG RCLONE_WEBUI_VERSION

WORKDIR /build/rclone-webui

RUN wget -qO- "https://github.com/rclone/rclone-webui-react/releases/download/v${RCLONE_WEBUI_VERSION}/currentbuild.zip" \
    | unzip - \
    && mkdir -p /var/rclone/webgui \
    && mv -T build /var/rclone/webgui

FROM alpine:${ALPINE_VERSION}

ARG STARTUP_TIMEOUT

RUN apk add \
        fuse3 \
        iptables \
        nfs-utils \
        nftables \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add \
        s6-overlay \
        skalibs-dev

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
