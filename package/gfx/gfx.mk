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

GFX_GBM_SURFACE_LIST = gbm-surface \
	gbm-surface-blend \
	gbm-surface-clear \
	gbm-surface-color \
	gbm-surface-draw \
	gbm-surface-fbo \
	gbm-surface-gbm-fbo \
	gbm-surface-index \
	gbm-surface-line \
	gbm-surface-move \
	gbm-surface-part \
	gbm-surface-render \
	gbm-surface-render-two \
	gbm-surface-scissor \
	gbm-surface-tex

# Makefile in the repo uses host 'gcc' directly.
# This below uses a make implicit rule so that it picks variables like CC.
define GFX_BUILD_CMDS
	for i in $(GFX_GBM_SURFACE_LIST); do $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/$$i main LDLIBS="-lgbm -lepoxy -lpng"; done
endef

define GFX_INSTALL_TARGET_CMDS
	for i in $(GFX_GBM_SURFACE_LIST); do mkdir -p $(TARGET_DIR)/usr/local/gfx/$$i; cp -v $(@D)/$$i/main $(TARGET_DIR)/usr/local/gfx/$$i/$$i; cp -v $(@D)/$$i/*.{glsl,png} $(TARGET_DIR)/usr/local/gfx/$$i/; done
endef

$(eval $(generic-package))
