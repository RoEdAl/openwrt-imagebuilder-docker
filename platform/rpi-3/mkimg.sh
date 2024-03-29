#!/bin/bash -e

# required .config modification:
#
# CONFIG_TARGET_ROOTFS_PARTSIZE=280
#

#
# BUGS:
# dockerd: failed to start containerd: timeout waiting for containerd to start
#

readonly SCRIPTDIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
 
readonly TARGET=bcm27xx
readonly SUBTARGET=bcm2710
readonly PROFILE=rpi-3
. ${SCRIPTDIR}/../init-vars.sh

declare -r -a PKGS=(
	bcm27xx-userland
	kmod-usb2
	rng-tools
	irqbalance
)

declare -r -a NPKGS=(
	kmod-sound-core kmod-sound-arm-bcm2835
	bcm27xx-gpu-fw
	wpad-basic-wolfssl
	cypress-firmware-43430-sdio cypress-firmware-43455-sdio cypress-nvram-43430-sdio-rpi-3b cypress-nvram-43455-sdio-rpi-3b-plus
	kmod-brcmfmac brcmfmac-firmware-usb kmod-brcmutil
	iw iwinfo
	urandom-seed
)

MERGED_FILES=$(overlay_ro ${SCRIPTDIR}/files ${OPENWRTDIR}/system ${DOCKERDIR}/dockerd ${DOCKERDIR}/pi-hole ${DOCKERDIR}/blocky)
PACKAGES="${IMGPKGS[@]} ${PKGS[@]} ${IMGNPKGS[@]/#/-} ${NPKGS[@]/#/-}"
if make -C ${OPENWRTDIR}/${IMAGEBUILDERDIR} image \
	PROFILE=${PROFILE} \
	PACKAGES="$PACKAGES" \
	FILES=${MERGED_FILES} \
	DISABLED_SERVICES="sysfixtime dockerd" \
	EXTRA_IMAGE_NAME=docker
then
    umount_overlay ${MERGED_FILES}
    gzip -dq ${OPENWRTDIR}/${IMAGEBUILDERDIR}/${IMGDIR}/${IMGFILE_FACTORY}.gz
    mv ${OPENWRTDIR}/${IMAGEBUILDERDIR}/${IMGDIR}/${IMGFILE_FACTORY} ${SCRIPTDIR}
    IMG_SIZE=$(stat --printf="%s" ${SCRIPTDIR}/${IMGFILE_FACTORY})
    NEW_IMG_SIZE_MB=$((64+280+1024))
    truncate -c -s "${NEW_IMG_SIZE_MB}MB" ${SCRIPTDIR}/${IMGFILE_FACTORY}
    LAST_FREE=($(sfdisk -q -F ${SCRIPTDIR}/${IMGFILE_FACTORY} | tail -n 1))
    echo -e "${LAST_FREE[0]}" | sfdisk -q -a ${SCRIPTDIR}/${IMGFILE_FACTORY}
    truncate -c -s ${IMG_SIZE} ${SCRIPTDIR}/${IMGFILE_FACTORY}
	xz -q9 -T0 ${SCRIPTDIR}/${IMGFILE_FACTORY}
    #fallocate -d ${SCRIPTDIR}/${IMGFILE_FACTORY}
    # tar -C ${SCRIPTDIR} --remove-files -Scf ${IMGFILE/%.img/.tar} ${IMGFILE}
else
    umount_overlay ${MERGED_FILES}
    exit 1
fi

