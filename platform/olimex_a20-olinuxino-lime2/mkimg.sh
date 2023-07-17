#!/bin/bash -e

# required .config modification:
#
# CONFIG_TARGET_ROOTFS_PARTSIZE=280
#

readonly SCRIPTDIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")

readonly TARGET=sunxi
readonly SUBTARGET=cortexa7
readonly PROFILE=olimex_a20-olinuxino-lime2
. ${SCRIPTDIR}/../init-vars.sh

MERGED_FILES=$(overlay_ro ${SCRIPTDIR}/files ${OPENWRTDIR}/system ${DOCKERDIR}/dockerd ${DOCKERDIR}/pi-hole ${DOCKERDIR}/blocky)
PACKAGES="${IMGPKGS[@]} ${IMGNPKGS[@]/#/-}"
if make -C ${OPENWRTDIR}/${IMAGEBUILDERDIR} image \
	PROFILE=${PROFILE} \
	PACKAGES="$PACKAGES" \
	FILES=${MERGED_FILES} \
	DISABLED_SERVICES="sysfixtime dockerd" \
	EXTRA_IMAGE_NAME=docker
then
    umount_overlay ${MERGED_FILES}
    gzip -dq ${OPENWRTDIR}/${IMAGEBUILDERDIR}/${IMGDIR}/${IMGFILE}.gz
    mv ${OPENWRTDIR}/${IMAGEBUILDERDIR}/${IMGDIR}/${IMGFILE} ${SCRIPTDIR}
    IMG_SIZE=$(stat --printf="%s" ${SCRIPTDIR}/${IMGFILE})
    NEW_IMG_SIZE_MB=$((20+280+1024))
    truncate -c -s "${NEW_IMG_SIZE_MB}MB" ${SCRIPTDIR}/${IMGFILE}
    LAST_FREE=($(sfdisk -q -F ${SCRIPTDIR}/${IMGFILE} | tail -n 1))
    echo -e "${LAST_FREE[0]}" | sfdisk -q -a ${SCRIPTDIR}/${IMGFILE}
    truncate -c -s ${IMG_SIZE} ${SCRIPTDIR}/${IMGFILE}
    xz -q9 -T0 ${SCRIPTDIR}/${IMGFILE}
    # fallocate -d ${SCRIPTDIR}/${IMGFILE}
    # tar -C ${SCRIPTDIR} --remove-files -Scf ${IMGFILE/%.img/.tar} ${IMGFILE}
else
    umount_overlay ${MERGED_FILES}
    exit 1
fi

