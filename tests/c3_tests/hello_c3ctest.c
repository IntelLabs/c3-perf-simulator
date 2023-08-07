#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * To compile:
 *
 * gcc -L {glibc-2.30_install}/lib -I {glibc-2.30_install}/include \
 * -Wl,--rpath={glibc-2.30_install}/lib \
 * -Wl,--dynamic-linker={glibc-2.30_install}/lib/ld-linux-x86-64.so.2 \
 * -o hello_c3 \
 * hello_c3.c
 *
 * where {glibc-2.30_install} is built by the c3-simulator repo.
 *
 * Invoke the subsequent binary with the environment variable CC_ENABLED=1
 * and malloc will issue ccencptr instructions. (these are illegal insts
 * outside the simulator!)
*/

int main() {
    volatile char* hello = (char*) malloc(4 * sizeof(char));
    volatile char* goodbye = (char*) malloc(5 * sizeof(char));

    printf("Array 1 @ %016lx\n", (uint64_t) hello);
    printf("Array 2 @ %016lx\n", (uint64_t) goodbye);

    hello[0] = 'H';
    hello[1] = 'i';
    hello[2] = '!';
    hello[3] = (char) 0;

    goodbye[0] = 'B';
    goodbye[1] = 'y';
    goodbye[2] = 'e';
    goodbye[3] = '!';
    goodbye[4] = (char) 0;

    // now access the CAs
    printf("%s\n", hello);
    printf("%s\n", goodbye);
    return 0;
}
