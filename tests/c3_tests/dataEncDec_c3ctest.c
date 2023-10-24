#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    char *compareString = "DATA!";

    // Make a CA pointer
    volatile char* data = (char*) malloc(6 * sizeof(char));

    printf("Pointer Address for data (CA) = %016lx\n", (uint64_t) data);

    printf("Now store \'DATA!\' into the data variable.\n");
    data = "DATA!";

    // now access the data
    printf("Now access the data variable. Data content = %s\n", data);
    if (strncmp((const char*) data, compareString, strlen(compareString)) != 0) {
        printf("FAILED!\n");
    } else {
        printf("SUCCESS!\n");
    }
    return 0;
}
