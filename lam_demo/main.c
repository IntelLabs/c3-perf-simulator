#include <stdint.h>
#include <stdio.h>

// PoC: store pointer access count in the pointer's upper bits
// (just doing this for char ptrs, for ease of doing it)


uint64_t incr_refs(uint64_t c) {
        // we have 15 bits to store info (62:48)
        uint16_t refs = (c >> 48) & 0x7fff;
        refs++;
        c &= 0x8000ffffffffffff;
        c |= ((uint64_t) refs) << 48;
        return c;
}


#define count_refs(c) ((c >> 48) & 0x7fff)


char* iprintf(char* c) {
        // prints, then returns the pointer as incremented by incr_refs
        printf("%s", c);
        return (char*) incr_refs((uint64_t) c);
}


int main() {
        char* hello = "Hi, LAM48!\n";
        for (int i = 0; i < 10; i++) {
                hello = iprintf(hello);
                printf("\t(Now we've printed it %lu times.)\n",
                        count_refs((uint64_t) hello));
        }
        return 0;
}
