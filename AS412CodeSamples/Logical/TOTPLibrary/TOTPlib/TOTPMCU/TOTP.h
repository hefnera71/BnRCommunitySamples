#include <inttypes.h>

void TOTP(uint8_t* hmacKey, uint8_t keyLength, uint32_t timeStep);
uint32_t getCodeFromTimestamp(uint32_t timeStamp);
uint32_t getCodeFromSteps(uint32_t steps);
