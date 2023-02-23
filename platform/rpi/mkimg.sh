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
readonly SUBTARGET=bcm2708
readonly PROFILE=rpi
. ${SCRIPTDIR}/../init-vars.sh

PKGS=(
	bcm27xx-userland
	kmod-i2c-bcm2835
	kmod-rtc-ds1307
	kmod-usb2
	kmod-usb-net-rtl8152 kmod-usb-net-asix
	kmod-nf-conntrack-netlink
	kmod-ledtrig-activity
	nano
	usbutils
	htop iftop iperf3
        kmod-fs-vfat kmod-nls-cp852 dosfstools
	kmod-fs-f2fs f2fs-tools
	block-mount
	kmod-usb-storage
	lsblk fdisk sfdisk losetup
	shadow-useradd shadow-usermod shadow-chpasswd
	shadow-groupadd shadow-groupmod
	sudo
	iptables-nft ip6tables-nft
	docker docker-compose dockerd
	rng-tools
	libcap-bin
)

NPKGS=(
	kmod-sound-core kmod-sound-arm-bcm2835
	bcm27xx-gpu-fw
	ppp
	ppp-mod-pppoe
	luci lua
	dnsmasq
	odhcp6c
	odhcpd-ipv6only
	wpad-basic-wolfssl
	cypress-firmware-43430-sdio cypress-nvram-43430-sdio-rpi-zero-w
	kmod-brcmfmac brcmfmac-firmware-usb kmod-brcmutil
	iw iwinfo
	urandom-seed
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
    gzip -dq ${OPENWRTDIR}/${IMAGEBUILDERDIR}/${IMGDIR}/${IMGFILE_FACTORY}.gz
    mv ${OPENWRTDIR}/${IMAGEBUILDERDIR}/${IMGDIR}/${IMGFILE_FACTORY} ${SCRIPTDIR}
    IMG_SIZE=$(stat --printf="%s" ${SCRIPTDIR}/${IMGFILE_FACTORY})
    NEW_IMG_SIZE_MB=$((64+280+512))
    truncate -c -s "${NEW_IMG_SIZE_MB}MB" ${SCRIPTDIR}/${IMGFILE_FACTORY}
    LAST_FREE=($(sfdisk -q -F ${SCRIPTDIR}/${IMGFILE_FACTORY} | tail -n 1))
    echo -e "${LAST_FREE[0]}" | sfdisk -q -a ${SCRIPTDIR}/${IMGFILE_FACTORY}
    truncate -c -s ${IMG_SIZE} ${SCRIPTDIR}/${IMGFILE_FACTORY}
    #fallocate -d ${SCRIPTDIR}/${IMGFILE_FACTORY}
    # tar -C ${SCRIPTDIR} --remove-files -Scf ${IMGFILE/%.img/.tar} ${IMGFILE}
else
    umount_overlay ${MERGED_FILES}
    exit 1
fi

