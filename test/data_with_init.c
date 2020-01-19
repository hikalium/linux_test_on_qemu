#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

volatile uint64_t data[5][512] = {{0}, {1}, {2}, {3}, {4}};

int main() {
  for (volatile uint64_t n = 0;; n++) {
    for (uint64_t i = 0; i < 5; i++) {
      if (data[i][0] != (i + n))
        return 1;
    }
    for (uint64_t i = 0; i < 5; i++) {
      data[i][0]++;
    }
  }
  return 0;
}
