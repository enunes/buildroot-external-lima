################################################################################
#
# gfx
#
################################################################################

GFX_VERSION = 3f32cc9190d372026cf2b2a1eae633acefc467db
GFX_SITE = $(call github,yuq,gfx,$(GFX_VERSION))
GFX_LICENSE = Unknown
GFX_LICENSE_FILES = .gitignore
GFX_DEPENDENCIES = mesa3d libdrm libpng

# Makefile in the repo uses host 'gcc' directly.
# This below uses a make implicit rule so that it picks variables like CC.
define GFX_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/gbm-surface main LDLIBS="-lgbm -lepoxy -lpng"
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/gbm-surface-color main LDLIBS="-lgbm -lepoxy -lpng"
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/gbm-surface-move main LDLIBS="-lgbm -lepoxy -lpng"
endef

define GFX_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/local/gfx/gbm-surface
	cp -v $(@D)/gbm-surface/main $(TARGET_DIR)/usr/local/gfx/gbm-surface/gbm-surface
	cp -v $(@D)/gbm-surface/*.glsl $(TARGET_DIR)/usr/local/gfx/gbm-surface/
	mkdir -p $(TARGET_DIR)/usr/local/gfx/gbm-surface-color
	cp -v $(@D)/gbm-surface-color/main $(TARGET_DIR)/usr/local/gfx/gbm-surface-color/gbm-surface-color
	cp -v $(@D)/gbm-surface-color/*.glsl $(TARGET_DIR)/usr/local/gfx/gbm-surface-color/
	mkdir -p $(TARGET_DIR)/usr/local/gfx/gbm-surface-move
	cp -v $(@D)/gbm-surface-move/main $(TARGET_DIR)/usr/local/gfx/gbm-surface-move/gbm-surface-move
	cp -v $(@D)/gbm-surface-move/*.glsl $(TARGET_DIR)/usr/local/gfx/gbm-surface-move/
endef

$(eval $(generic-package))
