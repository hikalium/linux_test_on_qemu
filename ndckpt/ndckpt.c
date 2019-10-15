#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  pid_t fork_pid = fork();
  if(fork_pid == 0){
    puts("Hello from child");
    printf("  my pid is %d\n", getpid());
    puts("  loop forever...");
    for(;;){
    
    }
    return 0;
  } else if(fork_pid < 0){
    printf("Parent: Fork FAILED! retv=%d\n", fork_pid);
  }
  printf("Parent: Forked! child pid=%d\n", fork_pid);
  int child_retv;
  pid_t wait_pid = wait(&child_retv);
  printf("Parent: wait done! child pid=%d, child retv=%d\n", wait_pid, child_retv);

  return 0;
}
