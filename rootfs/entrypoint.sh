#!/usr/bin/env sh

: ${BUFFER_SIZE}
: ${CACHE_MAX_AGE}
: ${CACHE_MAX_SIZE}
: ${CACHE_MIN_FREE_SPACE}
: ${CACHE_READ_AHEAD:=0}
: ${CACHE_WRITE_BACK}
: ${DIR_CACHE_TIME:=10}
: ${HOME_DIRECTORY}
: ${NFS_PASSWORD}
: ${NFS_ROOT_PASSWORD}
: ${NFS_USERNAME}
: ${ROOT_DIRECTORY}
: ${STARTUP_TIMEOUT}
: ${WEBDAV_ENDPOINT}
: ${WEBDAV_PASSWORD}
: ${WEBDAV_USERNAME}

HOME_DIRECTORY="/${HOME_DIRECTORY#/}"
HOME_DIRECTORY="${HOME_DIRECTORY%/}/"
ROOT_DIRECTORY="/${ROOT_DIRECTORY#/}"
ROOT_DIRECTORY="${ROOT_DIRECTORY%/}/"

# -------------------------------------------------------------------------------
#    Bootstrap rclone services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create rclone-configure environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-configure/environment

    echo "$WEBDAV_USERNAME" > /run/rclone-configure/environment/WEBDAV_USERNAME
    echo "$WEBDAV_ENDPOINT" > /run/rclone-configure/environment/WEBDAV_ENDPOINT
    echo "$WEBDAV_PASSWORD" > /run/rclone-configure/environment/WEBDAV_PASSWORD

    if [ -z "$NFS_ROOT_PASSWORD" ]; then \
        echo "${ROOT_DIRECTORY%/}${HOME_DIRECTORY%/}/${NFS_USERNAME}" > /run/rclone-configure/environment/DIRECTORY
    else
        echo "${ROOT_DIRECTORY}" > /run/rclone-configure/environment/DIRECTORY
    fi

    chmod -R 400 /run/rclone-configure/environment

    # -------------------------------------------------------------------------------
    #    Create rclone-mount environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-mount/environment

    echo "$BUFFER_SIZE"          > /run/rclone-mount/environment/BUFFER_SIZE
    echo "$CACHE_MAX_AGE"        > /run/rclone-mount/environment/CACHE_MAX_AGE
    echo "$CACHE_MAX_SIZE"       > /run/rclone-mount/environment/CACHE_MAX_SIZE
    echo "$CACHE_MIN_FREE_SPACE" > /run/rclone-mount/environment/CACHE_MIN_FREE_SPACE
    echo "$CACHE_READ_AHEAD"     > /run/rclone-mount/environment/CACHE_READ_AHEAD
    echo "$CACHE_WRITE_BACK"     > /run/rclone-mount/environment/CACHE_WRITE_BACK

    chmod -R 400 /run/rclone-mount/environment

    # -------------------------------------------------------------------------------
    #    Create rclone-refresh environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-refresh/environment

    echo "$DIR_CACHE_TIME" > /run/rclone-refresh/environment/DIR_CACHE_TIME

    chmod -R 400 /run/rclone-refresh/environment
}

# -------------------------------------------------------------------------------
#    Create executables
# -------------------------------------------------------------------------------
for BIN in /etc/s6-overlay/s6-rc.d/*/bin/*.sh; do
    ENVIRONMENT=$(echo "$BIN" | sed "s|/etc/s6-overlay/s6-rc\.d/\(.*\)/bin/.*\.sh|/run/\1/environment|")
    SCRIPT=$(echo "$BIN" | sed "s|\(/etc/s6-overlay/s6-rc\.d/.*/\)bin/\(.*\)\.sh|\1\2|")
    SERVICE=$(echo "$BIN" | sed "s|/etc/s6-overlay/s6-rc\.d/\(.*\)/bin/.*\.sh|\1|")

    if [ -f "$SCRIPT" ]; then
        continue
    fi

    if [ -d "$ENVIRONMENT" ]; then
cat << EOF > "$SCRIPT"
#!/usr/bin/execlineb -P
exec s6-envdir "$ENVIRONMENT" "$BIN"
EOF
    else
cat << EOF > "$SCRIPT"
#!/usr/bin/execlineb -P
exec "$BIN"
EOF
    fi
done

# -------------------------------------------------------------------------------
#    Let's go!
# -------------------------------------------------------------------------------
exec env -i \
    PATH="/opt/webdav-nfs/bin:${PATH}" \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( $STARTUP_TIMEOUT * 1000 ))" \
    /init
