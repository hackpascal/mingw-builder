
NAME=binutils
VERSION=2.32
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://ftp.gnu.org/gnu/$(NAME)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST)) \
	--enable-static \
	--disable-shared \
	--disable-nls \
	--enable-ld \
	--enable-lto \
	--with-system-zlib \
	--with-sysroot=$(SYSROOT_PREFIX)

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

ifeq ($(BUILD_TYPE),toolchain)
TOOLCHAIN_MINGW_PREFIX = -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'
TOOLCHAIN_MINGW_LIB_PATH = LIB_PATH="$(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/lib"
else
ifeq ($(HOST),$(TARGET))
TOOLCHAIN_MINGW_LIB_PATH = LIB_PATH="$(SYSROOT_PREFIX)/lib"
else
TOOLCHAIN_MINGW_PREFIX = -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'
TOOLCHAIN_MINGW_LIB_PATH = LIB_PATH="$(SYSROOT_PREFIX)$(NATIVE_PREFIX)/lib"
endif
endif

all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -Jxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		CFLAGS="$(PKG_CFLAGS) $(LIBS_CFLAGS) $(TOOLCHAIN_MINGW_PREFIX)" \
		CXXFLAGS="$(PKG_CFLAGS) $(LIBS_CFLAGS) $(TOOLCHAIN_MINGW_PREFIX)" \
		LDFLAGS="$(PKG_LDFLAGS) $(LIBS_LDFLAGS)" \
		$(HOST_CONFIGURE_ENVS) \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) $(TOOLCHAIN_MINGW_LIB_PATH) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(INSTALL_DESTDIR) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

