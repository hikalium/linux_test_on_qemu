SRCS=pi.c pi.S

default: pi15000.bin pi30000.bin pi_with_ckpt_15000.bin pi_with_ckpt_30000.bin

pi%.bin : $(SRCS) Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -Ddigits=$* -o $@ $(SRCS)

pi_with_ckpt_%.bin : $(SRCS) Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -O3 -emain -Ddigits=$* -DCALL_NDCKPT_VIA_SYSCALL -o $@ $(SRCS)
