
// Copyright (c) 2026 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details

#include <bur/plctypes.h>
#include <AsTime.h>
#include <string.h>
#include "./TOTPMCU/sha1.h"
#include "./TOTPMCU/TOTP.h"
#include "./Base32/Base32.h"

#ifdef _DEFAULT_INCLUDES
	#include <AsDefault.h>
#endif

void _INIT ProgramInit(void)
{

}

void _CYCLIC ProgramCyclic(void)
{

	if (bGenerateCode == 1)
	{
		bGenerateCode = 0;
		
		// this is the shared secret between this code and an external code generator
		// in productive environment, KEEP YOUR KEY SECRET / ENCRYPT IT / DONT SHARE IT VIA PROCESS VARIABLES READABLE ONLINE!
		const char secret[] = "MyVerySecretString";

		// encode secret to Base32 string --> NOT NEEDED FOR THE FUNCTIONALITY HERE, BUT FOR USING EXTERNAL GENERATORS!
		// e.g. "MyVerySecretString" is in Base32: "JV4VMZLSPFJWKY3SMV2FG5DSNFXGO==="
		// in productive environment, KEEP YOUR KEY SECRET / ENCRYPT IT / DONT SHARE IT VIA PROCESS VARIABLES READABLE ONLINE!
		base32_encode(secret, strlen(secret), (char*)sBase32encoded);

		// get the Unix UTC timestamp as base for TOTP RFC 6238
		// for proper functionality, using UTC timestamp is mandatory! Please set your PLC clock properly, e.g. by using NTP client
		UtcDTGetTime_0.enable = 1;
		UtcDTGetTime(&UtcDTGetTime_0);
		uint32_t ts;
		memcpy(&ts, &UtcDTGetTime_0.DT1, 4); 

		// build the key, which is is valid for the value of seconds 
		seconds = 30;
		TOTP((uint8_t*)secret, (uint8_t)strlen(secret), (uint8_t)seconds);
		
		// get the code!!
		myCode = getCodeFromTimestamp(ts);
		
	}
}

void _EXIT ProgramExit(void)
{

}

