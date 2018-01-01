
NAME=gcc
VERSION=7.2.0
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://ftp.gnu.org/gnu/$(NAME)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR_COMMON=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST)) \
	--with-gmp=$(HOST_OUTPUT_PREFIX) \
	--with-mpfr=$(HOST_OUTPUT_PREFIX) \
	--with-mpc=$(HOST_OUTPUT_PREFIX) \
	--with-isl=$(HOST_OUTPUT_PREFIX) \
	--with-cloog=$(HOST_OUTPUT_PREFIX) \
	--disable-__cxa_atexit \
	--disable-multilib \
	--disable-libssp \
	--disable-libmudflap \
	--enable-version-specific-runtime-libs \
	--enable-fully-dynamic-string \
	--enable-gnu-unique-object \
	--enable-linker-build-id \
	--enable-c99 \
	--enable-clocale=gnu \
	--enable-long-long \
	--enable-decimal-float \
	--with-gnu-ld \
	--with-gnu-as \
	--with-libiconv \
	--without-system-zlib \
	$(TARGET_GCC_FLAGS)

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
MINGW_HOST_CONFIGURE_ENVS := $(HOST_CONFIGURE_ENVS)
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
	RANLIB="$(HOST)-ranlib"
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
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(PACKAGE_SOURCE_DIR) -p1 < $$f; done; \
		touch $(PACKAGE_SOURCE_DIR)/.extracted \
	)

ifeq ($(BUILD_TYPE),toolchain)
configure: extract
	[ -f $(PACKAGE_BUILD_DIR)/.configured ] || ( \
		mkdir -p $(PACKAGE_BUILD_DIR); \
		cd $(PACKAGE_BUILD_DIR); \
		CFLAGS="$(HOST_CFLAGS) -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'" \
		CXXFLAGS="$(HOST_CFLAGS) -DMINGW_NATIVE_PREFIX='\\\\\\\"$(NATIVE_PREFIX)\\\\\\\"'" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS)" \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
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
		enable_gnu_indirect_function=yes \
		default_gnu_indirect_function=yes \
		CFLAGS="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TARGET_CFLAGS) $(GCC_DEBUG_CFLAGS)" \
		$(MINGW_HOST_CONFIGURE_ENVS) \
		LDFLAGS_FOR_TARGET="$(TARGET_LDFLAGS)" \
		CC_FOR_TARGET="$(TOOLCHAIN_PREFIX)gcc" \
		CXX_FOR_TARGET="$(TOOLCHAIN_PREFIX)g++" \
		AR_FOR_TARGET="$(TOOLCHAIN_PREFIX)ar" \
		AS_FOR_TARGET="$(TOOLCHAIN_PREFIX)as" \
		LD_FOR_TARGET="$(TOOLCHAIN_PREFIX)ld"  \
		RANLIB_FOR_TARGET="$(TOOLCHAIN_PREFIX)ranlib" \
			$(PACKAGE_SOURCE_DIR)/configure $(CONFIGURE_ARGS) && \
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

