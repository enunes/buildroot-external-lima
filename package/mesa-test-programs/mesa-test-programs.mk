################################################################################
#
# mesa-test-programs
#
################################################################################

MESA_TEST_PROGRAMS_VERSION = bf7789bffdd3d9b665cd37ee08f05adeb461314a
MESA_TEST_PROGRAMS_SITE = $(call github,enunes,mesa-test-programs,$(MESA_TEST_PROGRAMS_VERSION))
MESA_TEST_PROGRAMS_LICENSE = Unknown
MESA_TEST_PROGRAMS_LICENSE_FILES = .gitignore
MESA_TEST_PROGRAMS_DEPENDENCIES = mesa3d libdrm tiff

define MESA_TEST_PROGRAMS_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

define MESA_TEST_PROGRAMS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/root/mesa-test-programs
	cp -rv $(@D)/* $(TARGET_DIR)/root/mesa-test-programs
	rm -rfv $(TARGET_DIR)/root/mesa-test-programs/{README,Makefile,*.c}
endef

$(eval $(generic-package))
