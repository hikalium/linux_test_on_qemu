#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define SIZE (1024 * 1024)

int main() {
  volatile uint64_t *arr = malloc(SIZE * sizeof(uint64_t));
  for (int n = 0;; n++) {
    for (int i = 0; i < SIZE; i++) {
      arr[i] = n;
    }
    for (int i = 0; i < SIZE; i++) {
      if (arr[i] != n)
        return 1;
    }
  }
  return 0;
}
