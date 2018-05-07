setenv fdt_high ffffffff
setenv bootargs console=tty1 console=ttyS0,115200 rootwait

# leave only one of the below uncommented, for either mmc or nfs root filesystem.
setenv bootargs $bootargs root=/dev/mmcblk0p2
#setenv bootargs $bootargs ip=dhcp root=/dev/nfs rw nfsroot=<SERVER.IP.HERE>:</EXPORTED/DIR/HERE>,nolock,tcp,nfsvers=4

# comment this for native resolution. may cause bugs in lima
setenv bootargs $bootargs drm_kms_helper.edid_firmware=edid/1024x768.bin

fatload mmc 0 $kernel_addr_r zImage
fatload mmc 0 $fdt_addr_r sun7i-a20-bananapi.dtb
bootz $kernel_addr_r - $fdt_addr_r
