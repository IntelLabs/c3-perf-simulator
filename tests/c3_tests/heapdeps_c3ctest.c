// microbenchmark: do a lot of tight mem-dep operations

#include <stdint.h>
#include <stdlib.h>

#define N 100000

int main() {
        volatile uint32_t* arr = calloc(N, sizeof(uint32_t));

        // fibonacci in-memory.
        // underflows are UB, but that's not the point

        arr[0] = 1;
        arr[1] = 1;
        for (uint32_t i = 2; i < N; i++) {
                arr[i] = arr[i-1] + arr[i-2];
        }

        return 0;
}
