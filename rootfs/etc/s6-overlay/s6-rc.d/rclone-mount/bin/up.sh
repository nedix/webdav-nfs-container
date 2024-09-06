#!/usr/bin/env sh

: ${BUFFER_SIZE}
: ${CACHE_MAX_AGE}
: ${CACHE_MAX_SIZE}
: ${CACHE_MIN_FREE_SPACE}
: ${CACHE_READ_AHEAD}
: ${CACHE_WRITE_BACK}
: ${CHECK_FIRST}
: ${ORDER_BY}

s6-sleep 1

main_options() {
cat <<EOF
{
    $([ -z "$BUFFER_SIZE" ] || echo "\"BufferSize\": $(( $BUFFER_SIZE * 1048576 )),")
    $([ -z "$CHECK_FIRST" ] || echo "\"CheckFirst\": true,")
    $([ -z "$ORDER_BY" ] || echo "\"OrderBy\": \"$ORDER_BY\",")
    "CheckSum": true,
    "DeleteMode": 1,
    "DisableHTTP2": true,
    "IgnoreSize": true,
    "LowLevelRetries": 2,
    "MultiThreadStreams": 0,
    "NoAppleDouble": true,
    "NoAppleXattr": true,
    "Retries": 10,
    "RetriesInterval": 1000000000,
    "ServerSideAcrossConfigs": true,
    "StreamingUploadCutoff": 0,
    "Timeout": 0,
    "TrackRenames": true,
    "UseMmap": true
}
EOF
}

mount_options() {
cat <<EOF
{
    "AllowOther": true,
    "WritebackCache": true
}
EOF
}

vfs_options() {
cat <<EOF
{
    $([ -z "$CACHE_MAX_AGE" ] || echo "\"CacheMaxAge\": $(( $CACHE_MAX_AGE * 1000000000 )),")
    $([ -z "$CACHE_MAX_SIZE" ] || echo "\"CacheMaxSize\": $(( $CACHE_MAX_SIZE * 1048576 )),")
    $([ -z "$CACHE_MIN_FREE_SPACE" ] || echo "\"CacheMinFreeSpace\": $(( $CACHE_MIN_FREE_SPACE * 1048576 )),")
    $([ -z "$CACHE_READ_AHEAD" ] || echo "\"ReadAhead\": $(( $CACHE_READ_AHEAD * 1048576 )),")
    $([ -z "$CACHE_WRITE_BACK" ] || echo "\"WriteBack\": $(( $CACHE_WRITE_BACK * 1000000000 )),")
    "CacheMode": "full",
    "CachePollInterval": 5000000000,
    "ChunkSize": 0,
    "DirCacheTime": 86400000000000,
    "UsedIsSize": true
}
EOF
}

/usr/bin/rclone rc \
    options/set \
    --json "{\"main\": $(main_options), \"mount\": $(mount_options), \"vfs\": $(vfs_options)}"

/usr/bin/rclone rc \
    mount/mount \
    fs=remote: \
    mountPoint=/mnt/rclone \
    mountOpt="$(mount_options)" \
    vfsOpt="$(vfs_options)"
