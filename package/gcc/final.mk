
CONFIGURE_ARGS += \
	--disable-plugins \
	--disable-libstdcxx-pch \
	--enable-libgomp \
	--enable-libssp \
	--enable-lto \
	--enable-largefile \
	--enable-shared \
	--enable-static \
	--enable-nls \
	--enable-tls \
	--enable-threads=$(THREAD_MODEL) \
	--enable-checking=release \
	--enable-libstdcxx-debug \
	--enable-libstdcxx-time=yes \
	--enable-languages=c,c++,lto

