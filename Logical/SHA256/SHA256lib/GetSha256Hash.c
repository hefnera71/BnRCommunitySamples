
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "sha256.h"
	#include "SHA256lib.h"
#ifdef __cplusplus
	};
#endif

// **********************************************
// HELPER function - show hash as hex-coded ASCII string
//
#define ASCII_OFFSET_09	0x30
#define ASCII_OFFSET_AF	0x61
signed long UsintToHex (unsigned char* pIn, unsigned char* pHex)
{
	unsigned int i;
	unsigned char in;
	for (i = 0; i < SHA256_BLOCK_SIZE; i++)
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

// **********************************************
// wrapper for the sha256 hash function calls
//
signed long GetSha256Hash(unsigned long pData, unsigned long lenData, plcstring* hash)
{
	signed long result = 0;
	SHA256_CTX ctx;
	BYTE buf[SHA256_BLOCK_SIZE];

	if (pData == 0 || lenData == 0)
		return -1;
	
	sha256_init(&ctx);
	sha256_update(&ctx, (void*)pData, (size_t)lenData);
	sha256_final(&ctx, buf);
	
	UsintToHex(buf, (unsigned char*)hash);
	
	return result;
	
}



