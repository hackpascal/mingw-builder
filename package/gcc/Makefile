
NAME=gcc
GCC_VER_MAJOR=9
GCC_VER_MINOR=2
GCC_VER_PATCH=0
VERSION=$(GCC_VER_MAJOR).$(GCC_VER_MINOR).$(GCC_VER_PATCH)
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://ftp.gnu.org/gnu/$(NAME)/$(NAME)-$(VERSION)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR_COMMON=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST)) \
	--disable-multilib \
	--enable-version-specific-runtime-libs \
	--enable-fully-dynamic-string \
	--enable-gnu-unique-object \
	--with-gnu-ld \
	--with-gnu-as \
	--with-system-zlib \
	$(TARGET_GCC_FLAGS)

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

ifeq ($(BUILD_TYPE),toolchain)
CONFIGURE_ARGS += \
	--with-sysroot=$(SYSROOT_PREFIX) \
	--with-native-system-header-dir=$(NATIVE_PREFIX)/include
TOOLCHAIN_BUILD_ENV:=TOOLCHAIN_BUILD=1
else
ifeq ($(TARGET),$(HOST))
CONFIGURE_ARGS += \
	--with-sysroot=$(SYSROOT_PREFIX) \
	--with-native-system-header-dir=/include
MINGW_HOST_CONFIGURE_ENVS := $(HOST_CONFIGURE_ENVS) \
	BUILD_TIME_INSTALL_DIR="$(INSTALL_DESTDIR)"
else
CONFIGURE_ARGS += \
	--with-sysroot=$(SYSROOT_PREFIX) \
	--with-native-system-header-dir=$(NATIVE_PREFIX)/include
MINGW_HOST_CONFIGURE_ENVS := \
	CC="$(HOST)-gcc -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'" \
	CXX="$(HOST)-g++ -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'" \
	AR="$(HOST)-ar" \
	AS="$(HOST)-as" \
	LD="$(HOST)-ld" \
	STRIP="$(HOST)-strip" \
	RANLIB="$(HOST)-ranlib" \
	BUILD_TIME_INSTALL_DIR="$(INSTALL_DESTDIR)"
endif
endif

ifneq ($(filter seh dw2,$(EXCEPTION_MODEL)),)
CONFIGURE_ARGS += --disable-sjlj-exceptions
else
CONFIGURE_ARGS += --enable-sjlj-exceptions
endif

ifeq ($(strip $(LIBC_DEBUG)),y)
GCC_DEBUG_CFLAGS:=-g3 -ggdb3 -gdwarf-4
endif

PACKAGE_BUILD_DIR=$(PACKAGE_BUILD_DIR_COMMON)-$(STAGE)

ifneq ($(LIBC),none)
STAGE_MK=$(STAGE)
else
STAGE_MK=$(STAGE)-none
endif

include $(STAGE_MK).mk


all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(PACKAGE_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(PACKAGE_SOURCE_DIR); \
		tar -Jxf $(DLDIR)/$(SOURCE_FILE) -C $(BUILD_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f || exit 1; done; \
		for f in $$(ls ./patches-$(GCC_VER_MAJOR).$(GCC_VER_MINOR)/*.patch ./patches/-$(GCC_VER_MAJOR).$(GCC_VER_MINOR)*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f || exit 1; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

ifeq ($(BUILD_TYPE),toolchain)
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(PACKAGE_SOURCE_DIR); \
		CFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS) -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'" \
		CXXFLAGS="$(HOST_CFLAGS) $(LIBS_CFLAGS) -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'" \
		LDFLAGS="$(HOST_LDFLAGS) $(LIBS_LDFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR:$(BUILD_SOURCE_DIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(INSTALL_DESTDIR) && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib/*.a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/ || true) && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64 ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64/*.a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/ || true) && \
		(cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64 ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/lib64/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		([ -d $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/$(VERSION) ] && cp -a $(OUTPUT_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)
else
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		ln -sf $(PACKAGE_SOURCE_DIR); \
		enable_gnu_indirect_function=yes \
		default_gnu_indirect_function=yes \
		CFLAGS="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(LIBS_LDFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS) -isystem /include -L$(INSTALL_DESTDIR)$(PREFIX)/lib" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(LIBS_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		$(MINGW_HOST_CONFIGURE_ENVS) \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS) $(LIBS_LDFLAGS)" \
		CC_FOR_TARGET="$(TOOLCHAIN_PREFIX)gcc" \
		CXX_FOR_TARGET="$(TOOLCHAIN_PREFIX)g++" \
		AR_FOR_TARGET="$(TOOLCHAIN_PREFIX)ar" \
		AS_FOR_TARGET="$(TOOLCHAIN_PREFIX)as" \
		LD_FOR_TARGET="$(TOOLCHAIN_PREFIX)ld"  \
		RANLIB_FOR_TARGET="$(TOOLCHAIN_PREFIX)ranlib" \
			$(PACKAGE_SOURCE_DIR:$(BUILD_SOURCE_DIR)/%=%)/configure $(CONFIGURE_ARGS) && \
		touch $(PACKAGE_BUILD_DIR)/.configured \
	)

install: build
	[ -f $(PACKAGE_BUILD_DIR)/.installed ] || ( \
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install DESTDIR=$(INSTALL_DESTDIR) && \
		([ -d $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib ] && cp -a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib/*.a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/ || true) && \
		([ -d $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib64 ] && cp -a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib64/*.a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/ || true) && \
		(cp -a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/*.dll $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		([ -d $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib ] && cp -a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		([ -d $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib64 ] && cp -a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/lib64/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		([ -d $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/$(VERSION) ] && cp -a $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/*.dll $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin/ || true) && \
		sed -i 's/$(subst /,\/,$(OUTPUT_PREFIX))//g' $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/lib/gcc/$(TARGET)/$(VERSION)/install-tools/mkheaders.conf && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)
endif

build: configure
	[ -f $(PACKAGE_BUILD_DIR)/.built ] || ( \
		$(TOOLCHAIN_BUILD_ENV) $(MAKE) -C $(PACKAGE_BUILD_DIR) && \
		touch $(PACKAGE_BUILD_DIR)/.built \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

