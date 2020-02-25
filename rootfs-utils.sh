#!/usr/bin/env bash

set -e 

if [[ ! -z ${ENV_VARS} ]]; then
	for VAR in ${ENV_VARS}; do 
		export $VAR
	done
fi


function allocate_rootfs() {
	if [[ -f ${ROOT_FS_RAW_FILE} ]]; then
		NEW_ROOT_FS_RAW_FILE="$(date | sed 's/\s/-/g')-${ROOT_FS_RAW_FILE}"
		echo "Renaming old rootfs: ${NEW_ROOT_FS_RAW_FILE}"
		mv ${ROOT_FS_RAW_FILE} ${NEW_ROOT_FS_RAW_FILE}
	fi

	dd if=/dev/zero of=${ROOT_FS_RAW_FILE} bs=20M count=50
	mkfs.ext4 ${ROOT_FS_RAW_FILE}
}

function copy_files_to_rootfs() {
	# copy the newly configured system to the rootfs image:
	for dir in bin etc lib root sbin usr; do tar c "/$dir" | tar x -C ${ROOT_FS_PATH}; done
	for dir in dev proc run sys var; do mkdir ${ROOT_FS_PATH}/${dir}; done

	# copy dmtcp
	cp -r /firecracker/dmtcp ${ROOT_FS_PATH}/
}

function mount_custom_root_fs() {
	if mountpoint -q ${ROOT_FS_HOST_PATH} ; then
		echo "Unmounting: ${ROOT_FS_HOST_PATH}"
		sudo umount ${ROOT_FS_HOST_PATH}
	fi
	sudo mount ${ROOT_FS_RAW_FILE} ${ROOT_FS_HOST_PATH}
}

function unmount_custom_root_fs() {
	sudo umount ${ROOT_FS_HOST_PATH}
}

function create_rootfs () {
	mount_custom_root_fs
	make docker-build
	make docker-create-rootfs
	unmount_custom_root_fs
}

while [[ $# -ne 0 ]];
do
   case $1 in
		create-rootfs) create_rootfs ;;
		copy-files-to-rootfs) copy_files_to_rootfs ;;
		allocate-rootfs) allocate_rootfs ;;
		mount) mount_custom_root_fs ;;
		unmount) unmount_custom_root_fs ;;
           *) echo "Invalid option: $1, correct usage is: rootfs-utils.sh [create-rootfs|copy-files-to-rootfs|allocate-rootfs|mount|unmount]";;
   esac
   shift
done
