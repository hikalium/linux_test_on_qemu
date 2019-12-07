#include <stdio.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define PR_ENABLE_NDCKPT 57
// int prctl(PR_ENABLE_NDCKPT, 0 or restore object id, 0, 0, 0);

static int LaunchPersistentProcessInBackground(const char *path, char *argv[], int obj_id) {
  pid_t fork_pid = fork();
  if (fork_pid == 0) {
    int result = prctl(PR_ENABLE_NDCKPT, obj_id, 0, 0, 0);
    if (result) {
      perror("ndckpt: prctl(PR_ENABLE_NDCKPT, ...)");
    } else {
      printf("ndckpt: prctl(PR_ENABLE_NDCKPT, ...): success\n");
    }
    execve(path, argv, NULL);
    perror("ndckpt");
    return 1;
  } else if (fork_pid < 0) {
    printf("Parent: Fork FAILED! retv=%d\n", fork_pid);
    perror("ndckpt");
    return 1;
  }
  printf("Parent: Forked! child pid= %d\n", fork_pid);
  printf("Parent: wait...\n");
  int child_retv;
  pid_t wait_pid = wait(&child_retv);
  printf("Parent: wait done! child pid=%d, child retv=%d\n", wait_pid,
         child_retv);

  return 0;
}

int main(int argc, char *argv[]) {
  if (argc >= 3 && strcmp(argv[1], "run") == 0) {
    return LaunchPersistentProcessInBackground(argv[2], &argv[3], 0);
  }
  if (argc >= 3 && strcmp(argv[1], "restore") == 0) {
    return LaunchPersistentProcessInBackground(argv[2], &argv[3], 1);
  }
  puts("ndckpt run <path_to_bin>    # run as persistent process");
  puts("ndckpt restore <path_to_bin>     # restore last persistent process");
  return 0;
}
