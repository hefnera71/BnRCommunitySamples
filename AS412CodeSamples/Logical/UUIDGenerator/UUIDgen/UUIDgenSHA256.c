// Copyright (c) 2026 Alexander Hefner
//
// Licensed under the MIT License - see LICENSE.txt file for details

// changes
// V2.00.0 initial version 
//  	 				- SHA-256 based Hash_DRBG replacement for Xoshiro256**
//                        - non-linear entropy extraction via SHA-256
//                        - periodic re-seeding
//                        - forward and backward secrecy

#include <bur/plctypes.h>

#ifdef __cplusplus
	extern "C"
	{
#endif

#include <stdint.h>
#include <string.h>
#include <AsTime.h>
#include <standard.h>
#include <AsETH.h>
#include <AsIO.h>
#include <AsIOTime.h>
#include "sha256.h"
#include "UUIDgen.h"

#ifdef __cplusplus
	};
#endif

/* ==========================================================================
   Hash_DRBG per NIST SP 800-90A
   - Uses SHA-256 code from SHA256lib (embedded the code directly to avoid another library dependendcy)
   - State: 32-byte secret key K + 32-byte counter V
   - Provides forward and backward secrecy
   ========================================================================== */

static void drbg_update(uint8_t *K, uint8_t *V, const uint8_t *provided_data, uint32_t provided_len)
{
	SHA256_CTX ctx;
	uint8_t temp[32];

	// temp = SHA-256(V || provided_data)
	sha256_init(&ctx);
	sha256_update(&ctx, V, 32);
	if (provided_data != 0 && provided_len > 0) {
		sha256_update(&ctx, provided_data, provided_len);
	}
	sha256_final(&ctx, temp);
	memcpy(K, temp, 32);

	// V = SHA-256(K)
	sha256_init(&ctx);
	sha256_update(&ctx, K, 32);
	sha256_final(&ctx, V);
}

static void drbg_init(uint8_t *K, uint8_t *V, const uint8_t *entropy, uint32_t entropy_len)
{
	uint8_t seed_material[32 + 64];
	uint32_t sm_len;

	// seed_material = entropy || nonce (nonce = 0 for simplicity)
	sm_len = 0;
	if (entropy != 0 && entropy_len > 0) {
		uint32_t copy = (entropy_len < 64) ? entropy_len : 64;
		memcpy(seed_material, entropy, copy);
		sm_len = copy;
	}
	memset(seed_material + sm_len, 0, 32);
	sm_len += 32;

	// K = 0x00...00, V = 0x00...00
	memset(K, 0, 32);
	memset(V, 0, 32);

	// Update with seed material
	drbg_update(K, V, seed_material, sm_len);
}

static void drbg_reseed(uint8_t *K, uint8_t *V, const uint8_t *entropy, uint32_t entropy_len)
{
	uint8_t seed_material[64];
	uint32_t sm_len;

	sm_len = 0;
	if (entropy != 0 && entropy_len > 0) {
		uint32_t copy = (entropy_len < 64) ? entropy_len : 64;
		memcpy(seed_material, entropy, copy);
		sm_len = copy;
	}

	drbg_update(K, V, seed_material, sm_len);
}

static void drbg_generate(uint8_t *K, uint8_t *V, uint8_t *out, uint32_t out_len)
{
	SHA256_CTX ctx;
	uint8_t block[32];
	uint32_t i;

	while (out_len > 0) {
		// V = V + 1 (big-endian counter increment)
		for (i = 31; i > 0; i--) {
			if (V[i] < 0xFF) {
				V[i]++;
				break;
			} else {
				V[i] = 0;
			}
		}
		if (i == 0) {
			V[0]++;
		}

		// output_block = SHA-256(K || V)
		sha256_init(&ctx);
		sha256_update(&ctx, K, 32);
		sha256_update(&ctx, V, 32);
		sha256_final(&ctx, block);

		// Copy to output
		{
			uint32_t copy = (out_len < 32) ? out_len : 32;
			memcpy(out, block, copy);
			out += copy;
			out_len -= copy;
		}
	}

	// Backwards step - critical for backtracking resistance
	drbg_update(K, V, 0, 0);
}

/* ==========================================================================
   Entropy collection
   - Collects from device serial, RTC, and ethernet statistics
   - Uses SHA-256 as a non-linear entropy extractor
   ========================================================================== */

static uint32_t GetDTSecs(void)
{
	DTGetTime_typ dt;
	dt.enable = 1;
	DTGetTime(&dt);
	if (dt.status == 0)
		return dt.DT1;
	else
		return 0;
}

static void collect_entropy(uuidgensha256Internal_typ *internal, uint8_t *buf, uint32_t *len, uint8_t *fallback)
{
	uint32_t rtc;
	uint32_t offset = 0;

	*fallback = 0;

	// Source 1: device serial + module ID (constant, but provides device-uniqueness)
	memcpy(buf + offset, &internal->serial, sizeof(internal->serial));
	offset += sizeof(internal->serial);

	// Source 2: RTC (changes per boot, low but real entropy)
	rtc = GetDTSecs();
	memcpy(buf + offset, &rtc, sizeof(rtc));
	offset += sizeof(rtc);

	// Source 3: ethernet statistics (real entropy when network is active)
	if (internal->bytesRecv > 0) {
		memcpy(buf + offset, &internal->bytesRecv, sizeof(internal->bytesRecv)); ;
		offset += sizeof(internal->bytesRecv);
	} else {
		// Fallback: no network entropy available
		// RTC alone provides boot-time variation
		*fallback = 1;
	}

	*len = offset;
}

/* ==========================================================================
   UUID formatting
   ========================================================================== */

#define UUID_BLOCKSIZE 16

static int32_t UsintToHex(const uint8_t* pIn, uint8_t* pHex)
{
	static const char hexChars[] = "0123456789abcdef";
	uint16_t i;

	for (i = 0; i < UUID_BLOCKSIZE; i++) {
		uint8_t byte = pIn[i];
		pHex[2 * i]     = hexChars[byte >> 4];
		pHex[2 * i + 1] = hexChars[byte & 0x0F];
	}

	pHex[2 * UUID_BLOCKSIZE] = '\0';
	return 0;
}

static void HexStrToUUID(const uint8_t* pHex, uint8_t* pUUID)
{
	uint32_t offsetDest = 0;
	uint32_t offsetSrc = 0;
	uint8_t i;

	memcpy(pUUID + offsetDest, pHex + offsetSrc, 8);
	offsetDest += 8;
	offsetSrc += 8;
	memset(pUUID + offsetDest, '-', 1);
	offsetDest += 1;
	for (i = 0; i < 3; i++) {
		memcpy(pUUID + offsetDest, pHex + offsetSrc, 4);
		offsetDest += 4;
		offsetSrc += 4;
		memset(pUUID + offsetDest, '-', 1);
		offsetDest += 1;
	}
	memcpy(pUUID + offsetDest, pHex + offsetSrc, 12);
	offsetDest += 12;
	memset(pUUID + offsetDest, 0, 1);
}

/* ==========================================================================
   Main function block implementation
   ========================================================================== */

#define stepIDLE 0
#define stepWAITNEXT 1
#define stepSERIAL 2
#define stepTYPE 3
#define stepENTROPY 4
#define stepGENERATE 5

void UUIDGenerator(UUIDGenerator_typ* inst)
{
	uint8_t array[16] = {0};
	uint8_t uuid[33] = {0};
	uint8_t uuid_hyphened[37] = {0};
	uint8_t entropy_buf[128];
	uint32_t entropy_len;
	uint8_t fallback;
	DINT genTs1 = 0, initTs1 = 0, seedTs1 = 0;

	if (inst->internal.enable_last == 0 && inst->enable == 1) {
		// Positive edge of enable - start initialization
		inst->internal.internal_status = 65535;
		inst->internal.internal_error = 0;
		inst->internal.run_count = 0;
		inst->internal.uuid_count = 0;
		inst->internal.drbg_initialized = 0;
		inst->internal.step = stepSERIAL;
		inst->phase = uuidgenPHASE_INITIALIZING;
		inst->internal.ethstat_0.enable = 1;
	}
	inst->internal.enable_last = inst->enable;

	if (inst->enable == 0) {
		inst->phase = uuidgenPHASE_STOPPED;
		inst->internal.drbg_initialized = 0;
		inst->internal.ethstat_0.enable = 0;
	}

	// eth fb call - read statistics cyclic to avoid asynchronous call at re-seed
	inst->internal.ethstat_0.pDevice = (UDINT)&inst->ethIfName;
	inst->internal.ethstat_0.pStat = (UDINT)&inst->internal.stat;
	EthStat(&inst->internal.ethstat_0);
	if (inst->internal.ethstat_0.status != 65535) {
		if (inst->internal.ethstat_0.status == 0)
		{
			inst->internal.bytesRecv = inst->internal.stat.bytesrecv;		
		}
		else 
		{
			if (inst->internal.ethstat_0.status < 65534)
			{
				inst->fallbackModeActive = 1;
			}
		}
	}
	
	switch (inst->internal.step) {

		case stepIDLE:
			if (inst->internal.getnext_last == 0 && inst->getNextUUID == 1) {
				// Positive edge of getNextUUID
				if (inst->enable == 1 && inst->phase == uuidgenPHASE_READY) {
					inst->internal.step = stepGENERATE;
				}
			}
			inst->internal.getnext_last = inst->getNextUUID;
			break;

		case stepSERIAL:
			inst->internal.asiodpstatus_0.pDatapoint = (UDINT)"%ID.SerialNumber";
			inst->internal.asiodpstatus_0.enable = 1;
			AsIODPStatus(&inst->internal.asiodpstatus_0);
			if (inst->internal.asiodpstatus_0.status != 65535) {
				if (inst->internal.asiodpstatus_0.status == 0) {
					inst->internal.serial = inst->internal.asiodpstatus_0.value;
				} else {
					inst->internal.serial = inst->internal.asiodpstatus_0.status;
				}
				inst->internal.step = stepTYPE;
			}
			break;

		case stepTYPE:
			inst->internal.asiodpstatus_0.pDatapoint = (UDINT)"%IW.ModuleID";
			inst->internal.asiodpstatus_0.enable = 1;
			AsIODPStatus(&inst->internal.asiodpstatus_0);
			if (inst->internal.asiodpstatus_0.status != 65535) {
				if (inst->internal.asiodpstatus_0.status == 0) {
					inst->internal.serial = (inst->internal.serial << 16) | inst->internal.asiodpstatus_0.value;
				} else {
					inst->internal.serial = (inst->internal.serial << 16) | inst->internal.asiodpstatus_0.status;
				}
				inst->internal.step = stepWAITNEXT;
			}
			break;

		case stepWAITNEXT:
			inst->internal.ton_0.PT = 195;
			inst->internal.ton_0.IN = 1;
			TON(&inst->internal.ton_0);
			if (inst->internal.ton_0.Q == 1) {
				inst->internal.step = stepENTROPY;
				inst->internal.ton_0.IN = 0;
				TON(&inst->internal.ton_0);
			}
			break;

		case stepENTROPY:
			// Collect entropy from all sources
			collect_entropy(&inst->internal, entropy_buf, &entropy_len, &fallback);

			// Initialize or reseed the DRBG
			if (inst->internal.drbg_initialized == 0) {
				initTs1 = AsIOTimeStamp();
				drbg_init(inst->internal.drbg_K, inst->internal.drbg_V, entropy_buf, entropy_len);
				inst->internal.drbg_initialized = 1;
				inst->initTsDiff = AsIOTimeStamp() - initTs1;
			} else {
				seedTs1 = AsIOTimeStamp();			
				drbg_reseed(inst->internal.drbg_K, inst->internal.drbg_V, entropy_buf, entropy_len);
				inst->reseedTsDiff = AsIOTimeStamp() - seedTs1;
			}

			inst->fallbackModeActive = fallback;

			// Repeat initialization rounds to mix in more entropy
			if (inst->internal.run_count >= uuidgen_INIT_ROUNDS - 1) {
				inst->internal.step = stepGENERATE;
			} else {
				inst->internal.step = stepWAITNEXT;
				inst->internal.run_count++;
			}
			break;

		case stepGENERATE:
			inst->phase = uuidgenPHASE_READY;
			inst->internal.internal_status = 0;
			
			genTs1 = AsIOTimeStamp();
			
			// Periodic re-seeding to mix in fresh entropy
			if (inst->internal.uuid_count % uuidgen_RESEED_INTERVAL == 0) {
			
				collect_entropy(&inst->internal, entropy_buf, &entropy_len, &fallback);

				if (inst->internal.drbg_initialized) {
					seedTs1 = AsIOTimeStamp();
					drbg_reseed(inst->internal.drbg_K, inst->internal.drbg_V, entropy_buf, entropy_len);
					inst->reseedTsDiff = AsIOTimeStamp() - seedTs1;
				}
				inst->fallbackModeActive = fallback;
			}

			// Generate 16 random bytes from the DRBG
			
			drbg_generate(inst->internal.drbg_K, inst->internal.drbg_V, array, 16);

			// Force UUIDv4 format
			array[6] = (array[6] & 0x0F) | 0x40; // version 4
			array[8] = (array[8] & 0x3F) | 0x80; // variant 1

			// Convert to hex string
			UsintToHex(array, (uint8_t*)uuid);
			HexStrToUUID(uuid, uuid_hyphened);

			strcpy(inst->UUID, (char*)uuid);
			strcpy(inst->UUIDhyphened, (char*)uuid_hyphened);

			inst->genTsDiff = AsIOTimeStamp() - genTs1;
			
			inst->internal.uuid_count++;
			inst->internal.step = stepIDLE;
			break;

		default:
			inst->internal.step = stepIDLE;
			break;
	}
}
