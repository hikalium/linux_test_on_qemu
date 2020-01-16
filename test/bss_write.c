int bss_data;
extern void exit(int);  // @syscall.S
int main(){
  while(bss_data == 0){bss_data = 0;}
  exit(1);
}
