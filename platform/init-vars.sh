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


