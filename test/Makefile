default: test_reg.bin

%.bin : %.S Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -o $@ $*.S

clean :
	-rm *.bin
