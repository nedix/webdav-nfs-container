setup:
	@test -e .env || cp .env.example .env
	@docker build --progress=plain -f Containerfile -t webdav-nfs .

destroy:
	-@docker rm -fv webdav-nfs

up: NFS_PORT    = "2049"
up: RCLONE_PORT = "5572"
up:
	@docker run --rm -d --name webdav-nfs \
		--cap-add SYS_ADMIN \
		--device /dev/fuse \
        --env-file .env \
        -p 127.0.0.1:$(NFS_PORT):2049 \
        -p 127.0.0.1:$(RCLONE_PORT):5572 \
        webdav-nfs
	@docker logs -f webdav-nfs

down:
	-@docker stop webdav-nfs

shell:
	@docker exec -it webdav-nfs /bin/sh

test:
	@$(CURDIR)/tests/index.sh
