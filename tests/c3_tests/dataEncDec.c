#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "crypto/bipbip.h"
#include "malloc/cc_globals.h"
#include "modules/common/ccsimics/cc_encoding.h"

#define DEF_ADDR_KEY_BYTES                                                     \
    {                                                                          \
        0xd1, 0xbe, 0x2c, 0xdb, 0xb5, 0x82, 0x4d, 0x03, 0x17, 0x5c, 0x25,      \
                0x2a, 0x20, 0xb6, 0xf2, 0x93, 0xfd, 0x01, 0x96, 0xe7, 0xb5,    \
                0xe6, 0x88, 0x1c, 0xb3, 0x69, 0x22, 0x60, 0x38, 0x09, 0xf6,    \
                0x68                                                           \
    }

int main() {

    CCPointerEncoding enc = CCPointerEncoding();

    pointer_key_t addr_key_{.size_ = 32,
                            .bytes_ = DEF_ADDR_KEY_BYTES};

    enc.init_pointer_key(addr_key_.bytes_, addr_key_.size_);

    ptr_metadata_t data_metadata = { 0 };
    data_metadata.size_ = 0b000101;  // 16 B allocation

    char* comparing_data_la = "Hi, C3!";
    char* comparing_data_ca = "S3cr3t!";

    // Make an LA pointer
    char* data = (char*) malloc(8 * sizeof(char));
    char* data_enc = (char*) enc.encode_pointer((uint64_t) data, &data_metadata);
    char* data_dec = (char*) enc.decode_pointer((uint64_t) data_enc);

    printf("Original Address of data (LA) = %016lx\n", (uint64_t) data);
    printf("Encrypted Address of data (CA) = %016lx\n", (uint64_t) data_enc);
    printf("Decrypted Address of data (LA) = %016lx\n", (uint64_t) data_dec);
    printf("\n");

    printf("Write Data using LA: ");
    data[0] = 'H';
    data[1] = 'i';
    data[2] = ',';
    data[3] = ' ';
    data[4] = 'C';
    data[5] = '3';
    data[6] = '!';
    data[7] = (char) 0;
    printf("%s\n", data);

    printf("Read Data using LA: %s\n", data);
    if (0 != strcmp(data, comparing_data_la)) {
        printf("LA -> LA : FAILED\n");
    } else {
        printf("LA -> LA : SUCCESS\n");
    }

    printf("Read Data using CA: ");
    if (0 != strcmp(data_enc, comparing_data_la)) {
        printf("garbled data!\n");
        printf("LA -> CA : SUCCESS\n");
    } else {
        printf("LA -> CA : FAILED\n");
    }

    printf("Write Data using CA: ");
    data_enc[0] = 'S';
    data_enc[1] = '3';
    data_enc[2] = 'c';
    data_enc[3] = 'r';
    data_enc[4] = '3';
    data_enc[5] = 't';
    data_enc[6] = '!';
    data_enc[7] = (char) 0;
    printf("%s\n", data_enc);

    printf("Read Data using CA with the same metadata: %s\n", data_enc);
    if (0 != strcmp(data_enc, comparing_data_ca)) {
        printf("CA -> CA : FAILED\n");
    } else {
        printf("CA -> CA : SUCCESS\n");
    }

    printf("Read Data using LA: ");
    if (0 != strcmp(data, comparing_data_ca)) {
        printf("garbled data!\n");
        printf("CA -> LA : SUCCESS\n");
    } else {
        printf("CA -> LA : FAILED\n");
    }

    ptr_metadata_t data_metadata_2 = { 0 };
    data_metadata_2.size_ = 0b000110;  // 32 B allocation
    char* data_enc2 = (char*) enc.encode_pointer((uint64_t) data, &data_metadata_2);
    char* data_dec2 = (char*) enc.decode_pointer((uint64_t) data_enc2);
    printf("\n");
    printf("Original Address of data (LA) = %016lx\n", (uint64_t) data);
    printf("Encrypted Address of data (CA) = %016lx\n", (uint64_t) data_enc2);
    printf("Decrypted Address of data (LA) = %016lx\n", (uint64_t) data_dec2);
    printf("\n");

    printf("Read Data using CA with the different metadata: ");
    if (0 != strncmp(data_enc2, comparing_data_ca, 8)) {
        printf("garbled data!\n");
        printf("CA1 -> CA2 : SUCCESS\n");
    } else {
        printf("CA1 -> CA2 : FAILED\n");
    }
    
    return 0;

}
