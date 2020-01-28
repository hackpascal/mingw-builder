
CONFIGURE_ARGS += \
	--disable-plugins \
	--disable-libstdcxx-pch \
	--enable-libgomp \
	--enable-libssp \
	--enable-libmudflap \
	--enable-libatomic \
	--enable-libvtv \
	--enable-libquadmath \
	--enable-lto \
	--enable-largefile \
	--enable-shared \
	--enable-static \
	--enable-nls \
	--enable-tls \
	--enable-checking=release \
	--enable-libstdcxx-debug \
	--enable-libstdcxx-time=yes \
	--enable-languages=c,c++,lto \
	--enable-threads=$(THREAD_MODEL)

