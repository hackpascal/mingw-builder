MINGW_W64_PACKAGE_NAME=widl
MINGW_W64_PACKAGE_CATEGORY=tools

PACKAGE_SOURCE_DIR=$(MINGW_W64_SOURCE_DIR)/$(NAME)-$(MINGW_W64_PACKAGE_CATEGORY)/$(MINGW_W64_PACKAGE_NAME)
PACKAGE_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/$(MINGW_W64_PACKAGE_NAME)

CONFIGURE_ARGS= \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST))

all: install
	true

configure:
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		CFLAGS="$(PKG_CFLAGS)" \
		LDFLAGS="$(PKG_LDFLAGS)" \
		$(TARGET_CONFIGURE_VARS) \
		$(HOST_CONFIGURE_ENVS) \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(INSTALL_DESTDIR) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

