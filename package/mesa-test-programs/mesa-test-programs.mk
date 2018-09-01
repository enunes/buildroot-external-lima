################################################################################
#
# mesa-test-programs
#
################################################################################

MESA_TEST_PROGRAMS_VERSION = 37e7a352db1304f2c68ea8c60ffcb5412f4a3264
MESA_TEST_PROGRAMS_SITE = $(call github,enunes,mesa-test-programs,$(MESA_TEST_PROGRAMS_VERSION))
MESA_TEST_PROGRAMS_LICENSE = Unknown
MESA_TEST_PROGRAMS_LICENSE_FILES = .gitignore
MESA_TEST_PROGRAMS_DEPENDENCIES = mesa3d libdrm tiff libpng

define MESA_TEST_PROGRAMS_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

define MESA_TEST_PROGRAMS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/mesa-test-programs
	cp -rv $(@D)/* $(TARGET_DIR)/usr/local/mesa-test-programs
	rm -rfv $(TARGET_DIR)/usr/local/mesa-test-programs/{README,Makefile,*.c,*.o,*.glsl}
endef

$(eval $(generic-package))
