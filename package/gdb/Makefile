
NAME=gdb
VERSION=8.3.1
SOURCE_FILE=$(NAME)-$(VERSION).tar.xz
URL=https://ftp.gnu.org/gnu/$(NAME)/$(SOURCE_FILE)

PACKAGE_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
PACKAGE_BUILD_DIR=$(BUILD_DIR)/$(NAME)-$(VERSION)

CONFIGURE_ARGS= \
	--prefix=$(PREFIX) \
	--target=$(TARGET) \
	$(if $(HOST),--host=$(HOST)) \
	--enable-nls \
	--with-system-zlib \
	--with-gmp=$(HOST_OUTPUT_PREFIX) \
	--with-mpfr=$(HOST_OUTPUT_PREFIX) \
	--with-mpc=$(HOST_OUTPUT_PREFIX) \
	--with-isl=$(HOST_OUTPUT_PREFIX)

LIBS_CFLAGS := -I$(HOST_OUTPUT_PREFIX)/include
LIBS_LDFLAGS := -L$(HOST_OUTPUT_PREFIX)/lib

ifeq ($(BUILD_TYPE),target)
PKG_CFLAGS= -fstack-protector
PKG_CXXFLAGS= -fstack-protector
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
		ln -sf $(PACKAGE_SOURCE_DIR); \
		CFLAGS="$(PKG_CFLAGS) $(LIBS_CFLAGS)" \
		CXXFLAGS="$(PKG_CXXFLAGS) $(LIBS_CFLAGS)" \
		LDFLAGS="$(PKG_LDFLAGS) $(LIBS_LDFLAGS)" \
		LIBS="$(PKG_LIBS)" \
		$(HOST_CONFIGURE_ENVS) \
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
		$(MAKE) -C $(PACKAGE_BUILD_DIR) install-gdb DESTDIR=$(INSTALL_DESTDIR) && \
		touch $(PACKAGE_BUILD_DIR)/.installed \
	)

force-install: build
	$(MAKE) -C $(PACKAGE_BUILD_DIR) install

