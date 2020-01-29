MINGW_W64_PACKAGE_NAME=winstorecompat
MINGW_W64_PACKAGE_CATEGORY=libraries

PACKAGE_SOURCE_DIR=$(MINGW_W64_SOURCE_DIR)/$(NAME)-$(MINGW_W64_PACKAGE_CATEGORY)/$(MINGW_W64_PACKAGE_NAME)
PACKAGE_BUILD_DIR=$(MINGW_W64_BUILD_DIR)/$(MINGW_W64_PACKAGE_NAME)

ifeq ($(strip $(LIBC_DEBUG)),y)
DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

CONFIGURE_ARGS= \
	--prefix=$(NATIVE_PREFIX) \
	--host=$(TARGET) \
	--enable-static \
	--enable-shared

all: install
	true

configure:
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(MINGW_W64_SOURCE_DIR); \
		CFLAGS="$(TARGET_CFLAGS) $(DEBUG_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(TARGET_CONFIGURE_ENVS) \
			$(PACKAGE_SOURCE_DIR:$(BUILD_SOURCE_DIR)/%=%)/configure $(CONFIGURE_ARGS) && \
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

