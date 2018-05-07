## buildroot-external-lima

This is a [BR2_EXTERNAL](https://buildroot.org/downloads/manual/manual.html#outside-br-custom) tree for [Buildroot](https://buildroot.org/) which contains modifications to the mesa3d package so that it supports building the mesa port of [lima](https://github.com/yuq/mesa-lima) (OpenGL driver for ARM Mali400), to be used for people interested in developing or trying lima.

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
git clone https://github.com/yuq/mesa-lima.git
git clone https://github.com/yuq/linux-lima.git
```

Now, we need to create an output directory to be our workspace while we use Buildroot.

Use one of the following commands to create that and use one of the predefined configurations from this repository that include lima and the demo programs.
Predefined configurations are provided for the Cubieboard2, Bananapi M1 Plus, NanoPi M1 boards.
(More details about [BR2_EXTERNAL in the manual](https://buildroot.org/downloads/manual/manual.html#outside-br-custom)).

```
make -C buildroot O=$PWD/output BR2_EXTERNAL=$PWD/buildroot-external-lima lima_nanopi_m1_defconfig
  or
make -C buildroot O=$PWD/output BR2_EXTERNAL=$PWD/buildroot-external-lima lima_cubieboard2_defconfig
  or
make -C buildroot O=$PWD/output BR2_EXTERNAL=$PWD/buildroot-external-lima lima_bananapi_m1_plus_defconfig
```

The output directory will be called `output` (note: there can be multiple simultaneous outputs, by changing `O=` to point to another path).

Since we want to use our externally cloned repositories for `mesa-lima` and `linux-lima`, we need to [tell Buildroot about that](https://buildroot.org/downloads/manual/manual.html#_using_buildroot_during_development) using a `local.mk` file.
Copy the provided `local.mk` template to the output directory.

```
cp buildroot-external-lima/local.mk.template output/local.mk
```

Edit `output/local.mk` and adjust the `MESA3D_OVERRIDE_SRCDIR` and `LINUX_OVERRIDE_SRCDIR` variables to point to the directories where you cloned the `mesa-lima` and `linux-lima` repositories respectively.

```
vim output/local.mk
```

Now the build can be started with `make` in the `output` directory:

```
cd output
make
```

The first build may take several minutes.
After the build is done, flash `images/sdcard.img` to a SD card.

```
sudo dd if=images/sdcard.img of=/dev/YOUR_DEV
```

Insert the SD card into the board, connect a UART adapter or monitor, and log in to the board.

```
cubieboard2
cubieboard2 login: root
Password: (root)
# lsmod
Module                  Size  Used by    Not tainted
lima                   28672  0
# dmesg | grep -i sun4i-drm
[    0.957682] sun4i-drm display-engine: bound 1e60000.display-backend (ops 0xc0743708)
[    0.966040] sun4i-drm display-engine: No panel or bridge found... RGB output disabled
[    0.974143] sun4i-drm display-engine: bound 1c0c000.lcd-controller (ops 0xc0742b28)
[    0.991322] sun4i-drm display-engine: bound 1c16000.hdmi (ops 0xc0743ab0)
[    1.007333] fb: switching to sun4i-drm-fb from simple
[    1.109215] sun4i-drm display-engine: fb0:  frame buffer device
[    1.115804] [drm] Initialized sun4i-drm 1.0.0 20150629 for display-engine on minor 0
# dmesg | grep -i lima
[    3.505853] lima 1c40000.gpu: bus rate = 300000000
[    3.517377] lima 1c40000.gpu: mod rate = 195000000
[    3.535307] lima 1c40000.gpu: found 2 PPs
[    3.546023] lima 1c40000.gpu: l2 cache 64K, 4-way, 64byte cache line, 64bit external bus
[    3.560988] lima 1c40000.gpu: gp - mali400 version major 1 minor 1
[    3.577875] lima 1c40000.gpu: pp0 - mali400 version major 1 minor 1
[    3.590964] lima 1c40000.gpu: pp1 - mali400 version major 1 minor 1
[    3.606303] [drm] Initialized lima 1.0.0 20170325 for 1c40000.gpu on minor 1
# ls /dev/dri
by-path     card0       card1       renderD128
# ls /usr/lib/dri/
lima_dri.so       sun4i-drm_dri.so
```

Try offscreen rendering with `gbm-surface`:

```
# cd gbm-surface/
# ls
frag.glsl    gbm-surface  vert.glsl
# ./gbm-surface
 <snip>
frag.glsl       gbm-surface     screenshot.png  vert.glsl
```

If you have a monitor plugged in, you can also try `gbm-bo-test` for rendering to the display:

```
# cd mesa-test-programs/
# ./gbm-bo-test
```

Enjoy your triangles!

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
To do this, [setup nfs-server](https://elinux.org/TFTP_Boot_and_NFS_Root_Filesystems#NFS_Server), extract `output/images/rootfs.tar` as root to a NFS-exported directory, and change (uncomment) the bootcmd to use the nfsroot line in `buildroot-external-lima/board/lima/boot-<board>.cmd`.
After this, files can be made accessible to the embedded board by just copying them to the NFS-exported root filesystem.
The Buildroot `uboot` package is responsible for making the boot script from `boot-<board>.cmd`. so when that file is modified, it is necessary to `make uboot-rebuild` so that the boot script in the target is updated.

When a new `sdcard.img` is necessary, run `make` or `make all`.

## Reference

For a full reference on how to use Buildroot, check the [Buildroot manual](https://buildroot.org/downloads/manual/manual.html), or check the [training materials](http://free-electrons.com/doc/training/buildroot/buildroot-slides.pdf) from free-electrons.
