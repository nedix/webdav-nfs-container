# [webdav-nfs-container][project]

Mount a webdav directory as an NFS filesystem to use it as a Docker or Docker Compose volume.


## Usage as a Compose volume

The example Compose manifest will start the webdav-nfs container on localhost port `2049`.
It will then make the NFS filesystem available to other services by configuring it as a volume.
The `service_healthy` condition ensures that a connection to a webdav directory has been established before the other service can start using it.
Multiple services can use the same volume.


### 1. Create the Compose manifest

```shell
wget https://raw.githubusercontent.com/nedix/webdav-nfs-container/main/docs/examples/compose.yml
```


### 2. Start the container

```shell
docker compose up -d
```


### 3. Browse the webdav contents from within the example container

```shell
docker compose exec example-container ls /data
```


## Usage as a mounted directory

The following example will mount the remote webdav directory to a local directory named `webdav-nfs`.


### 1. Start the container

```shell
docker run --rm --pull always --name webdav-nfs \
    --cap-add SYS_ADMIN --device /dev/fuse \
    -p 127.0.0.1:2049:2049 \
    -e WEBDAV_ENDPOINT=foo \
    -e WEBDAV_USERNAME=bar \
    -e WEBDAV_PASSWORD=baz \
    --restart unless-stopped \
    nedix/webdav-nfs
```


### 2. Create a target directory

```shell
mkdir webdav-nfs
```


### 3. Mount the directory

```shell
mount -v -o vers=4 -o port=2049 127.0.0.1:/ ./webdav-nfs
```


[project]: https://hub.docker.com/r/nedix/webdav-nfs
