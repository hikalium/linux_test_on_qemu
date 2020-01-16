find . \
	-path ./linux-hikalium -prune -o \
	-path './busybox-*' -prune -o \
	\( -name \*.c -or -name \*.h \) \
	-exec clang-format -verbose -i {} \;
