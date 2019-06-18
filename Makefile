
default: bzImage initrd.img

.FORCE : 

bzImage : .FORCE
	cp kernel_config_v5.1.8.txt linux-hikalium/.config
	export CCACHE_DIR=/home/hikalium/.ccache && time make -C linux-hikalium CC="ccache gcc" -j11

modules : .FORCE
	make -j11 -C linux-hikalium modules
	make -j11 INSTALL_MOD_PATH=`readlink -f initrd_root` -C linux-hikalium modules_install

pmem.img :
	qemu-img create $@ 2G


ndckpt/ndckpt : .FORCE
	make -C ndckpt ndckpt

initrd.img : initrd.cpio
	cat initrd.cpio | gzip > $@
initrd.cpio : ndckpt/ndckpt .FORCE
	cp ndckpt/ndckpt initrd_root/bin/
	cd initrd_root && find ./* | cpio --quiet -H newc -o > ../$@
	# cpio -itv < $@

BZIMAGE_PATH=linux-hikalium/arch/x86_64/boot/bzImage
run : bzImage initrd.img pmem.img
	qemu-system-x86_64 \
		-bios bios64.bin \
		-kernel $(BZIMAGE_PATH) \
		-append "console=ttyS0" \
		-initrd initrd.img \
		-machine q35,nvdimm -cpu qemu64 -smp 4 \
		-monitor stdio \
		-m 8G,slots=2,maxmem=10G \
		-object memory-backend-file,id=mem1,share=on,mem-path=pmem.img,size=2G \
		-device nvdimm,id=nvdimm1,memdev=mem1 \
		-serial tcp::1234,server,nowait
clean:
	-rm initrd.img
	-rm initrd.cpio

telnet:
	telnet localhost 1234
