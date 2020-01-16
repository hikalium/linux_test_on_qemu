PORT_SERIAL=1235
PORT_MONITOR=1240

VNC_PASSWORD=a

default: bzImage initrd.img

.FORCE : 

busybox : .FORCE
	wget https://busybox.net/downloads/busybox-1.30.1.tar.bz2
	tar -xvf busybox-1.30.1.tar.bz2
	cd busybox-1.30.1 && make defconfig && make CONFIG_STATIC=y install -j8

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
	
pi : .FORCE
	make -C pi

initrd.img : initrd.cpio
	cat initrd.cpio | gzip > $@

initrd.cpio : ndckpt/ndckpt pi .FORCE
	mkdir -p initrd_root
	cp -r busybox-1.30.1/_install/* initrd_root/
	cp -rv dist/* initrd_root/
	cp ndckpt/ndckpt initrd_root/bin/
	cp pi/pi*.bin initrd_root/bin/
	cp test/*.bin initrd_root/bin/
	cd initrd_root && find ./* | cpio --quiet -H newc -o > ../$@
	# cpio -itv < $@

BZIMAGE_PATH=linux-hikalium/arch/x86_64/boot/bzImage
QEMU_ARGS = \
			-bios bios64.bin \
			-kernel $(BZIMAGE_PATH) \
			-append "nokaslr console=ttyS0" \
			-initrd initrd.img \
			-machine q35,nvdimm -cpu host --enable-kvm -smp 4 \
			-monitor stdio \
			-monitor telnet:127.0.0.1:$(PORT_MONITOR),server,nowait \
			-m 8G,slots=2,maxmem=10G \
			-device nvdimm,id=nvdimm1,memdev=mem1 \
			-serial tcp::$(PORT_SERIAL),server,nowait \
			-vnc :0,password \
			-device qemu-xhci -device usb-mouse -device usb-kbd

QEMU_ARGS_FILE_BACKEND = \
			$(QEMU_ARGS) \
			-object memory-backend-file,id=mem1,share=on,mem-path=pmem.img,size=2G

QEMU_ARGS_PMEM_BACKEND = \
			$(QEMU_ARGS) \
			-object memory-backend-file,id=mem1,share=on,mem-path=/mnt/pmem0_ext4/pmem.img,size=2G

QEMU_ARGS_WITH_GDB = $(QEMU_ARGS_PMEM_BACKEND) -s -S

run : initrd.img pmem.img
	( echo 'change vnc password $(VNC_PASSWORD)' | while ! nc localhost 1240 ; do sleep 1 ; done ) &
	qemu-system-x86_64 $(QEMU_ARGS_PMEM_BACKEND)

run_dram : initrd.img pmem.img
	( echo 'change vnc password $(VNC_PASSWORD)' | while ! nc localhost 1240 ; do sleep 1 ; done ) &
	qemu-system-x86_64 $(QEMU_ARGS_FILE_BACKEND)

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

format:
	cd linux-hikalium/drivers/ndckpt && clang-format -i *.c *.h

commit: format
	git add . && git diff HEAD --color=always | less -R && git commit && git push

commit_linux: format
	cd linux-hikalium && git add . && git diff HEAD --color=always | less -R && git commit && git push

deploy:
	mkdir -p ~/linux-hikalium/
	cp linux-hikalium/arch/x86_64/boot/bzImage ~/linux-hikalium/hikalium-vmlinux
	cp initrd.img ~/linux-hikalium/hikalium-initrd.img

install:
	make deploy
	ssh xopus402 'cp ~/linux-hikalium/* /boot/ && sync && sync && sync && echo OK && sudo reboot'

reboot:
	ssh xopus402 'sudo reboot'

reset:
	/home4/hikalium/SMCIPMITool_2.22.0_build.190701_bundleJRE_Linux_x64/SMCIPMITool 192.168.4.112 ADMIN ADMIN ipmi power reset

sol:
	/home4/hikalium/SMCIPMITool_2.22.0_build.190701_bundleJRE_Linux_x64/SMCIPMITool 192.168.4.112 ADMIN ADMIN sol activate

