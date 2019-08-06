PORT_SERIAL=1235
PORT_MONITOR=1240

VNC_PASSWORD=a

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
QEMU_ARGS = \
			-bios bios64.bin \
			-kernel $(BZIMAGE_PATH) \
			-append "console=ttyS0 nokaslr" \
			-initrd initrd.img \
			-machine q35,nvdimm -cpu host --enable-kvm -smp 4 \
			-monitor stdio \
			-monitor telnet:127.0.0.1:$(PORT_MONITOR),server,nowait \
			-m 8G,slots=2,maxmem=10G \
			-object memory-backend-file,id=mem1,share=on,mem-path=pmem.img,size=2G \
			-device nvdimm,id=nvdimm1,memdev=mem1 \
			-serial tcp::$(PORT_SERIAL),server,nowait \
			-vnc :0,password

QEMU_ARGS_WITH_GDB = $(QEMU_ARGS) -s -S

run : initrd.img pmem.img
	( echo 'change vnc password $(VNC_PASSWORD)' | while ! nc localhost 1240 ; do sleep 1 ; done ) &
	qemu-system-x86_64 $(QEMU_ARGS)

run_gdb : initrd.img pmem.img
	( echo 'change vnc password $(VNC_PASSWORD)' | while ! nc localhost 1240 ; do sleep 1 ; done ) &
	qemu-system-x86_64 $(QEMU_ARGS_WITH_GDB)

clean:
	-rm initrd.img
	-rm initrd.cpio

gdb:
	gdb -ex 'target remote :1234' linux-hikalium/vmlinux
	
serial:
	while ! telnet localhost $(PORT_SERIAL) ; do sleep 1 ; done ;

monitor:
	telnet localhost $(PORT_MONITOR)
