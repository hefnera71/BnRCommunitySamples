#ifndef SHA1_H
#define SHA1_H

#ifdef __cplusplus
extern "C" {
#endif

#include <inttypes.h>
#include <string.h>

#define HASH_LENGTH 20
#define BLOCK_LENGTH 64

void init(void *context);
void initHmac(void *context, const uint8_t* secret, uint8_t secretLength);
uint8_t* result(void *context);
uint8_t* resultHmac(void *context);
void write(void *context, uint8_t data);
void writeArray(void *context, uint8_t *buffer, uint8_t size);

#ifdef __cplusplus
}
#endif

#endif /* SHA1_H */
