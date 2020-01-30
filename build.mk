
export BUILD_TYPE:=$(strip $(BUILD_TYPE))

export TARGET_BUILD_DIR:=$(BUILDDIR)/$(TARGET)-$(EXCEPTION_MODEL)-thread_$(THREAD_MODEL)
export TARGET_OUTPUT_DIR:=$(OUTPUTDIR)/$(TARGET)-$(EXCEPTION_MODEL)-thread_$(THREAD_MODEL)

export NATIVE_PREFIX:=$(PREFIX)

export TOOLCHAIN_BIN_DIR:=$(TARGET_OUTPUT_DIR)/host-$(BUILD)/toolchain/usr/bin
export TOOLCHAIN_PREFIX:=$(TOOLCHAIN_BIN_DIR)/$(TARGET)-

export TARGET_CONFIGURE_ENVS := \
	CC="$(TOOLCHAIN_PREFIX)gcc" \
	CXX="$(TOOLCHAIN_PREFIX)g++" \
	AR="$(TOOLCHAIN_PREFIX)ar" \
	AS="$(TOOLCHAIN_PREFIX)as" \
	LD="$(TOOLCHAIN_PREFIX)ld" \
	NM="$(TOOLCHAIN_PREFIX)nm" \
	STRIP="$(TOOLCHAIN_PREFIX)strip" \
	RANLIB="$(TOOLCHAIN_PREFIX)ranlib" \
	WINDMC="$(TOOLCHAIN_PREFIX)windmc" \
	WINDRES="$(TOOLCHAIN_PREFIX)windres" \
	DLLTOOL="$(TOOLCHAIN_PREFIX)dlltool" \
	OBJCOPY="$(TOOLCHAIN_PREFIX)objcopy" \
	OBJDUMP="$(TOOLCHAIN_PREFIX)objdump" \
	RC="$(TOOLCHAIN_PREFIX)windres"

export _HOST_CONFIGURE_ENVS := \
	CC="$(HOST)-gcc" \
	CXX="$(HOST)-g++" \
	AR="$(HOST)-ar" \
	AS="$(HOST)-as" \
	LD="$(HOST)-ld" \
	NM="$(HOST)-nm" \
	STRIP="$(HOST)-strip" \
	RANLIB="$(HOST)-ranlib" \
	WINDMC="$(HOST)-windmc" \
	WINDRES="$(HOST)-windres" \
	DLLTOOL="$(HOST)-dlltool" \
	OBJCOPY="$(HOST)-objcopy" \
	OBJDUMP="$(HOST)-objdump" \
	RC="$(HOST)-windres"

ifeq ($(BUILD_TYPE),toolchain)
export OUTPUT_PREFIX:=$(TARGET_OUTPUT_DIR)/host-$(BUILD)/$(BUILD_TYPE)/usr
export INSTALL_DESTDIR:=/
export PREFIX:=$(OUTPUT_PREFIX)
export BUILD_DIR:=$(TARGET_BUILD_DIR)/host-$(BUILD)/$(BUILD_TYPE)
export HOST_BUILD_DIR:=$(BUILDDIR)/$(BUILD)
export HOST:=
export SYSROOT_PREFIX:=$(OUTPUT_PREFIX)/$(TARGET)
export OUTPUT_SYSROOT_PREFIX:=$(SYSROOT_PREFIX)
export PKG_CFLAGS:=$(HOST_CFLAGS)
export PKG_LDFLAGS:=$(HOST_LDFLAGS)
export CONFIGURE_ENVS :=
export HOST_CONFIGURE_ENVS :=
else
ifeq ($(BUILD_TYPE),target)
export OUTPUT_PREFIX:=$(TARGET_OUTPUT_DIR)/host-$(HOST)/$(BUILD_TYPE)
export INSTALL_DESTDIR:=$(OUTPUT_PREFIX)
export BUILD_DIR:=$(TARGET_BUILD_DIR)/host-$(HOST)/$(BUILD_TYPE)
export HOST_BUILD_DIR:=$(BUILDDIR)/$(HOST)
ifeq ($(HOST),$(TARGET))
export SYSROOT_PREFIX:=$(NATIVE_PREFIX)
export OUTPUT_SYSROOT_PREFIX:=$(OUTPUT_PREFIX)
export HOST_TOOLCHAIN_PREFIX:=$(TOOLCHAIN_PREFIX)
export HOST_CONFIGURE_ENVS := $(TARGET_CONFIGURE_ENVS)
else
export SYSROOT_PREFIX:=$(NATIVE_PREFIX)/$(TARGET)
export OUTPUT_SYSROOT_PREFIX:=$(OUTPUT_PREFIX)$(NATIVE_PREFIX)/$(TARGET)
export HOST_TOOLCHAIN_PREFIX:=$(HOST)-
export HOST_CONFIGURE_ENVS := $(_HOST_CONFIGURE_ENVS)
endif
export PKG_CFLAGS:=$(TARGET_CFLAGS)
export PKG_LDFLAGS:=$(TARGET_LDFLAGS)
export CONFIGURE_ENVS := $(TARGET_CONFIGURE_ENVS)

export TARGET_CONFIGURE_VARS := \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes
else
$(error Invalid BUILD_TYPE)
endif
endif

export BUILD_SOURCE_DIR:=$(BUILDDIR)/sources

export HOST_SOURCE_DIR:=$(BUILD_SOURCE_DIR)
export HOST_OUTPUT_PREFIX:=$(HOST_BUILD_DIR)/install


all: mingw-w64-libraries gdb
ifeq ($(BUILD_TYPE),target)
ifeq ($(STRIP_ALL),y)
	-find $(OUTPUT_PREFIX)$(NATIVE_PREFIX) -name '*.exe' -o -name '*.dll' -o -name '*.a' -o -name '*.o' | xargs $(HOST_TOOLCHAIN_PREFIX)strip
else
	-find $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/bin -name '*.exe' -o -name '*.dll' | xargs $(HOST_TOOLCHAIN_PREFIX)strip
	-find $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/libexec -name '*.exe' -o -name '*.dll' | xargs $(HOST_TOOLCHAIN_PREFIX)strip
	-find $(OUTPUT_PREFIX)$(NATIVE_PREFIX)/$(TARGET)/bin -name '*.exe' -o -name '*.dll' | xargs $(HOST_TOOLCHAIN_PREFIX)strip
endif
	find $(OUTPUT_PREFIX)$(NATIVE_PREFIX) -name '*.la' | xargs sed -i -e 's/-L$(subst /,\/,$(HOST_OUTPUT_PREFIX))\/lib//g' -e 's/$(subst /,\/,$(OUTPUT_PREFIX))//g'
endif

gmp:
	$(MAKE) -C $(PACKAGEDIR)/gmp

mpfr: gmp
	$(MAKE) -C $(PACKAGEDIR)/mpfr

mpc: gmp mpfr
	$(MAKE) -C $(PACKAGEDIR)/mpc

isl: gmp
	$(MAKE) -C $(PACKAGEDIR)/isl

zlib:
	$(MAKE) -C $(PACKAGEDIR)/zlib

libiconv:
	$(MAKE) -C $(PACKAGEDIR)/libiconv

expat:
	$(MAKE) -C $(PACKAGEDIR)/expat

xz:
	$(MAKE) -C $(PACKAGEDIR)/xz

binutils: gmp mpfr mpc isl
	$(MAKE) -C $(PACKAGEDIR)/binutils

dir-prep:
ifeq ($(BUILD_TYPE),toolchain)
	mkdir -p $(OUTPUT_SYSROOT_PREFIX)/lib
endif
	mkdir -p $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/bin
	mkdir -p $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/lib
	mkdir -p $(OUTPUT_SYSROOT_PREFIX)$(NATIVE_PREFIX)/include

mingw-w64-tools:
	$(MAKE) -C $(PACKAGEDIR)/mingw-w64 PART=tools

mingw-w64-crt: mingw-w64-headers
	$(MAKE) -C $(PACKAGEDIR)/mingw-w64 PART=crt

ifeq ($(BUILD_TYPE),toolchain)
mingw-w64-headers: dir-prep mingw-w64-tools gcc-initial
	$(MAKE) -C $(PACKAGEDIR)/mingw-w64 PART=headers

gcc-initial: gmp mpfr mpc isl zlib libiconv binutils
	$(MAKE) -C $(PACKAGEDIR)/gcc STAGE=initial
else
mingw-w64-headers: dir-prep mingw-w64-tools
	$(MAKE) -C $(PACKAGEDIR)/mingw-w64 PART=headers
endif

mingw-w64-winpthreads: mingw-w64-crt
	$(MAKE) -C $(PACKAGEDIR)/mingw-w64 PART=winpthreads

gcc-final: zlib libiconv binutils mingw-w64-crt mingw-w64-winpthreads
	$(MAKE) -C $(PACKAGEDIR)/gcc STAGE=final

mingw-w64-libraries: gcc-final
	$(MAKE) -C $(PACKAGEDIR)/mingw-w64 PART=libraries

gdb: mpfr expat xz zlib
	$(MAKE) -C $(PACKAGEDIR)/gdb

