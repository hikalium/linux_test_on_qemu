SRCS=pi.c pi.S

pi : $(SRCS) Makefile
	$(CC) -Wall -Wpedantic -static -nostdlib -emain -o $@ $(SRCS)
