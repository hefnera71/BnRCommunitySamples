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
#include <SYS_lib.h>
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

#define _STEP_IDLE 0
#define _STEP_READCERT 1
#define _STEP_READCERT2 2
#define _STEP_BUILDSECRET 10
#define _STEP_CALCCODES 11

 // as I'm using strcat below, salt has to be of len = 8 + 1, last byte has to be zero !!!
#define _SALT_LEN 8
const char _SALT_ID1[_SALT_LEN + 1] = {'V','8','N','?','4','g','R','+', 0};
const char _SALT_ID2[_SALT_LEN + 1] = {'k','7','R','d','!','=','f','Y', 0};

	
/* TODO: Add your comment here */
void VerifyTOTPCode(struct VerifyTOTPCode* inst)
{
	int tmpState = 0;
	
	// internal instance data in allocated mem -> has to be updated cyclicly!!!
	totplib_intinst_typ* allocInst = 0;
	if (inst->internal.pInternal > 0)
	{
		allocInst = (totplib_Internal_typ*)inst->internal.pInternal;
	}

	// edge pos
	if (inst->enable == 1 && inst->internal.last == 0)
	{
		inst->status = 0xFFFF;
		inst->statusID = 0;
		inst->codeValid = 0;
		inst->phase = 0;
		
		// JUST AS TEST RIGHT NOW! NOT FUNCTIONAL!!
		tmpState = TMP_alloc(sizeof(totplib_intinst_typ), &inst->internal.pInternal);
		if (tmpState != 0)
		{
			// error allocation memory!
			inst->internal.pInternal = 0;
			inst->status = tmpState;
		}
		else
		{
			allocInst = (totplib_Internal_typ*)inst->internal.pInternal;

			// inititalize some internal memory
			memset(allocInst->id1Buffer, 0, sizeof(allocInst->id1Buffer));
			memset(allocInst->id2Buffer, 0, sizeof(allocInst->id2Buffer));
			memset(allocInst->sha1result, 0, sizeof(allocInst->sha1result));
			memset(allocInst->secret, 0, sizeof(allocInst->secret));
			memset(allocInst->b32secret, 0, sizeof(allocInst->b32secret));
			memset(allocInst->otpauthLink, 0, sizeof(allocInst->otpauthLink));
			memset(allocInst->otpcodes, 0, sizeof(allocInst->otpcodes));
			memset(&allocInst->certVFrom, 0, sizeof(allocInst->certVFrom));
			memset(&allocInst->certVTo, 0, sizeof(allocInst->certVTo));
			memset(&allocInst->readCert, 0, sizeof(allocInst->readCert));
			memset(&allocInst->readUTC, 0, sizeof(allocInst->readUTC));
			memset(&allocInst->sha1Context, 0, sizeof(allocInst->sha1Context));
		
			// copy id1
			if (strlen((char*)inst->pId1) <= _MAX_INSTRING_LEN)
			{
				strcpy((char*)allocInst->id1Buffer, (char*)inst->pId1);
			}
			else
			{
				memcpy(allocInst->id1Buffer, (char*)inst->pId1, _MAX_INSTRING_LEN);
				memset(&allocInst->id1Buffer[_MAX_INSTRING_LEN], 0, 1);
			}
			// check the usage of id2
			if (inst->id2IsOwnCertificate == 1)
			{
				inst->internal.step = _STEP_READCERT;
			}
			else
			{
				// 2nd id is not a certificate name but a own string, so copy that into the buffer for secret generation used below
				if (strlen((char*)inst->pId2) <= _MAX_INSTRING_LEN)
				{
					strcpy((char*)allocInst->id2Buffer, (char*)inst->pId2);
				}
				else
				{
					memcpy(allocInst->id2Buffer, (char*)inst->pId2, _MAX_INSTRING_LEN);
					memset(&allocInst->id2Buffer[_MAX_INSTRING_LEN], 0, 1);
				}
			

				inst->internal.step = _STEP_BUILDSECRET;
			}
		}
	}
	
	if (inst->enable == 0 && inst->internal.last == 1)
	{
		
		// JUST AS TEST RIGHT NOW! NOT FUNCTIONAL!!
		if (inst->internal.pInternal > 0)
		{
			tmpState = TMP_free(sizeof(totplib_intinst_typ), inst->internal.pInternal);
			if (tmpState != 0)
			{
				// error deallocating memory -> mem leak!
				inst->status = tmpState;
			}
			else
			{
				inst->status = 0xFFFE;
			}
			inst->internal.pInternal = 0;
		}
		else
		{
			// there was an error before when allocating
			inst->status = 0xFFFE;
		}
		
		inst->internal.step = _STEP_IDLE;
		inst->codeValid = 0;
		inst->phase = 0;
	}

	if (inst->internal.pInternal > 0)
	{	
		switch (inst->internal.step)
		{
	
			case _STEP_READCERT: // read certificate if needed
				// user uses a own certificate as part of the secret, so we have to read it here
				if (strlen((char*)inst->pId2) > 0)
				{
					if (strlen((char*)inst->pId2) <= _MAX_INSTRING_LEN)
					{
						strcpy(allocInst->readCert.Name, (char*)inst->pId2);
					}
					else
					{
						memcpy(allocInst->readCert.Name, (char*)inst->pId2, _MAX_INSTRING_LEN);
						memset(&allocInst->readCert.Name[_MAX_INSTRING_LEN], 0, 1);
					}
					allocInst->readCert.Index = 0;
					allocInst->readCert.Execute = 1;
					inst->internal.step = _STEP_READCERT2;
				}
				else
				{
					inst->status = totplib_errEMPTYPARAM;
					inst->internal.step = _STEP_IDLE;
				}
				inst->phase = 1;
				break;
		
			case _STEP_READCERT2:
				if (allocInst->readCert.Busy == 0)
				{
					if (allocInst->readCert.Done == 1)
					{
						// copy the certificate serial number in internbal buffer used for secret generation
						strcpy((char*)allocInst->id2Buffer, allocInst->readCert.Details.SerialNumber);
						// copy validity infos
						memcpy(&allocInst->certVFrom, &allocInst->readCert.Details.ValidFrom, sizeof(allocInst->certVFrom));
						memcpy(&allocInst->certVTo, &allocInst->readCert.Details.ValidTo, sizeof(allocInst->certVTo));
						inst->internal.step = _STEP_BUILDSECRET;
					}
					else
					{
						// error reading cert
						inst->statusID = allocInst->readCert.StatusID;
						inst->status = totplib_errREADCERT;
						inst->internal.step =_STEP_IDLE;
					}
					// deactivate FB !!!
					allocInst->readCert.Execute = 0;
				}
				inst->phase = 1;
				break;
		
		
			case _STEP_BUILDSECRET: // build secret
				// salt in1 = user string
				strcat((char*)allocInst->id1Buffer, _SALT_ID1);
				// salt idBuffer = in2 = certificate serial number or user string
				strcat((char*)allocInst->id2Buffer, _SALT_ID2);
				// build SHA1 HMAC out of in1 and in2
				getSha1Hmac(&allocInst->sha1Context, allocInst->id2Buffer, strlen((char*)allocInst->id2Buffer), allocInst->id1Buffer, strlen((char*)allocInst->id1Buffer), allocInst->sha1result, sizeof(allocInst->sha1result));
				// present hash as hex string and !!!use this hex coded hash as secret!!!
				sha1HmacToHexString(allocInst->sha1result, allocInst->secret);
				// encode hex string = secret to base32
				base32_encode((char*)allocInst->secret, strlen((char*)allocInst->secret), (char*)allocInst->b32secret);
				// build otpauth link
				strcpy((char*)allocInst->otpauthLink, "otpauth://totp/");
				strcat((char*)allocInst->otpauthLink, inst->otpauthLabel);
				strcat((char*)allocInst->otpauthLink, "?secret=");
				strcat((char*)allocInst->otpauthLink, (char*)allocInst->b32secret);
			
				inst->internal.step = _STEP_CALCCODES;
				inst->phase = 2;
				break;
			
			case  _STEP_CALCCODES: // calculate codes
				allocInst->readUTC.enable = 1;
				UtcDTGetTime(&allocInst->readUTC);

				// reset code validitiy
				inst->codeValid = 0;

				if (allocInst->readUTC.status == 0)
				{
					// get seconds until 01.01.1970
					uint32_t ts;
					memcpy(&ts, &allocInst->readUTC.DT1, 4);
			
					UINT sec = _OTP_CODEVALID_DURATION;
					// if value > 30, use the user setting for code valid time
					if (inst->validity > _OTP_CODEVALID_DURATION)
						sec = inst->validity;
					// build the TOTP key, which is is valid for xx seconds 
					allocInst->otpcodes[_CACTUAL] = getCodeFromTimestamp(&allocInst->sha1Context, allocInst->secret, (uint8_t)strlen((char*)allocInst->secret), _OTP_CODEVALID_DURATION, ts);
					// code actual - xx * 2 seconds
					allocInst->otpcodes[_CACTUALM2] = getCodeFromTimestamp(&allocInst->sha1Context, allocInst->secret, (uint8_t)strlen((char*)allocInst->secret), _OTP_CODEVALID_DURATION, ts - sec * 2);
					// code actual - xx seconds
					allocInst->otpcodes[_CACTUALM1] = getCodeFromTimestamp(&allocInst->sha1Context, allocInst->secret, (uint8_t)strlen((char*)allocInst->secret), _OTP_CODEVALID_DURATION, ts - sec);
					// code actual + xx seconds
					allocInst->otpcodes[_CACTUALP1] = getCodeFromTimestamp(&allocInst->sha1Context, allocInst->secret, (uint8_t)strlen((char*)allocInst->secret), _OTP_CODEVALID_DURATION, ts + sec);
					// code actual + xx * 2 seconds
					allocInst->otpcodes[_CACTUALP2] = getCodeFromTimestamp(&allocInst->sha1Context, allocInst->secret, (uint8_t)strlen((char*)allocInst->secret), _OTP_CODEVALID_DURATION, ts + sec * 2);
			
			
					UDINT c = inst->code;
					switch (inst->tolerance)
					{
					
						case 1:
							// accept actual & +/-30
							if (c == allocInst->otpcodes[_CACTUAL] || c == allocInst->otpcodes[_CACTUALP1] || c == allocInst->otpcodes[_CACTUALM1])
								inst->codeValid = 1;
							else
								inst->codeValid = 0;
							break;
						case 2:
							// accept actual & +/-30 & +/-60
							if (c == allocInst->otpcodes[_CACTUAL] || c == allocInst->otpcodes[_CACTUALP1] || c == allocInst->otpcodes[_CACTUALM1] || c == allocInst->otpcodes[_CACTUALP2] || c == allocInst->otpcodes[_CACTUALM2])
								inst->codeValid = 1;
							else
								inst->codeValid = 0;
							break;
						default:
							// precision is zero or has invalid number -> use the most secure one
							if (c == allocInst->otpcodes[_CACTUAL])
								inst->codeValid = 1;
							else
								inst->codeValid = 0;
							break;
					}
				}
				else
				{
					// error reading UTC
					inst->status = totplib_errREADRTC;
					inst->internal.step = _STEP_IDLE;
				}
				inst->phase = 3;
				break;
			
	
		}
		// call FB
		ArCertGetOwnDetails(&allocInst->readCert);

		// update outputs
		inst->pOtpSharedB32S = (UDINT)allocInst->b32secret;
		inst->pOtpauthLink = (UDINT)allocInst->otpauthLink;
		inst->pCertValidFrom = (UDINT)&allocInst->certVFrom;
		inst->pCertValidTo = (UDINT)&allocInst->certVTo;
	}
	// store state for edge detection
	inst->internal.last = inst->enable;


}
