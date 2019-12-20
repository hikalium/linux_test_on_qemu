SRCS=pi.c pi.S

default: pi15000.bin pi30000.bin

pi%.bin : $(SRCS) Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -Ddigits=$* -o $@ $(SRCS)
