#!/usr/bin/env sh

setsid /usr/bin/rclone rcd \
    --config=/etc/rclone/rclone.conf \
    --rc-addr=:5572 \
    --rc-allow-origin="*" \
    --rc-files=/var/rclone/webgui \
    --rc-no-auth \
    --rc-web-gui-no-open-browser
