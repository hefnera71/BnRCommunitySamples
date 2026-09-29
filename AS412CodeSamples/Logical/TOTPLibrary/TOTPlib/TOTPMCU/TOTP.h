#ifndef TOTP_H
#define TOTP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <inttypes.h>
#include "sha1.h"

uint32_t getCodeFromTimestamp(void *context, uint8_t* hmacKey, uint8_t keyLength, uint32_t timeStep, uint32_t timeStamp);
uint32_t getCodeFromSteps(void *context, uint8_t* hmacKey, uint8_t keyLength, uint32_t steps);


#ifdef __cplusplus
}
#endif

#endif /* TOTP_H */
