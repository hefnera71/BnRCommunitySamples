
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details


#include <bur/plctypes.h>
#include <asbrstr.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "xtea.h"
#ifdef __cplusplus
	};
#endif


#define ASCII_OFFSET_09	0x30
#define ASCII_OFFSET_AF	0x61

// encode data to ascii coded hex string
signed long UsintToHex (unsigned char* pIn, unsigned char* pHex, unsigned long lenIn, unsigned long lenHex)
{
	unsigned int i;
	unsigned char in;
	
	for (i = 0; i < lenIn; i++)
	{
		// lower nibble
		in = *(pIn + i) & 0xF;
		if (in < 0xA)
			*(pHex + 2*i + 1) = in + ASCII_OFFSET_09;
		else
			*(pHex + 2*i + 1) = in + ASCII_OFFSET_AF - 0xA;

		// higher nibble
		in = *(pIn + i) >> 4;
		if (in < 0xA)
			*(pHex + 2*i) = in + ASCII_OFFSET_09;
		else
			*(pHex + 2*i) = in + ASCII_OFFSET_AF - 0xA;
	}
	return 0;
}
// decode data from ascii coded hex string
signed long HexToUsint (unsigned char* pHex, unsigned char* pOut, unsigned long lenHex, unsigned long lenOut)
{
	unsigned int i = 0, j = 0;
	unsigned char in1, in2;
	
	for (i = 0; i < lenHex; i+=2)
	{
		// higher nibble
		in1 = *(pHex + i);
		if (in1 < ASCII_OFFSET_AF)
			in1 = (in1 - ASCII_OFFSET_09) << 4;
		else
			in1 = (in1 - ASCII_OFFSET_AF + 0xA) << 4;

		// lower nibble
		in2 = *(pHex + i + 1);
		if (in2 < ASCII_OFFSET_AF)
			in2 = in2 - ASCII_OFFSET_09;
		else
			in2 = in2 - ASCII_OFFSET_AF + 0xA;
		
		*(pOut + j) = in1 + in2;
		j++;
	}
	return 0;
}


#define NUMBER_ROUNDS 32

// encrypt --> based on the xtea reference algorithm https://de.wikipedia.org/wiki/Extended_Tiny_Encryption_Algorithm
void encipher (unsigned int num_cycles, unsigned long v[2], unsigned long const k[4]) {
	unsigned int i;
	const unsigned long delta = 0x9E3779B9;
	unsigned long v0 = v[0], v1 = v[1], sum = 0;
	for (i=0; i < num_cycles; i++) {
		v0 += (((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + k[sum & 3]);
		sum += delta;
		v1 += (((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + k[(sum>>11) & 3]);
	}
	v[0] = v0; v[1] = v1;
}
// decrypt --> based on the xtea reference algorithm https://de.wikipedia.org/wiki/Extended_Tiny_Encryption_Algorithm
void decipher (unsigned int num_cycles, unsigned long v[2], unsigned long const k[4]) {
	unsigned int i;
	const unsigned long delta = 0x9E3779B9;
	unsigned long v0 = v[0], v1 = v[1], sum = delta * num_cycles;
	for (i=0; i < num_cycles; i++) {
		v1 -= (((v0 << 4) ^ (v0 >> 5)) + v0) ^ (sum + k[(sum>>11) & 3]);
		sum -= delta;
		v0 -= (((v1 << 4) ^ (v1 >> 5)) + v1) ^ (sum + k[sum & 3]);
	}
	v[0] = v0; v[1] = v1;
}

/* encrypt / decrypt data, optionally also with encode / decode data to ascii-coded hex (for better usability when data has to be stored / loaded) */
long xteaencdec(unsigned char mode, unsigned long pIn, unsigned long lenIn, unsigned long pOut, unsigned long lenOut, unsigned long pKey, unsigned long lenKey)
{
	unsigned long key[4], v[2];
	unsigned long i = 0, k = 0, len = 0;
	unsigned char hex[16];
	
	if (lenKey != sizeof(key))
	{
		return xteaERROR_WRONGKEYSIZE;
	}

	switch (mode)
	{
		// lenOut has to be greater then lenIn an % 8 = 0 because of block cipher !!
		case xteaMODE_ENCRYPT:
			if (lenOut < lenIn) return xteaERROR_OUTBLOCKTOOSMALL;
			if (lenOut % 8 != 0) return xteaERROR_WRONGOUTBLOCKSIZE;
			break;
		// lenOut has to double greater then lenIn an % 8 = 0 because of block cipher !!
		case xteaMODE_ENCRYPT_TO_HEX:
			if (lenOut < lenIn * 2) return xteaERROR_OUTBLOCKTOOSMALL;
			if (lenOut % 8 != 0) return xteaERROR_WRONGOUTBLOCKSIZE;
			break;
		// lenIn has to be % 8 = 0, lenOut has to bee at least as big as lenIn
		case xteaMODE_DECRYPT:
				if (lenIn % 8 != 0) return xteaERROR_WRONGINBLOCKSIZE;
				if (lenOut < lenIn) return xteaERROR_OUTBLOCKTOOSMALL;
			break;
		// lenIn has to be % 8 = 0, lenOut has to bee at least half as big as lenIn
		case xteaMODE_DECRYPT_FROM_HEX:
			if (lenIn % 8 != 0) return xteaERROR_WRONGINBLOCKSIZE;
			if (lenOut < lenIn / 2) return xteaERROR_OUTBLOCKTOOSMALL;
			break;

		default:
			return xteaERROR_UNKNOWNMODE;
			break;
	}
	
	// if code reached this position, we haven't found any problems with the input parameters	
	// copy key
	brsmemcpy((UDINT)key, pKey, lenKey);
	
	// be aware, that one of the modes has a double sized input buffer!!
	if (mode == xteaMODE_DECRYPT_FROM_HEX)
	{
		k = lenIn / 2;
	}
	else
	{
		k = lenIn;
	}
	
	// do the blockwise en-/de- coding/-cryption
	for (i = 0; i < k; i += sizeof(v))
	{
		// initialize v
		v[0] = 0;
		v[1] = 0;

		// copy input data mode dependent
		if (mode != xteaMODE_DECRYPT_FROM_HEX)
		{
			// don't copy too much if input len not % 8
			if (lenIn - i < sizeof(v)) len = lenIn - i; else len = sizeof(v);
			// copy input data to vector
			brsmemcpy((UDINT)v, pIn + i, len);
		}
		else
		{
			// initialize hex
			brsmemcpy((UDINT)hex, pIn + i*2, sizeof(hex));
		}
		
		switch (mode)
		{
			case xteaMODE_ENCRYPT:
				// encrypt
				encipher(NUMBER_ROUNDS, v, key);
				brsmemcpy(pOut + i, (UDINT)v, sizeof(v));
				break;
			case xteaMODE_DECRYPT:
				// decrypt
				decipher(NUMBER_ROUNDS, v, key);
				brsmemcpy(pOut + i, (UDINT)v, sizeof(v));
				break;
			case xteaMODE_ENCRYPT_TO_HEX:
				// encrypt
				encipher(NUMBER_ROUNDS, v, key);
				// encode to hex string
				UsintToHex((unsigned char*)v, &hex[0], sizeof(v), sizeof(hex));
				brsmemcpy(pOut + i*2, (UDINT)&hex[0], sizeof(hex));
				break;
			case xteaMODE_DECRYPT_FROM_HEX:
				// decode hex string
				HexToUsint(hex, (unsigned char*)v, sizeof(hex), sizeof(v));
				// decrypt
				decipher(NUMBER_ROUNDS, v, key);
				brsmemcpy(pOut + i, (UDINT)v, sizeof(v));
				break;
		}
	}

	return xteaOK;
}

