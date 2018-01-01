
libmangle: extract
	$(MAKE) -C tools -f $@.mk

gendef: libmangle
	$(MAKE) -C tools -f $@.mk

genidl: extract
	$(MAKE) -C tools -f $@.mk

genlib: libmangle
	$(MAKE) -C tools -f $@.mk

genpeimg: extract
	$(MAKE) -C tools -f $@.mk

widl: extract
	$(MAKE) -C tools -f $@.mk

install: extract gendef genidl genlib genpeimg widl
	true

