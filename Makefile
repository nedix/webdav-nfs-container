setup:
	@docker build --progress=plain -f Containerfile -t webdav-nfs .

up: NFS_PORT=2049
up: RCLONE_PORT=5572
up:
	@docker run --rm --name webdav-nfs \
		--cap-add NET_ADMIN \
		--cap-add SYS_ADMIN \
		--device /dev/fuse \
        --env-file .env \
        -p 127.0.0.1:$(NFS_PORT):2049 \
        -p 127.0.0.1:$(RCLONE_PORT):5572 \
        -v /sys/fs/cgroup/webdav-nfs:/sys/fs/cgroup:rw \
        webdav-nfs

down:
	-@docker stop webdav-nfs

shell:
	@docker exec -it webdav-nfs /bin/sh
