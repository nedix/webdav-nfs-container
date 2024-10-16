# [webdav-nfs-container](https://github.com/nedix/webdav-nfs-container)

Mount a webdav directory as an NFS filesystem to use it as a Docker or Docker Compose volume.

## Usage

#### (Option 1.) Mount on a path outside the container

This command starts an NFS server on localhost port `2049`.

```shell
docker run --pull always --name webdav-nfs \
    --cap-add SYS_ADMIN --device /dev/fuse \ # fuse priviliges, these might not be necessary in the future
    -p 2049:2049 \
    -e WEBDAV_ENDPOINT=foo \
    -e WEBDAV_USERNAME=bar \
    -e WEBDAV_PASSWORD=baz \
    -d \
    --restart unless-stopped \
    nedix/webdav-nfs
```

This command mounts the NFS filesystem on a directory named `webdav-nfs`.

```shell
mkdir webdav-nfs \
&& mount -v -o vers=4 -o port=2049 127.0.0.1:/ ./webdav-nfs
```

#### (Option 2.) Use as a Docker Compose volume

The example Compose manifest will start the webdav-nfs service on localhost port `2049`.
It will then make the NFS filesystem available to other services by configuring it as a volume.
The `service_healthy` condition ensures that a connection to a webdav directory has been established before the other service can start using it.
Multiple services can use the same volume.

```shell
wget -q https://raw.githubusercontent.com/nedix/webdav-nfs-container/refs/heads/main/docs/examples/compose.yml
docker compose up -d
docker compose exec example-service ls /data
```

<hr>

## Attribution

Powered by [rclone].

[rclone]: https://github.com/rclone/rclone
