#ifndef BUILDSHA1HMAC_H
#define BUILDSHA1HMAC_H

#ifdef __cplusplus
extern "C" {
#endif

#include <inttypes.h>
#include <string.h>
#include "../TOTPMCU/sha1.h"

#define SHA1_BLOCK_SIZE 20
#define ASCII_OFFSET_09	0x30
#define ASCII_OFFSET_AF	0x61

uint32_t getSha1Hmac(uint8_t* hmacKey, uint8_t keyLength, uint8_t* hmacMessage, uint8_t messageLength, uint8_t* hashResult, uint8_t resultSize);
signed long sha1HmacToHexString(unsigned char* pIn, unsigned char* pHex);

#ifdef __cplusplus
}
#endif

#endif /* BUILDSHA1HMAC_H */
