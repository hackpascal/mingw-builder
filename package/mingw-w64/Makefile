
NAME=mingw-w64
VERSION=v5.0.3
SOURCE_FILE=$(NAME)-$(VERSION).tar.bz2
URL=https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/$(SOURCE_FILE)/download

export MINGW_W64_SOURCE_DIR=$(BUILD_SOURCE_DIR)/$(NAME)-$(VERSION)
export MINGW_W64_BUILD_DIR=$(BUILD_DIR)/$(NAME)-$(VERSION)
export NAME


all: install
	true

download:
	[ -f $(DLDIR)/$(SOURCE_FILE) ] || wget -O $(DLDIR)/$(SOURCE_FILE) $(URL) || (rm -f $(DLDIR)/$(SOURCE_FILE) && false)

extract: download
	[ -f $(MINGW_W64_SOURCE_DIR)/.extracted ] || ( \
		mkdir -p $(MINGW_W64_SOURCE_DIR); \
		tar -jxf $(DLDIR)/$(SOURCE_FILE) -C $(HOST_SOURCE_DIR) && \
		for f in $$(ls ./patches/*.patch ./patches/*.diff); do patch -d $(MINGW_W64_SOURCE_DIR) -p1 < $$f; done; \
		touch $(MINGW_W64_SOURCE_DIR)/.extracted \
	)

include $(PART).mk

