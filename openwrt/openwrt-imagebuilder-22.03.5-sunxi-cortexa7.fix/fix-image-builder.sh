#
# Use modified DT
#
cp ${FIXDIR}/sun8i-h3-zeropi.dt* ${OPENWRTDIR}/${IMAGEBUILDERDIR}/build_dir/target-arm_cortex-a7+neon-vfpv4_musl_eabi/linux-sunxi_cortexa7/linux-5.10.*/arch/arm/boot/dts
cp ${FIXDIR}/u-boot-sunxi-with-spl.bin ${OPENWRTDIR}/${IMAGEBUILDERDIR}/staging_dir/target-arm_cortex-a7+neon-vfpv4_musl_eabi/image/olimex_a20-olinuxino-lime2-u-boot-with-spl.bin
