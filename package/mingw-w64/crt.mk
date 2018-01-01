MINGW_W64_PACKAGE_CATEGORY=crt

PACKAGE_SOURCE_DIR=$(MINGW_W64_SOURCE_DIR)/$(NAME)-$(MINGW_W64_PACKAGE_CATEGORY)
PACKAGE_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/$(NAME)-$(MINGW_W64_PACKAGE_CATEGORY)

ifeq ($(strip $(LIBC_DEBUG)),y)
CRT_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

CONFIGURE_ARGS = \
	--prefix=$(NATIVE_PREFIX) \
	--build=$(BUILD) \
	--host=$(TARGET) \
	--disable-w32api \
	$(if $(findstring x86_64,$(TARGET)), \
		--enable-lib64 --disable-lib32, \
		--enable-lib32 --disable-lib64) \
	--enable-private-exports \
	--enable-delay-import-libs \
	--with-sysroot=$(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)
	
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		CFLAGS="$(TARGET_CFLAGS) $(CRT_DEBUG_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(TARGET_CONFIGURE_ENVS) \
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
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(OUTPUT_SYSROOT_PREFIX) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

