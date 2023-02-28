#
#
#

readonly OPENWRTVER=22.03.3
readonly OPENWRTDIR=${SCRIPTDIR}/../../openwrt
readonly DOCKERDIR=${SCRIPTDIR}/../../docker
readonly IMAGEBUILDERDIR=openwrt-imagebuilder-${OPENWRTVER}-${TARGET}-${SUBTARGET}.Linux-x86_64
readonly IMGDIR=bin/targets/${TARGET}/${SUBTARGET}
readonly IMGFILE_BASE=openwrt-${OPENWRTVER}-docker-${TARGET}-${SUBTARGET}-${PROFILE}
readonly IMGFILE=${IMGFILE_BASE}-squashfs-sdcard.img
readonly IMGFILE_FACTORY=${IMGFILE_BASE}-squashfs-factory.img
readonly IMGFILE_UPGRADE=${IMGFILE_BASE}-squashfs-sysupgrade.img

declare -r -a IMGPKGS=(
	kmod-nf-conntrack-netlink
	kmod-ledtrig-activity
	nano
	usbutils
	htop iftop iperf3
	shadow-useradd shadow-usermod shadow-chpasswd
	shadow-groupadd shadow-groupmod
	sudo
	iptables-nft ip6tables-nft
	docker dockerd docker-compose
	kmod-fs-vfat kmod-nls-cp852 kmod-nls-iso8859-2 dosfstools
	kmod-fs-f2fs f2fsck mkf2fs
	block-mount
	kmod-usb-storage kmod-usb-storage-uas kmod-usb-storage-extras
	lsblk fdisk sfdisk losetup
	libcap-bin
)

declare -r -a IMGNPKGS=(
	ppp
	ppp-mod-pppoe
	luci lua
	dnsmasq
	odhcp6c
	odhcpd-ipv6only
)


[ -d ${OPENWRTDIR} ] || mkdir -p ${OPENWRTDIR}
if [ ! -d ${OPENWRTDIR}/${IMAGEBUILDERDIR} ]; then
    wget -nv -O ${OPENWRTDIR}/${IMAGEBUILDERDIR}.tar.xz http://downloads.openwrt.org/releases/${OPENWRTVER}/targets/${TARGET}/${SUBTARGET}/${IMAGEBUILDERDIR}.tar.xz
    tar -C ${OPENWRTDIR} -xf ${OPENWRTDIR}/${IMAGEBUILDERDIR}.tar.xz
fi

join_by () {
    # Argument #1 is the separator. It can be multi-character.
    # Argument #2, 3, and so on, are the elements to be joined.
    # Usage: join_by ", " "${array[@]}"
    local SEPARATOR="$1"
    shift

    local F=''
    for x in "$@"
    do
        if [ -n "$F" ]
        then
            echo -n $F
        else
            F=$SEPARATOR
        fi
        echo -n "$x"
    done
    echo
}

function overlay_ro(){
   case $# in
      0)
      ;;
      
      1)
      ;;
      
      *)
      local TMP_DIR=$(mktemp -d)
      local JOINED_DIRS=$(join_by ':' "$@")
      fuse-overlayfs -o auto_umount -o lowerdir=${JOINED_DIRS} $TMP_DIR
      echo $TMP_DIR
      ;;
   esac
}

function umount_overlay() {
    fusermount -q -u $1
    rmdir $1
}


