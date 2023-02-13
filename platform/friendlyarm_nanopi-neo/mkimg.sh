#!/bin/bash -e

# required .config modification:
#
# CONFIG_TARGET_ROOTFS_PARTSIZE=280
#

readonly SCRIPTDIR=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")

readonly TARGET=sunxi
readonly SUBTARGET=cortexa7
readonly PROFILE=friendlyarm_nanopi-neo
. ${SCRIPTDIR}/../init-vars.sh

PKGS=(
	kmod-nf-conntrack-netlink
	kmod-ledtrig-activity
	nano
	usbutils
	htop iftop iperf3
	shadow-useradd shadow-usermod shadow-chpasswd
	shadow-groupadd shadow-groupmod
	sudo
	docker dockerd docker-compose
	kmod-fs-vfat kmod-nls-cp852 dosfstools
	kmod-fs-f2fs f2fs-tools
	block-mount
	kmod-usb-storage
	lsblk fdisk sfdisk
	irqbalance losetup
)

NPKGS=(
	ppp
	ppp-mod-pppoe
	luci lua
	dnsmasq
	odhcp6c
	odhcpd-ipv6only
)

MERGED_FILES=$(overlay_ro ${SCRIPTDIR}/files ${OPENWRTDIR}/system ${DOCKERDIR}/dockerd ${DOCKERDIR}/pi-hole ${DOCKERDIR}/blocky)
PACKAGES="${PKGS[@]} ${NPKGS[@]/#/-}"
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
    NEW_IMG_SIZE_MB=$((20+280+512))
    truncate -c -s "${NEW_IMG_SIZE_MB}MB" ${SCRIPTDIR}/${IMGFILE}
    LAST_FREE=($(sfdisk -q -F ${SCRIPTDIR}/${IMGFILE} | tail -n 1))
    echo -e "${LAST_FREE[0]}" | sfdisk -q -a ${SCRIPTDIR}/${IMGFILE}
    truncate -c -s ${IMG_SIZE} ${SCRIPTDIR}/${IMGFILE}
    # fallocate -d ${SCRIPTDIR}/${IMGFILE}
    # tar -C ${SCRIPTDIR} --remove-files -Scf ${IMGFILE/%.img/.tar} ${IMGFILE}
else
    umount_overlay ${MERGED_FILES}
    exit 1
fi

