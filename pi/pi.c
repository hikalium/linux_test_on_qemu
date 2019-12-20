// based on: http://xn--w6q13e505b.jp/program/spigot.html

#include <stdint.h>

typedef unsigned int size_t;
int write(int fd, const void*, size_t);
void exit(int);
void ndckpt_checkpoint(void);

void printf04d(int v) {
  char s[4];
  for (int i = 0; i < 4; i++) {
    s[3 - i] = v % 10 + '0';
    v /= 10;
  }
  write(1, s, 4);
}
#ifndef digits
#define digits 15000
#endif

#define EXPECT0 3141
#define EXPECT1 5926

#if digits == 30000
#define EXPECT2 4510
#define EXPECT3 8247
#elif digits == 15000
#define EXPECT2 8427
#define EXPECT3 9927
#endif

#define base 10000
int64_t nume[digits / 4 * 14 + 14];
int result[digits / 4];

void CalcPi() {
  int64_t i;
  int64_t n;
  int64_t digit;
  int64_t denom;
  int64_t out_count = 0;
  int64_t carry = 0;
  int64_t first = 0;

  for (n = digits / 4 * 14; n > 0; n -= 14) {
    carry %= base;
    digit = carry;
    for (i = n - 1; i > 0; --i) {
      denom = 2 * i - 1;
      carry = carry * i + base * (first ? nume[i] : (base / 5));
      nume[i] = carry % denom;
      carry /= denom;
    }
    first = 1;
    if ((out_count & 0xff) == 0){
      ndckpt_checkpoint();
      write(1, ".", 1);
    }
    result[out_count++] = digit + carry / base;
  }
}

void Verify() {
  write(1, " ", 1);
  printf04d(result[0]);
  printf04d(result[1]);
  write(1, " ... ", 5);
  printf04d(result[digits / 4 - 2]);
  printf04d(result[digits / 4 - 1]);
  write(1, (result[0] == EXPECT0 && result[1] == EXPECT1 && result[digits / 4 - 2] == EXPECT2 && result[digits / 4 - 1] == EXPECT3) ? " OK" : " NG", 3);
  write(1, "\n", 1);
}

int main() {
  for (int i = 0; i < 10; i++) {
    printf04d(i);
    write(1, ": ", 2);
    CalcPi();
    Verify();
  }
  exit(0);
  return 0;
}
