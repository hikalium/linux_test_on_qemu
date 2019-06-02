
default: initrd.img

.FORCE : 

initrd.img : initrd.cpio
	cat initrd.cpio | gzip > $@
initrd.cpio : .FORCE
	cd initrd_root && find ./* | cpio --quiet -H newc -o > ../$@
	cpio -itv < $@

BZIMAGE_PATH=../linux-stable/arch/x86_64/boot/bzImage
run : initrd.img
	qemu-system-x86_64 \
		-bios bios64.bin \
		-kernel $(BZIMAGE_PATH) \
		-append "console=ttyS0 init=/hello" \
		-initrd initrd.img \
		-machine q35,nvdimm -cpu qemu64 -smp 4 \
		-monitor stdio \
		-m 8G,slots=2,maxmem=10G \
		-serial tcp::1234,server,nowait
clean:
	-rm initrd.img
	-rm initrd.cpio
