################################################################################
#
# gfx
#
################################################################################

GFX_VERSION = 008708b75852b086d2502c3c415a5ea9eabd54cd
GFX_SITE = $(call github,yuq,gfx,$(GFX_VERSION))
GFX_LICENSE = Unknown
GFX_LICENSE_FILES = .gitignore
GFX_DEPENDENCIES = mesa3d libdrm libpng

# Makefile in the repo uses host 'gcc' directly.
# This below uses a make implicit rule so that it picks variables like CC.
define GFX_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/gbm-surface main LDLIBS="-lgbm -lepoxy -lpng"
endef

define GFX_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/root/gbm-surface
	cp -v $(@D)/gbm-surface/main $(TARGET_DIR)/root/gbm-surface/gbm-surface
	cp -v $(@D)/gbm-surface/*.glsl $(TARGET_DIR)/root/gbm-surface/
endef

$(eval $(generic-package))
