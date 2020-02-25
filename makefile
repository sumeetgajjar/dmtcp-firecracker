ROOT_FS_PATH=/custom-rootfs
ROOT_FS_HOST_PATH=/tmp$(ROOT_FS_PATH)
ROOT_FS_RAW_FILE=custom-rootfs.ext4
DOCKER_IMAGE=ubuntu:dmtcp

ENV_VARS=ROOT_FS_HOST_PATH=$(ROOT_FS_HOST_PATH) ROOT_FS_PATH=$(ROOT_FS_PATH) ROOT_FS_RAW_FILE=$(ROOT_FS_RAW_FILE)

create-rootfs:
	$(ENV_VARS) ./rootfs-utils.sh create-rootfs

docker-build:
	docker build -t $(DOCKER_IMAGE) -f Dockerfile .

docker-shell:
# 	sudo mount $(ROOT_FS_RAW_FILE) $(ROOT_FS_HOST_PATH)
	docker run --rm --name dmtcp -v $(ROOT_FS_HOST_PATH):$(ROOT_FS_PATH) -e ENV_VARS="$(ENV_VARS)" -it $(DOCKER_IMAGE) /bin/bash
# 	sudo umount $(ROOT_FS_HOST_PATH)

docker-create-rootfs:
	docker run --rm --name dmtcp -v $(ROOT_FS_HOST_PATH):$(ROOT_FS_PATH) -e ENV_VARS="$(ENV_VARS)" -it $(DOCKER_IMAGE) /bin/bash -c "/firecracker/rootfs-utils.sh copy-files-to-rootfs"