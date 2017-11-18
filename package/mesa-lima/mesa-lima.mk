################################################################################
#
# mesa-lima
#
################################################################################

# NOTE: this is a hack. It is not how packages generally look like in
# Buildroot.
# The proper way to do this would be to add lima support to the mesa3d package
# in upstream Buildroot. However, lima currently requires the use of
# non-upstream kernel and non-upstream mesa repos, which makes such a change
# unsuitable to be merged in upstream Buildroot yet.
# Since mesa3d is a slightly complicated package, in order to support lima on
# it now, we either do the below hacks and append some variables to the
# existing mesa3d recipe, or create a fork of the entire Buildroot tree.
# Maintaining a fork would be more work now and would quickly become out of
# sync with upstream Buildroot, so just do the below hacks.

# Always enable mesa debug for mesa-lima development
MESA3D_CONF_OPTS += --enable-debug

# Avoid "configure: error: Python mako module v0.8.0 or higher not found"
# Sorry about this. Appending dependencies would not work in this package
# 'extension'.
define MESA3D_DEPENDENCY_MAKO
	make -C $(BASE_DIR) host-python-mako
endef
MESA3D_PRE_CONFIGURE_HOOKS += MESA3D_DEPENDENCY_MAKO

# Make mesa3d build with --with-gallium-drivers=lima,sun4i
MESA3D_GALLIUM_DRIVERS-$(BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_LIMA) += lima sun4i
