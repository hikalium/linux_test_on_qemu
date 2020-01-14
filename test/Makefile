default: test_reg.bin hello_libc_static.bin nop_libc_static.bin

%.bin : %.S Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -o $@ $*.S

%.bin : %.c Makefile
	$(CC) -Wall -Wpedantic -static -fno-pie -O3 -o $@ $*.c

clean :
	-rm *.bin
