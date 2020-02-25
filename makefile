ROOT_FS_PATH=/custom-rootfs
ROOT_FS_HOST_PATH=/tmp$(ROOT_FS_PATH)
ROOT_FS_RAW_FILE=rootfs.ext4
DOCKER_IMAGE=ubuntu:dmtcps

ENV_VARS=ROOT_FS_HOST_PATH=$(ROOT_FS_HOST_PATH) ROOT_FS_PATH=$(ROOT_FS_PATH) ROOT_FS_RAW_FILE=$(ROOT_FS_RAW_FILE)

create-rootfs: rootfs-utils.sh
	$(ENV_VARS) ./rootfs-utils.sh create-rootfs

docker-build: Dockerfile
	docker build -t $(DOCKER_IMAGE) -f Dockerfile .

docker-shell:
	sudo mount rootfs.ext4 $(ROOT_FS_HOST_PATH)
	docker run --rm --name dmtcp -v $(ROOT_FS_HOST_PATH):$(ROOT_FS_PATH) -it $(DOCKER_IMAGE) /bin/bash
	sudo umount $(ROOT_FS_HOST_PATH)

docker-create-rootfs:
	docker run --rm --name dmtcp -v $(ROOT_FS_HOST_PATH):$(ROOT_FS_PATH) $(DOCKER_IMAGE) /firecracker/rootfs-utils.sh copy