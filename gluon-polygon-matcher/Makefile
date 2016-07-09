PKG_NAME:=gluon-polygon-matcher
PKG_VERSION:=0.0.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-polygon-matcher
  SECTION:=gluon
    CATEGORY:=Gluon
      TITLE:=Polygon Matcher
        DEPENDS:=+gluon-core
	endef

define Build/Prepare
        mkdir -p $(PKG_BUILD_DIR)
	endef

define Build/Configure
endef

define Build/Compile
endef

define Package/gluon-polygon-matcher/install
        $(CP) ./files/* $(1)/
	endef

$(eval $(call BuildPackage,gluon-polygon-matcher))
