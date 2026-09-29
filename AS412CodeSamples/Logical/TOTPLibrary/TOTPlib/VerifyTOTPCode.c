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
const char _SALT_ID1[_SALT_LEN + 1] = {'V','8','N','?','4','g','R','+', 0};
const char _SALT_ID2[_SALT_LEN + 1] = {'k','7','R','d','!','=','f','Y', 0};

	
/* TODO: Add your comment here */
void VerifyTOTPCode(struct VerifyTOTPCode* inst)
{
	if (inst->enable == 1 && inst->internal.last == 0)
	{
		inst->status = 0xFFFF;
		inst->statusID = 0;
		inst->codeValid = 0;
		inst->phase = 0;

		// inititalize some internal memory
		memset(inst->internal.id1Buffer, 0, sizeof(inst->internal.id1Buffer));
		memset(inst->internal.id2Buffer, 0, sizeof(inst->internal.id2Buffer));
		memset(inst->internal.sha1result, 0, sizeof(inst->internal.sha1result));
		memset(inst->internal.secret, 0, sizeof(inst->internal.secret));
		memset(inst->internal.b32secret, 0, sizeof(inst->internal.b32secret));
		memset(inst->internal.otpauthLink, 0, sizeof(inst->internal.otpauthLink));
		memset(inst->internal.otpcodes, 0, sizeof(inst->internal.otpcodes));
		memset(&inst->internal.certVFrom, 0, sizeof(inst->internal.certVFrom));
		memset(&inst->internal.certVTo, 0, sizeof(inst->internal.certVTo));
		memset(&inst->internal.readCert, 0, sizeof(inst->internal.readCert));
		memset(&inst->internal.readUTC, 0, sizeof(inst->internal.readUTC));
		memset(&inst->internal.sha1Context, 0, sizeof(inst->internal.sha1Context));
		
		// copy id1
		if (strlen((char*)inst->pId1) <= _MAX_INSTRING_LEN)
		{
			strcpy((char*)inst->internal.id1Buffer, (char*)inst->pId1);
		}
		else
		{
			memcpy(inst->internal.id1Buffer, (char*)inst->pId1, _MAX_INSTRING_LEN);
			memset(&inst->internal.id1Buffer[_MAX_INSTRING_LEN], 0, 1);
		}
		// check the usage of id2
		if (inst->id2IsOwnCertificate == 1)
		{
			inst->internal.step = 1;
		}
		else
		{
			// 2nd id is not a certificate name but a own string, so copy that into the buffer for secret generation used below
			if (strlen((char*)inst->pId2) <= _MAX_INSTRING_LEN)
			{
				strcpy((char*)inst->internal.id2Buffer, (char*)inst->pId2);
			}
			else
			{
					memcpy(inst->internal.id2Buffer, (char*)inst->pId2, _MAX_INSTRING_LEN);
					memset(&inst->internal.id2Buffer[_MAX_INSTRING_LEN], 0, 1);
			}
			

			inst->internal.step = 10;
		}
	}
	
	if (inst->enable == 0 && inst->internal.last == 1)
	{
		inst->status = 0xFFFE;
		inst->internal.step = 0;
		inst->codeValid = 0;
		inst->phase = 0;
	}

	switch (inst->internal.step)
	{
	
		case 1: // read certificate if needed
			// user uses a own certificate as part of the secret, so we have to read it here
			if (strlen((char*)inst->pId2) > 0)
			{
				if (strlen((char*)inst->pId2) <= _MAX_INSTRING_LEN)
				{
					strcpy(inst->internal.readCert.Name, (char*)inst->pId2);
				}
				else
				{
					memcpy(inst->internal.readCert.Name, (char*)inst->pId2, _MAX_INSTRING_LEN);
					memset(&inst->internal.readCert.Name[_MAX_INSTRING_LEN], 0, 1);
				}
				inst->internal.readCert.Index = 0;
				inst->internal.readCert.Execute = 1;
				inst->internal.step = 2;
			}
			else
			{
				inst->status = 55555;
				inst->internal.step = 0;
			}
			inst->phase = 1;
			break;
		
		case 2:
			if (inst->internal.readCert.Busy == 0)
			{
				if (inst->internal.readCert.Done == 1)
				{
					// copy the certificate serial number in internbal buffer used for secret generation
					strcpy((char*)inst->internal.id2Buffer, inst->internal.readCert.Details.SerialNumber);
					// copy validity infos
					memcpy(&inst->internal.certVFrom, &inst->internal.readCert.Details.ValidFrom, sizeof(inst->internal.certVFrom));
					memcpy(&inst->internal.certVTo, &inst->internal.readCert.Details.ValidTo, sizeof(inst->internal.certVTo));
					inst->internal.step = 10;
				}
				else
				{
					// error reading cert
					inst->statusID = inst->internal.readCert.StatusID;
					inst->status = 55556;
					inst->internal.step = 0;
				}
				// deactivate FB !!!
				inst->internal.readCert.Execute = 0;
			}
			inst->phase = 1;
			break;
		
		
		case 10: // build secret
			// salt in1 = user string
			strcat((char*)inst->internal.id1Buffer, _SALT_ID1);
			// salt idBuffer = in2 = certificate serial number or user string
			strcat((char*)inst->internal.id2Buffer, _SALT_ID2);
			// build SHA1 HMAC out of in1 and in2
			getSha1Hmac(&inst->internal.sha1Context, inst->internal.id2Buffer, strlen((char*)inst->internal.id2Buffer), inst->internal.id1Buffer, strlen((char*)inst->internal.id1Buffer), inst->internal.sha1result, sizeof(inst->internal.sha1result));
			// present hash as hex string and !!!use this hex coded hash as secret!!!
			sha1HmacToHexString(inst->internal.sha1result, inst->internal.secret);
			// encode hex string = secret to base32
			base32_encode((char*)inst->internal.secret, strlen((char*)inst->internal.secret), (char*)inst->internal.b32secret);
			// build otpauth link
			strcpy((char*)inst->internal.otpauthLink, "otpauth://totp/");
			strcat((char*)inst->internal.otpauthLink, inst->otpauthLabel);
			strcat((char*)inst->internal.otpauthLink, "?secret=");
			strcat((char*)inst->internal.otpauthLink, (char*)inst->internal.b32secret);
			
			inst->internal.step = 11;
			inst->phase = 2;
			break;
			
		case 11: // calculate codes
			inst->internal.readUTC.enable = 1;
			UtcDTGetTime(&inst->internal.readUTC);

			// reset code validitiy
			inst->codeValid = 0;

			if (inst->internal.readUTC.status == 0)
			{
				// get seconds until 01.01.1970
				uint32_t ts;
				memcpy(&ts, &inst->internal.readUTC.DT1, 4);
			
				UINT sec = _OTP_CODEVALID_DURATION;
				// if value > 30, use the user setting for code valid time
				if (inst->validity > _OTP_CODEVALID_DURATION)
					sec = inst->validity;
				// build the TOTP key, which is is valid for xx seconds 
				inst->internal.otpcodes[_CACTUAL] = getCodeFromTimestamp(&inst->internal.sha1Context, inst->internal.secret, (uint8_t)strlen((char*)inst->internal.secret), _OTP_CODEVALID_DURATION, ts);
				// code actual - xx * 2 seconds
				inst->internal.otpcodes[_CACTUALM2] = getCodeFromTimestamp(&inst->internal.sha1Context, inst->internal.secret, (uint8_t)strlen((char*)inst->internal.secret), _OTP_CODEVALID_DURATION, ts - sec * 2);
				// code actual - xx seconds
				inst->internal.otpcodes[_CACTUALM1] = getCodeFromTimestamp(&inst->internal.sha1Context, inst->internal.secret, (uint8_t)strlen((char*)inst->internal.secret), _OTP_CODEVALID_DURATION, ts - sec);
				// code actual + xx seconds
				inst->internal.otpcodes[_CACTUALP1] = getCodeFromTimestamp(&inst->internal.sha1Context, inst->internal.secret, (uint8_t)strlen((char*)inst->internal.secret), _OTP_CODEVALID_DURATION, ts + sec);
				// code actual + xx * 2 seconds
				inst->internal.otpcodes[_CACTUALP2] = getCodeFromTimestamp(&inst->internal.sha1Context, inst->internal.secret, (uint8_t)strlen((char*)inst->internal.secret), _OTP_CODEVALID_DURATION, ts + sec * 2);
			
			
				UDINT c = inst->code;
				switch (inst->tolerance)
				{
					
					case 1:
						// accept actual & +/-30
						if (c == inst->internal.otpcodes[_CACTUAL] || c == inst->internal.otpcodes[_CACTUALP1] || c == inst->internal.otpcodes[_CACTUALM1])
							inst->codeValid = 1;
						else
							inst->codeValid = 0;
						break;
					case 2:
						// accept actual & +/-30 & +/-60
						if (c == inst->internal.otpcodes[_CACTUAL] || c == inst->internal.otpcodes[_CACTUALP1] || c == inst->internal.otpcodes[_CACTUALM1] || c == inst->internal.otpcodes[_CACTUALP2] || c == inst->internal.otpcodes[_CACTUALM2])
							inst->codeValid = 1;
						else
							inst->codeValid = 0;
						break;
					default:
						// precision is zero or has invalid number -> use the most secure one
						if (c == inst->internal.otpcodes[_CACTUAL])
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
				inst->internal.step = 0;
			}
			inst->phase = 3;
			break;
			
	
	}

	// call FB
	ArCertGetOwnDetails(&inst->internal.readCert);

	// update outputs
	inst->pOtpSharedB32S = (UDINT)inst->internal.b32secret;
	inst->pOtpauthLink = (UDINT)inst->internal.otpauthLink;
	inst->pCertValidFrom = (UDINT)&inst->internal.certVFrom;
	inst->pCertValidTo = (UDINT)&inst->internal.certVTo;

	// store state for edge detection
	inst->internal.last = inst->enable;


}
