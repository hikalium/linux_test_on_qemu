#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <sys/ptrace.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define PR_ENABLE_NDCKPT 57
// int prctl(PR_ENABLE_NDCKPT, 0 or restore object id, 0, 0, 0);
#define PTRACE_DO_NDCKPT 0x6b63
// int ptrace(PTRACE_DO_NDCKPT, target_pid, NULL, 0);

int target_pid;

static void TimerHandler(int signum) {
  int err;
  err = ptrace(PTRACE_INTERRUPT, target_pid, NULL, NULL);
  if (err) printf("Parent: PTRACE_INTERRUPT: FAILED\n");
}

static void StartCheckpointTimer(int timer_interval_ms) {
  struct sigaction action;
  struct itimerval timer;

  memset(&action, 0, sizeof(action));
  action.sa_handler = TimerHandler;
  action.sa_flags = SA_RESTART;
  sigemptyset(&action.sa_mask);
  if (sigaction(SIGALRM, &action, NULL) < 0) {
    perror("sigaction error");
    exit(1);
  }

  /* set intarval timer (10ms) */
  timer.it_value.tv_sec = timer_interval_ms / 1000;
  timer.it_value.tv_usec = timer_interval_ms % 1000 * 1000;
  timer.it_interval.tv_sec = timer.it_value.tv_sec;
  timer.it_interval.tv_usec = timer.it_value.tv_usec;
  if (setitimer(ITIMER_REAL, &timer, NULL) < 0) {
    perror("setitimer error");
    exit(1);
  }
}

static int LaunchPersistentProcessInBackground(const char *path, char *argv[],
                                               int obj_id,
                                               int ckpt_interval_ms) {
  target_pid = fork();
  if (target_pid == 0) {
    prctl(PR_SET_PDEATHSIG, SIGTERM);
    int result = prctl(PR_ENABLE_NDCKPT, obj_id, 0, 0, 0);
    if (result) {
      perror("ndckpt: prctl(PR_ENABLE_NDCKPT, ...)");
    } else {
      printf("ndckpt: prctl(PR_ENABLE_NDCKPT, ...): success\n");
    }
    execve(path, argv, NULL);
    perror("ndckpt");
    return 1;
  } else if (target_pid < 0) {
    printf("Parent: Fork FAILED! retv=%d\n", target_pid);
    perror("ndckpt");
    return 1;
  }
  printf("Parent: Forked! child pid= %d\n", target_pid);
  if (ckpt_interval_ms > 0) {
    int err;
    err = ptrace(PTRACE_SEIZE, target_pid, NULL, 0);
    printf("Parent: PTRACE_SEIZE: %s\n", err == 0 ? "success" : "FAILED");
    if (err) exit(EXIT_FAILURE);
    StartCheckpointTimer(ckpt_interval_ms);
  }
  printf("Parent: wait...\n");
  while (1) {
    int status;
    pid_t wait_pid = waitpid(target_pid, &status, WUNTRACED);
    if (WIFEXITED(status)) {
      int retv = WEXITSTATUS(status);
      printf("Parent: child exited! child pid=%d, child retv=%d\n", wait_pid,
             retv);
      break;
    }
    if (WIFSTOPPED(status)) {
      int err;
      if (WSTOPSIG(status) == SIGTRAP) {
        // Stopped by ptrace. Request checkpointing via ptrace.
        err = ptrace(PTRACE_DO_NDCKPT, target_pid, NULL, 0);
        if (err) printf("Parent: PTRACE_DO_NDCKPT: FAILED\n");
      }
      err = ptrace(PTRACE_CONT, target_pid, NULL, 0);
      if (err) printf("Parent: PTRACE_CONT: FAILED\n");
      continue;
    }
    printf("Parent: unhandled wait done! child status=0x%08X\n", status);
    exit(EXIT_FAILURE);
  }
  return 0;
}

int main(int argc, char *argv[]) {
  if (argc == 2 && strcmp(argv[1], "init") == 0) {
    return system(
        "if [ -f '/sys/kernel/ndckpt/init' ]; then echo '1' > "
        "/sys/kernel/ndckpt/init; fi");
  }
  if (argc == 2 && strcmp(argv[1], "info") == 0) {
    return system(
        "if [ -f '/sys/kernel/ndckpt/info' ]; then cat "
        "/sys/kernel/ndckpt/info; fi");
  }
  if (argc >= 4 && strcmp(argv[1], "run") == 0) {
    return LaunchPersistentProcessInBackground(argv[3], &argv[3], 0,
                                               strtol(argv[2], NULL, 10));
  }
  if (argc >= 4 && strcmp(argv[1], "restore") == 0) {
    return LaunchPersistentProcessInBackground(argv[3], &argv[3], 1,
                                               strtol(argv[2], NULL, 10));
  }
  puts(
      "ndckpt init                      # init pmem (This will destroy all "
      "data in pmem0!)");
  puts("ndckpt info                      # show last saved process info");
  puts(
      "ndckpt run <interval_ms> <path_to_bin>         # run as persistent "
      "process");
  puts(
      "ndckpt restore <interval_ms> <path_to_bin>     # restore last "
      "persistent process");
  return 0;
}
