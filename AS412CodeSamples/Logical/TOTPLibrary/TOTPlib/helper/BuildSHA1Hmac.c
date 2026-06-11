
#include "BuildSHA1Hmac.h"

// generate a sha1 hmac out of 2 strings 
uint32_t getSha1Hmac(uint8_t* hmacKey, uint8_t keyLength, uint8_t* hmacMessage, uint8_t messageLength, uint8_t* hashResult, uint8_t resultSize)
{
	if (resultSize == SHA1_BLOCK_SIZE)
	{
		initHmac(hmacKey, keyLength);
		writeArray(hmacMessage, messageLength);
		uint8_t* _hash = resultHmac(); 
		memcpy(hashResult, _hash, 20);
		return 0;
	}
	else
	{
		return -1;
	}
}

// show hash as hex-coded ASCII string
signed long sha1HmacToHexString(unsigned char* pIn, unsigned char* pHex)
{
	unsigned int i;
	unsigned char in;
	for (i = 0; i < SHA1_BLOCK_SIZE; i++)
	{
		/* lower nibble*/
		in = *(pIn + i) & 0xF;
		if (in < 0xA)
			*(pHex + 2*i + 1) = in + ASCII_OFFSET_09;
		else
			*(pHex + 2*i + 1) = in + ASCII_OFFSET_AF - 0xA;

		/* higher nibble*/
		in = *(pIn + i) >> 4;
		if (in < 0xA)
			*(pHex + 2*i) = in + ASCII_OFFSET_09;
		else
			*(pHex + 2*i) = in + ASCII_OFFSET_AF - 0xA;
	}
	return 0;
}

