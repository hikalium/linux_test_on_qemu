# linux_test_on_qemu

```
sudo apt install build-essential qemu bison flex libelf-dev libssl-dev ccache
# Make sure ccache is properly set up
git clone https://github.com/hikalium/linux_test_on_qemu.git
cd linux_test_on_qemu
git submodule init
git submodule update
make busybox
make
```

## qemu-kvm
```
sudo apt install qemu-kvm
usermod -aG kvm hikalium
```
