include $(TOPDIR)/rules.mk

PKG_NAME:=gluon-polygon-matcher
PKG_VERSION:=0.0.1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/gluon-polygon-matcher
  SECTION:=gluon
  CATEGORY:=Freifunk Muenster
  TITLE:=Polygon Matcher
  DEPENDS:=+gluon-core
endef

define Package/$(PKG_NAME)/description
  Selects the domain based on provided polygons in the geojson format.
endef

define Build/Prepare
  mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
  $(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
