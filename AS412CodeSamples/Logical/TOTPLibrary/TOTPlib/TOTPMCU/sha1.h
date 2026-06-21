#ifndef SHA1_H
#define SHA1_H

#ifdef __cplusplus
extern "C" {
#endif

#include <inttypes.h>
#include <string.h>

#define HASH_LENGTH 20
#define BLOCK_LENGTH 64

void init(void);
void initHmac(const uint8_t* secret, uint8_t secretLength);
uint8_t* result(void);
uint8_t* resultHmac(void);
void write(uint8_t);
void writeArray(uint8_t *buffer, uint8_t size);

#ifdef __cplusplus
}
#endif

#endif /* SHA1_H */
