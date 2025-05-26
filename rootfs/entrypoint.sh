#!/usr/bin/env sh

: ${BUFFER_SIZE}
: ${CACHE_MAX_AGE}
: ${CACHE_MAX_SIZE}
: ${CACHE_MIN_FREE_SPACE}
: ${CACHE_READ_AHEAD:=0}
: ${CACHE_WRITE_BACK}
: ${DIR_CACHE_TIME:=10}
: ${NFS_PASSWORD_HASH}
: ${NFS_USERNAME}
: ${STARTUP_TIMEOUT}
: ${WEBDAV_DIRECTORY}
: ${WEBDAV_ENDPOINT}
: ${WEBDAV_PASSWORD}
: ${WEBDAV_USERNAME}

WEBDAV_DIRECTORY="/${WEBDAV_DIRECTORY#/}"
WEBDAV_DIRECTORY="${WEBDAV_DIRECTORY%/}/"

# -------------------------------------------------------------------------------
#    Bootstrap rclone services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create rclone-configure environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-configure/environment

    echo "$WEBDAV_DIRECTORY" > /run/rclone-configure/environment/WEBDAV_DIRECTORY
    echo "$WEBDAV_ENDPOINT"  > /run/rclone-configure/environment/WEBDAV_ENDPOINT
    echo "$WEBDAV_PASSWORD"  > /run/rclone-configure/environment/WEBDAV_PASSWORD
    echo "$WEBDAV_USERNAME"  > /run/rclone-configure/environment/WEBDAV_USERNAME

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

    # -------------------------------------------------------------------------------
    #    Create rclone-refresh environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/rclone-refresh/environment

    echo "$DIR_CACHE_TIME" > /run/rclone-refresh/environment/DIR_CACHE_TIME
}

# -------------------------------------------------------------------------------
#    Bootstrap nfs services
# -------------------------------------------------------------------------------
{
    # -------------------------------------------------------------------------------
    #    Create nfs-configure environment
    # -------------------------------------------------------------------------------
    mkdir -p /run/nfs-configure/environment

    echo "$NFS_PASSWORD_HASH" > /run/nfs-configure/environment/NFS_PASSWORD_HASH
    echo "$NFS_USERNAME"      > /run/nfs-configure/environment/NFS_USERNAME
}

# -------------------------------------------------------------------------------
#    Let's go!
# -------------------------------------------------------------------------------
exec env -i \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME="$(( $STARTUP_TIMEOUT * 1000 ))" \
    S6_STAGE2_HOOK="/usr/sbin/s6-stage2-hook" \
    /init
