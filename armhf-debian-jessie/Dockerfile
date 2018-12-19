FROM arm32v7/debian:jessie

# make arm32v7 container runable on x86
COPY qemu-arm-static /usr/bin

# install needed packages
RUN	apt-get update && \
	apt-get install -y \
		build-essential \
		automake \
		libzmq3-dev \
		libcurl4-openssl-dev \
		liblua5.2-dev \
		libconfig-dev \
		libarchive-dev \
		libjson0-dev \
		zlib1g-dev \
		libncursesw5-dev \
		libncurses5-dev \
		git \
		uuid \
		uuid-dev \
		liblzo2-dev \
		libsystemd-daemon-dev \
		libsystemd-daemon0 \
		check \
		bison \
		flex \
		libssl-dev \
		fakeroot \
		devscripts \
		wget \
		nano \
		pax-utils && \
	ln -sf /usr/lib/arm-linux-gnueabihf/pkgconfig/lua5.2.pc /usr/lib/arm-linux-gnueabihf/pkgconfig/lua.pc && \
	mkdir -p /usr/local/lib && \
	mkdir -p /usr/local/include && \
	mkdir -p /usr/local/include/mtd

ENV BUILD_THREADS 4

ENV MTD_UTILS_URL https://github.com/jneuhauser/mtd-utils/archive/v2.0.2.tar.gz
RUN	wget -O mtd-utils_dl.tar.gz $MTD_UTILS_URL && \
	tar xf mtd-utils_dl.tar.gz && \
	cd mtd-utils-* && \
	./autogen.sh && \
	./configure && \
	make -j$BUILD_THREADS && \
	install -m 644 include/libubi.h /usr/local/include/mtd && \
	install -m 644 include/libmtd.h /usr/local/include/mtd && \
	install -m 644 include/mtd/ubi-media.h /usr/local/include/mtd && \
	install -m 644 *.a /usr/local/lib && \
	cd .. && \
	rm -rf mtd-utils*

ENV EFIBOOTGUARD_URL https://github.com/jneuhauser/efibootguard/archive/v0.4.tar.gz
RUN	wget -O efibootguard_dl.tar.gz $EFIBOOTGUARD_URL && \
	tar xf efibootguard_dl.tar.gz && \
	cd efibootguard-* && \
	autoreconf -fi && \
	./configure && \
	make -j$BUILD_THREADS libebgenv.a && \
	install -m 644 libebgenv.a /usr/local/lib/libebgenv.a && \
	install -m 755 -d /usr/include/efibootguard && \
	install -m 644 include/ebgenv.h /usr/include/efibootguard/ebgenv.h && \
	cd .. && \
	rm -rf efibootguard*

ENV UBOOT_URL https://github.com/jneuhauser/u-boot-imx6qdl/archive/dev/legacy/2018.05_dhcom.tar.gz
RUN	wget -O u-boot_dl.tar.gz $UBOOT_URL && \
	tar xf u-boot_dl.tar.gz && \
	cd u-boot-* && \
	make dh_imx6_defconfig && \
	make -j$BUILD_THREADS envtools && \
	install -m 644 tools/env/lib.a /usr/local/lib/libubootenv.a && \
	install -m 755 tools/env/fw_printenv /usr/local/bin/fw_printenv && \
	ln -sr /usr/local/bin/fw_printenv /usr/local/bin/fw_setenv && \
	cd .. && \
	rm -rf u-boot*

COPY	executables_with_so_to_tar.sh /usr/local/bin/executables_with_so_to_tar

WORKDIR /swupdate
ENTRYPOINT ["/bin/bash"]
