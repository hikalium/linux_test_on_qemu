default: test_reg.bin bss_write.bin hello_libc_static.bin nop_libc_static.bin mmap.bin

%.bin : %.S Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -o $@ $*.S

bss_write.bin : bss_write.c syscall.S Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -o $@ bss_write.c syscall.S

%.bin : %.c Makefile
	$(CC) -Wall -Wpedantic -static -fno-pie -O3 -o $@ $*.c

clean :
	-rm *.bin
