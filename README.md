# Deprecation notice

Lima is now in the upstream [linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/gpu/drm/lima) tree and upstream [mesa](https://gitlab.freedesktop.org/mesa/mesa).
It is now also available in [Buildroot](https://patchwork.ozlabs.org/patch/1165617/) upstream.
Therefore, this repository is no longer necessary.

## buildroot-external-lima

This is a [BR2_EXTERNAL](https://buildroot.org/downloads/manual/manual.html#outside-br-custom) tree for [Buildroot](https://buildroot.org/) which contains modifications to the mesa3d package so that it supports building the mesa port of [lima](https://gitlab.freedesktop.org/lima/mesa.git) (OpenGL driver for ARM Mali400/450).
It is intended to be used for people interested in developing or trying lima.

See [lima/mesa](https://gitlab.freedesktop.org/lima/mesa.git), [lima/linux](https://gitlab.freedesktop.org/lima/linux.git) and the [lima wiki](https://gitlab.freedesktop.org/lima/web/wikis/home) for more information about the driver.

The normal Buildroot development workflow can be used with this tree, so the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html) can be used.

## Quick start

Here is a quick start on how to use this to cross-compile a full image containing lima. Note that this is all detailed more extensively in the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html), these are just some copy and paste commands. These steps do not require or use any feature that is not documented in the Buildroot manual.

Clone Buildroot:

```
git clone git://git.buildroot.net/buildroot
```

Clone this repository:

```
git clone https://github.com/enunes/buildroot-external-lima
```

You will also need `mesa-lima` and `linux-lima`, so clone those too:

```
git clone https://gitlab.freedesktop.org/lima/mesa.git
git clone https://gitlab.freedesktop.org/lima/linux.git
```

Now, we need to create a workspace directory to use while we use Buildroot.

First, select one of the existing defconfigs in Buildroot, which can be seen [here](https://git.buildroot.net/buildroot/tree/configs).
Some examples of defconfigs for devices with a Mali400 are, `cubieboard2_defconfig`, `pine64_defconfig`.
Then create the workspace directory with:

```
make -C buildroot O=$PWD/output BR2_EXTERNAL=$PWD/buildroot-external-lima <defconfig>
# for example:
make -C buildroot O=$PWD/output BR2_EXTERNAL=$PWD/buildroot-external-lima cubieboard2_defconfig
```

This line also configures this repository as a BR2_EXTERNAL. (More details about [BR2_EXTERNAL in the manual](https://buildroot.org/downloads/manual/manual.html#outside-br-custom)).
The output directory will be called `output` (note: you can have multiple simultaneous output, just changing `O=` to point to another name).

Since we want to use our externally cloned repositories for `mesa-lima` and `linux-lima`, we need to [tell Buildroot about that](https://buildroot.org/downloads/manual/manual.html#_using_buildroot_during_development) using a `local.mk` file.
Copy the provided `local.mk` template to the output directory.

```
cp buildroot-external-lima/local.mk.template output/local.mk
```

Edit `output/local.mk` and adjust the `MESA3D_OVERRIDE_SRCDIR` and `LINUX_OVERRIDE_SRCDIR` variables to point to the directories where you cloned the `mesa-lima` and `linux-lima` repositories respectively.

```
vim output/local.mk
```

Finally, the default Buildroot defconfig doesn't have mesa3d or lima enabled, so enable it by using the provided config fragment:

```
cd output
../buildroot/support/kconfig/merge_config.sh .config ../buildroot-external-lima/configs/lima-config.frag
```

Now the build can be started with `make` inside the `output` directory:

```
make
```

The first build may take several minutes.
After the build is done, flash `images/sdcard.img` to a SD card.

```
sudo dd if=images/sdcard.img of=/dev/YOUR_DEV
```

Insert the SD card into the board, connect a UART adapter or monitor, and log in to the board.

```
Welcome to Cubieboard2!
Cubieboard2 login: root
Password: (root)
# lsmod
Module                  Size  Used by    Not tainted
lima                   45056  0
gpu_sched              20480  1 lima
ttm                    65536  1 lima
sun4i_backend          20480  0
sun4i_drm_hdmi         20480  0
sun4i_drm              16384  0
sun4i_frontend         16384  2 sun4i_backend,sun4i_drm
sun4i_tcon             28672  1 sun4i_drm
# dmesg | grep -i sun4i-drm
[    2.870341] sun4i-drm display-engine: bound 1e60000.display-backend (ops sun4i_backend_ops [sun4i_backend])
[    2.890566] sun4i-drm display-engine: bound 1e40000.display-backend (ops sun4i_backend_ops [sun4i_backend])
[    2.900948] sun4i-drm display-engine: No panel or bridge found... RGB output disabled
[    2.908843] sun4i-drm display-engine: bound 1c0c000.lcd-controller (ops sun4i_tcon_platform_driver_exit [sun4i_tcon])
[    2.920111] sun4i-drm display-engine: No panel or bridge found... RGB output disabled
[    2.928031] sun4i-drm display-engine: bound 1c0d000.lcd-controller (ops sun4i_tcon_platform_driver_exit [sun4i_tcon])
[    3.038806] sun4i-drm display-engine: bound 1c16000.hdmi (ops sun4i_hdmi_driver_exit [sun4i_drm_hdmi])
[    3.064483] fb: switching to sun4i-drm-fb from simple
[    3.226186] sun4i-drm display-engine: fb0:  frame buffer device
[    3.233673] [drm] Initialized sun4i-drm 1.0.0 20150629 for display-engine on minor 0
# dmesg | grep -i lima
[    2.930238] lima 1c40000.gpu: bus rate = 300000000
[    2.943558] lima 1c40000.gpu: mod rate = 384000000
[    2.970024] lima 1c40000.gpu: gp - mali400 version major 1 minor 1
[    2.976392] lima 1c40000.gpu: pp0 - mali400 version major 1 minor 1
[    2.982786] lima 1c40000.gpu: pp1 - mali400 version major 1 minor 1
[    2.989216] lima 1c40000.gpu: l2 cache 64K, 4-way, 64byte cache line, 64bit external bus
[    3.035332] [drm] Initialized lima 1.0.0 20170325 for 1c40000.gpu on minor 1
# ls /dev/dri
by-path     card0       card1       renderD128
# ls /usr/lib/dri/
exynos_dri.so     lima_dri.so       meson_dri.so      rockchip_dri.so   sun4i-drm_dri.so
```

Try offscreen rendering with `egl-color-png`, which will output `screenshot.png`:

```
# cd /usr/local/mesa-test-programs/
# ./egl-color-png
# ls screenshot.png
screenshot.png
```

If you have a display plugged in, you can also try `egl-color-kms` to render to the display:

```
# cd /usr/local/mesa-test-programs/
# ./egl-color-kms
```

`kmscube` is a nice well-known upstream demo (for a smoother animation without slowdowns, redirect all debug output to `/dev/null`):

```
# kmscube >/dev/null 2>&1
# kmscube -M rgba >/dev/null 2>&1
```

See https://gitlab.freedesktop.org/lima/web/wikis/home for a more up-to-date list of working features.

## Development workflow

During lima development, in order to quickly rebuild `mesa3d` or `linux` after performing code changes, we can leverage the [OVERRIDE_SRCDIR](https://buildroot.org/downloads/manual/manual.html#_using_buildroot_during_development) feature from Buildroot.

The code can be changed directly in the directories where we clones the repositories earlier.
After changing the code, rebuild the respective package with:

```
make mesa3d-rebuild
  or
make linux-rebuild
```

This will cause Buildroot to re-sync the sources from your cloned repository, including non-committed changes, and rebuild.
The newly built libraries or modules can be copyed with `scp` to the board from the `output/target/` directory (`scp target/usr/lib/dri/* root@<board ip>:/usr/lib/dri/`) to avoid having to re-flash every time.
This workflow can be used for any Buildroot package.

A further workflow enhancement is to use a NFS root filesystem instead of mmc, to make it even simpler to copy modifications to the target.
To do this, [setup nfs-server](https://elinux.org/TFTP_Boot_and_NFS_Root_Filesystems#NFS_Server), extract `output/images/rootfs.tar` as root to a NFS-exported directory.
Then, change the bootargs in the bootcmd file to use the nfsroot as in:

```
setenv bootargs $bootargs ip=dhcp root=/dev/nfs rw nfsroot=<SERVER.IP.HERE>:</EXPORTED/DIR/HERE>,nolock,tcp,nfsvers=4
```

After this, files can be made accessible to the embedded board by just copying them to the NFS-exported root filesystem.
The Buildroot `uboot` package is responsible for making the boot script from `boot-<board>.cmd`. so when that file is modified, it is necessary to `make uboot-rebuild` so that the boot script in the target is updated.

When a new `sdcard.img` is necessary, run `make` or `make all`.

## Reference

For a full reference on how to use Buildroot, check the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html), or check the [training materials](http://free-electrons.com/doc/training/buildroot/buildroot-slides.pdf) from free-electrons.
