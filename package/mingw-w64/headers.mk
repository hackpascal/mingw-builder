MINGW_W64_PACKAGE_CATEGORY=headers

PACKAGE_SOURCE_DIR=$(MINGW_W64_SOURCE_DIR)/$(NAME)-$(MINGW_W64_PACKAGE_CATEGORY)
PACKAGE_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/$(NAME)-$(MINGW_W64_PACKAGE_CATEGORY)

CONFIGURE_ARGS= \
	--prefix=$(NATIVE_PREFIX) \
	--host=$(TARGET) \
	--build=$(BUILD) \
	--enable-idl \
	--enable-secure-api \
	--with-widl=$(TOOLCHAIN_BIN_DIR)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(MINGW_W64_SOURCE_DIR); \
		CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR:$(BUILD_SOURCE_DIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(OUTPUT_SYSROOT_PREFIX)

