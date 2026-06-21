// Copyright (c) 2026 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details

#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

#include "TOTPlib.h"
#include <ArCert.h>
#include <AsTime.h>
#include <string.h>
#include <inttypes.h>
#include "./TOTPMCU/TOTP.h"
#include "./helper/Base32.h"
#include "./helper/BuildSHA1Hmac.h"

#ifdef __cplusplus
	};
#endif

#define _OTP_CODEVALID_DURATION 30
#define _CACTUALM2 0
#define _CACTUALM1 1
#define _CACTUAL 2
#define _CACTUALP1 3
#define _CACTUALP2 4
#define _MAX_INSTRING_LEN 32
 // as I'm using strcat below, salt has to be of len = 8 + 1, last byte has to be zero !!!
#define _SALT_LEN 8
char _SALT_ID1[_SALT_LEN + 1] = {'V','8','N','?','4','g','R','+', 0};
char _SALT_ID2[_SALT_LEN + 1] = {'k','7','R','d','!','=','f','Y', 0};

char id2Buffer[_MAX_INSTRING_LEN + _SALT_LEN + 1] =	{0};
char id1Buffer[_MAX_INSTRING_LEN + _SALT_LEN + 1] =	{0};
char sha1result[20]  = {0};

char secret[41] = {0};
char b32secret[128] = {0};
UDINT otpcodes[5] = {0};
char otpauthLink[256] = {0};

DTStructure certVFrom = {0};
DTStructure certVTo = {0};

ArCertGetOwnDetails_typ readCert = {0};
UtcDTGetTime_typ readUTC = {0};

	
/* TODO: Add your comment here */
void VerifyTOTPCode(struct VerifyTOTPCode* inst)
{
	if (inst->enable == 1 && inst->last == 0)
	{
		inst->status = 0xFFFF;
		inst->statusID = 0;
		inst->codeValid = 0;
		inst->phase = 0;

		// inititalize some internal memory
		memset(id1Buffer, 0, sizeof(id1Buffer));
		memset(id2Buffer, 0, sizeof(id2Buffer));
		memset(b32secret, 0, sizeof(b32secret));
		memset(otpauthLink, 0, sizeof(otpauthLink));
		memset(otpcodes, 0, sizeof(otpcodes));
		memset(&certVFrom, 0, sizeof(certVFrom));
		memset(&certVTo, 0, sizeof(certVTo));
		memset(&readCert, 0, sizeof(readCert));
		memset(&readUTC, 0, sizeof(readUTC));
		
		// copy id1
		if (strlen((char*)inst->pId1) <= _MAX_INSTRING_LEN)
		{
			strcpy(id1Buffer, (char*)inst->pId1);
		}
		else
		{
			memcpy(id1Buffer, (char*)inst->pId1, _MAX_INSTRING_LEN);
			memset(&id1Buffer[_MAX_INSTRING_LEN], 0, 1);
		}
		// check the usage of id2
		if (inst->id2IsOwnCertificate == 1)
		{
			inst->step = 1;
		}
		else
		{
			// 2nd id is not a certificate name but a own string, so copy that into the buffer for secret generation used below
			strcpy(id2Buffer, (char*)inst->pId2);
			if (strlen((char*)inst->pId2) <= _MAX_INSTRING_LEN)
			{
				strcpy(id2Buffer, (char*)inst->pId2);
			}
			else
			{
				memcpy(id2Buffer, (char*)inst->pId2, _MAX_INSTRING_LEN);
				memset(&id2Buffer[_MAX_INSTRING_LEN], 0, 1);
			}
			

			inst->step = 10;
		}
	}
	
	if (inst->enable == 0 && inst->last == 1)
	{
		inst->status = 0xFFFE;
		inst->step = 0;
		inst->codeValid = 0;
		inst->phase = 0;
	}

	switch (inst->step)
	{
	
		case 1: // read certificate if needed
			// user uses a own certificate as part of the secret, so we have to read it here
			if (strlen((char*)inst->pId2) > 0)
			{
				if (strlen((char*)inst->pId2) <= _MAX_INSTRING_LEN)
				{
					strcpy(readCert.Name, (char*)inst->pId2);
				}
				else
				{
					memcpy(readCert.Name, (char*)inst->pId2, _MAX_INSTRING_LEN);
					memset(&readCert.Name + _MAX_INSTRING_LEN, 0, 1);
				}
				readCert.Index = 0;
				readCert.Execute = 1;
				inst->step = 2;
			}
			else
			{
				inst->status = 55555;
				inst->step = 0;
			}
			inst->phase = 1;
			break;
		
		case 2:
			if (readCert.Busy == 0)
			{
				if (readCert.Done == 1)
				{
					// copy the certificate serial number in internbal buffer used for secret generation
					strcpy(id2Buffer, readCert.Details.SerialNumber);
					// copy validity infos
					memcpy(&certVFrom, &readCert.Details.ValidFrom, sizeof(certVFrom));
					memcpy(&certVTo, &readCert.Details.ValidTo, sizeof(certVTo));
					inst->step = 10;
				}
				else
				{
					// error reading cert
					inst->statusID = readCert.StatusID;
					inst->status = 55556;
					inst->step = 0;
				}
				// deactivate FB !!!
				readCert.Execute = 0;
			}
			inst->phase = 1;
			break;
		
		
		case 10: // build secret
			// salt in1 = user string
			strcat(id1Buffer, _SALT_ID1);
			// salt idBuffer = in2 = certificate serial number or user string
			strcat(id2Buffer, _SALT_ID2);
			// build SHA1 HMAC out of in1 and in2
			getSha1Hmac((uint8_t*)id2Buffer, strlen(id2Buffer), (uint8_t*)id1Buffer, strlen(id1Buffer), (uint8_t*)sha1result, sizeof(sha1result));
			// present hash as hex string and !!!use this hex coded hash as secret!!!
			sha1HmacToHexString((uint8_t*)sha1result, (uint8_t*)secret);
			// encode hex string = secret to base32
			base32_encode(secret, strlen(secret), (char*)b32secret);
			// build otpauth link
			strcpy(otpauthLink, "otpauth://totp/");
			strcat(otpauthLink, inst->otpauthLabel);
			strcat(otpauthLink, "?secret=");
			strcat(otpauthLink, b32secret);
			
			inst->step = 11;
			inst->phase = 2;
			break;
			
		case 11: // calculate codes
			readUTC.enable = 1;
			UtcDTGetTime(&readUTC);

			// reset code validitiy
			inst->codeValid = 0;

			if (readUTC.status == 0)
			{
				// get seconds until 01.01.1970
				uint32_t ts;
				memcpy(&ts, &readUTC.DT1, 4);
			
				UINT sec = _OTP_CODEVALID_DURATION;
				// if value > 30, use the user setting for code valid time
				if (inst->validity > _OTP_CODEVALID_DURATION)
					sec = inst->validity;
				// build the TOTP key, which is is valid for xx seconds 
				TOTP((uint8_t*)secret, (uint8_t)strlen(secret), _OTP_CODEVALID_DURATION);
				// calculate codes out of key
				// code actual
				otpcodes[_CACTUAL] = getCodeFromTimestamp(ts);
				// code actual - xx * 2 seconds
				otpcodes[_CACTUALM2] = getCodeFromTimestamp(ts - sec * 2);
				// code actual - xx seconds
				otpcodes[_CACTUALM1] = getCodeFromTimestamp(ts - sec);
				// code actual + xx seconds
				otpcodes[_CACTUALP1] = getCodeFromTimestamp(ts + sec);
				// code actual + xx * 2 seconds
				otpcodes[_CACTUALP2] = getCodeFromTimestamp(ts + sec * 2);
			
			
				UDINT c = inst->code;
				switch (inst->tolerance)
				{
					
					case 1:
						// accept actual & +/-30
						if (c == otpcodes[_CACTUAL] || c == otpcodes[_CACTUALP1] || c == otpcodes[_CACTUALM1])
							inst->codeValid = 1;
						else
							inst->codeValid = 0;
						break;
					case 2:
						// accept actual & +/-30 & +/-60
						if (c == otpcodes[_CACTUAL] || c == otpcodes[_CACTUALP1] || c == otpcodes[_CACTUALM1] || c == otpcodes[_CACTUALP2] || c == otpcodes[_CACTUALM2])
							inst->codeValid = 1;
						else
							inst->codeValid = 0;
						break;
					default:
						// precision is zero or has invalid number -> use the most secure one
						if (c == otpcodes[_CACTUAL])
							inst->codeValid = 1;
						else
							inst->codeValid = 0;
						break;
				}
			}
			else
			{
				// error reading UTC
				inst->status = 55557;
				inst->step = 0;
			}
			inst->phase = 3;
			break;
			
	
	}

	// call FB
	ArCertGetOwnDetails(&readCert);

	// update outputs
	inst->pOtpSharedB32S = (UDINT)&b32secret;
	inst->pOtpauthLink = (UDINT)&otpauthLink;
	inst->pCertValidFrom = (UDINT)&certVFrom;
	inst->pCertValidTo = (UDINT)&certVTo;

	// store state for edge detection
	inst->last = inst->enable;


}
