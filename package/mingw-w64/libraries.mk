
libmangle: extract
	$(MAKE) -C libraries -f $@.mk

pseh: extract
	$(MAKE) -C libraries -f $@.mk

winstorecompat: extract
	$(MAKE) -C libraries -f $@.mk

install: libmangle $(if $(findstring x86_64,$(TARGET)),,pseh) winstorecompat
	true

