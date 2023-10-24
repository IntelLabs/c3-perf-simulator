/*
 * Cache-friendly heap benchmark for C3 testing purposes.
 * First, calloc an array of n uint32_t's.
 * Then increment every element n times.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define N 10000

int main() {
  volatile uint32_t* arr = (uint32_t*) calloc(N,sizeof(uint32_t));
  if (arr == NULL) exit(1);  // make sure we actually alloc!
  while (arr[N-1] < N) {
    for (uint32_t i = 0; i < N; i++) {
      ((uint32_t volatile*) arr)[i] = arr[i] + 1;
    }
  }
  //printf("Finished benchmark.\n");
  return 0;
}
