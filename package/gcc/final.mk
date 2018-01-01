
CONFIGURE_ARGS += \
	--enable-lto \
	--disable-plugins \
	--enable-largefile \
	--enable-shared \
	--enable-static \
	--enable-nls \
	--enable-tls \
	--enable-libstdcxx-debug \
	--enable-libstdcxx-time=yes \
	--enable-languages=c,c++,lto \
	--enable-threads=$(THREAD_MODEL)

