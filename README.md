# [webdav-nfs-container](https://github.com/nedix/webdav-nfs-container)

Mount a webdav directory as an NFS filesystem to use it as a Docker or Docker Compose volume.

## Usage

### Mount as a Compose volume

The example Compose manifest will start the webdav-nfs service on localhost port `2049`.
It will then make the NFS filesystem available to other services by configuring it as a volume.
The `service_healthy` condition ensures that a connection to a webdav directory has been established before the other service can start using it.
Multiple services can use the same volume.

#### 1. Create the Compose manifest

```shell
wget -q https://raw.githubusercontent.com/nedix/webdav-nfs-container/main/docs/examples/compose.yml
```

#### 2. Start the services

```shell
docker compose up -d
```

#### 3. Browse the webdav directory from inside an example service

```shell
docker compose exec example-service ls /data
```

### Mount as a local directory

These commands mount the webdav directory to a local directory named `webdav-nfs`.

#### 1. Start the server

This command starts the NFS server on localhost port `2049`.

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

#### 2. Create a directory for the mount

```shell
mkdir webdav-nfs
```

#### 3. Mount the filesystem

```shell
mount -v -o vers=4 -o port=2049 127.0.0.1:/ ./webdav-nfs
```

<hr>

## Attribution

Powered by [rclone].

[rclone]: https://github.com/rclone/rclone
