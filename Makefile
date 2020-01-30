
export TOPDIR:=$(CURDIR)
export DLDIR:=$(TOPDIR)/dl
export OUTPUTDIR:=$(TOPDIR)/output
export BUILDDIR:=$(TOPDIR)/build
export PACKAGEDIR:=$(TOPDIR)/package

export HOST_CFLAGS:=-ffunction-sections -fdata-sections -fno-ident
export HOST_LDFLAGS:=-Wl,--gc-sections

export TARGET_CFLAGS:=$(HOST_CFLAGS)
export TARGET_LDFLAGS:=$(HOST_LDFLAGS)

export HOSTCC ?= gcc

export SYSROOT_NAME:=sysroot

ifneq ($(wildcard $(TOPDIR)/.config),)

include $(TOPDIR)/.config

export GCC_ARCH:=$(strip $(shell $(HOSTCC) --print-multiarch 2>/dev/null))

ifeq ($(BUILD),)
# you can copy config.guess to TOPDIR manually
export BUILD:=$(strip $(shell $(TOPDIR)/config.guess 2>/dev/null))
ifeq ($(BUILD),)
export BUILD:=$(GCC_ARCH)
endif
endif

all: dirs target
	true

dirs:
	mkdir -p $(DLDIR)

target: toolchain
ifeq ($(strip $(NO_TARGET)),)
	$(MAKE) -f build.mk BUILD_TYPE=target
else
	true
endif

toolchain:
	$(MAKE) -f build.mk BUILD_TYPE=toolchain

target_%:
ifeq ($(strip $(NO_TARGET)),)
	$(MAKE) -f build.mk BUILD_TYPE=target $(@:target_%=%)
endif

toolchain_%:
	$(MAKE) -f build.mk BUILD_TYPE=toolchain $(@:toolchain_%=%)

else
all:
	echo "Missing configure file!"
	false

endif

clean:
	-rm -rf $(BUILDDIR)

dirclean: clean
	-rm -rf $(OUTPUTDIR)

distclean: dirclean
	-rm -rf $(DLDIR)

.PHONY: clean dirclean distclean


