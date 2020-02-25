#!/usr/bin/env bash

set -e 

function copy_files_to_rootfs() {
	# copy the newly configured system to the rootfs image:
	for dir in bin etc lib root sbin usr; do tar c "/$dir" | tar x -C ${ROOT_FS_PATH}; done
	for dir in dev proc run sys var; do mkdir ${ROOT_FS_PATH}/${dir}; done
}

function allocate_rootfs() {
	if [[ -f ${ROOT_FS_RAW_FILE} ]]; then
		echo "Moving old rootfs"
		NEW_FILE_NAME="$(date | sed 's/\s/-/g')-${ROOT_FS_RAW_FILE}"
		mv ${ROOT_FS_RAW_FILE} ${NEW_FILE_NAME}
	fi

	dd if=/dev/zero of=${ROOT_FS_RAW_FILE} bs=20M count=50
	mkfs.ext4 ${ROOT_FS_RAW_FILE}
}

function mount_custom_rootfs() {
	sudo mount ${ROOT_FS_RAW_FILE} ${ROOT_FS_HOST_PATH}
}

function create-rootfs () {
	allocate_rootfs
}

while [[ $# -ne 0 ]];
do
   case $1 in
        copy) copy_files_to_rootfs ;;
		create-rootfs) create-rootfs ;;
           *) echo "Invalid option: $1, correct usage is: rootfs-utils.sh [copy]";;
   esac
   shift
done
