
/* Package code is MIT-licensed; see LICENSE.txt in this directory. */
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "ED25519.h"
	#include "tweetnacl.h"
	#include <stdlib.h>
	#include <AsBrStr.h>
#ifdef __cplusplus
	};
#endif
/* Signs data into pBuffer as a 64-byte signature followed by the original data. */
void SignMemoryData(struct SignMemoryData* inst)
{
	unsigned long long signed_buffer_len = 0;
	unsigned char secret[crypto_sign_BYTES] = {0};
	if (inst->bufferSize > inst->dataLen + crypto_sign_BYTES)
	{
		brsmemcpy((UDINT)secret, (UDINT)inst->private_key, sizeof(inst->private_key));
		brsmemcpy((UDINT)secret + sizeof(inst->private_key), (UDINT)inst->public_key, sizeof(inst->public_key));
		
		crypto_sign((unsigned char*)inst->pBuffer, &signed_buffer_len, (const unsigned char*)inst->pData, (unsigned long long)inst->dataLen, secret);
		inst->signedDataLen = (UDINT)signed_buffer_len;
		inst->status = 0;
	}
	else
	{
		inst->status = ed25519_ERR_BUFFERSIZE; // signed message buffer too short
		inst->signedDataLen = 0;
	}
	

}

/* Verifies a signature-prefixed message and writes verified data to pData.
	validationResult is 0 for a valid signature; status reports buffer/API errors. */
void VerifyMemoryData(struct VerifyMemoryData* inst)
{
	unsigned long long message_content_len = 0;
	/*TODO: Add your code here*/
	if (inst->dataSize >= inst->signedMessageLen - crypto_sign_BYTES)
	{
		inst->validationResult = crypto_sign_open((unsigned char*)inst->pData, &message_content_len, (const unsigned char*)inst->pSignedMessage, (unsigned long long)inst->signedMessageLen, inst->public_key);
		inst->status = 0;
		inst->dataLen = (UDINT)message_content_len;
	}
	else
	{
		inst->status = ed25519_ERR_BUFFERSIZE;
		inst->validationResult = -1;
		inst->dataLen = 0;
	}
}

