
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

void bytes_to_hex(const unsigned char *bin, size_t bin_len, char *hex_out);
void hex_to_bytes(const char *hex_in, size_t hex_len, unsigned char *bin_out);

/* Extracts the marker-delimited signature, verifies it, and writes the content to pContent.
	pBuffer is used as scratch and modified; validationResult is 0 for a valid signature. */
void VerifyFromContent(struct VerifyFromContent* inst)
{
	unsigned long long message_content_len = 0;
	unsigned char sig_bin[crypto_sign_BYTES];
	char sig_asc[crypto_sign_BYTES * 2];
	unsigned long contentLen = 0;
	
	if (inst->contentSize >= inst->bufferLen - ed25519_SIGN_MARKERBLOCK_LEN)
	{
		// read ascii signature
		brsmemcpy((UDINT)sig_asc, inst->pBuffer + ed25519_SIGN_MARKER_LEN, ed25519_SIGN_ASCII_LEN);
		// get binary signature
		hex_to_bytes(sig_asc, sizeof(sig_asc), sig_bin);
		// prepare memory
		contentLen = inst->bufferLen - ed25519_SIGN_MARKERBLOCK_LEN;
		// move the content behind the bin sig
		// temporary copy content to content out buffer, and from there to 
		brsmemcpy(inst->pContent, inst->pBuffer + ed25519_SIGN_MARKERBLOCK_LEN, contentLen);
		// reset the buffer
		brsmemset(inst->pBuffer, 0, inst->bufferLen);
		// set binary signature at the beginning of the memory
		brsmemcpy(inst->pBuffer, (UDINT)sig_bin, crypto_sign_BYTES);
		// copy temp content to verify buffer after bin sig 
		brsmemcpy(inst->pBuffer + crypto_sign_BYTES, inst->pContent, contentLen);
		// reset the content out buffer
		brsmemset(inst->pContent, 0, inst->contentSize);
		// validate
		inst->validationResult = crypto_sign_open((unsigned char*)inst->pContent, &message_content_len, (const unsigned char*)inst->pBuffer, (unsigned long long)(contentLen + crypto_sign_BYTES), inst->public_key);
		inst->status = 0;
		inst->contentLen = (UDINT)message_content_len;

	}
	else
	{
		inst->status = ed25519_ERR_BUFFERSIZE; // content buffer too short
		inst->contentLen = 0;
	}
}

/* Signs pContent and writes a marker block with the hex signature followed by content to pBuffer. */
void SignToContent(struct SignToContent* inst)
{
	/*TODO: Add your code here*/
	unsigned long long signed_buffer_len = 0;
	char hex_sig[crypto_sign_BYTES * 2 + 1];
	unsigned char secret[crypto_sign_BYTES] = {0};
	
	if (inst->bufferSize >= inst->contentLen + ed25519_SIGN_MARKERBLOCK_LEN)
	{
		brsmemcpy((UDINT)secret, (UDINT)inst->private_key, sizeof(inst->private_key));
		brsmemcpy((UDINT)secret + sizeof(inst->private_key), (UDINT)inst->public_key, sizeof(inst->public_key));

		// sign the message
		crypto_sign((unsigned char*)inst->pBuffer, &signed_buffer_len, (const unsigned char*)inst->pContent, (unsigned long long)inst->contentLen, secret);
		// get hex ascii of signature
		bytes_to_hex((const unsigned char*)inst->pBuffer, crypto_sign_BYTES, hex_sig);
		// move the content to free the memory for the signature block
		brsmemmove(inst->pBuffer + ed25519_SIGN_MARKERBLOCK_LEN, inst->pBuffer + crypto_sign_BYTES, inst->contentLen);
		// add signature block
		brsmemcpy(inst->pBuffer, (UDINT)ed25519_SIGN_BEGIN_MARKER, ed25519_SIGN_MARKER_LEN);
		brsmemcpy(inst->pBuffer + ed25519_SIGN_MARKER_LEN, (UDINT)hex_sig, crypto_sign_BYTES * 2);
		brsmemcpy(inst->pBuffer + ed25519_SIGN_MARKER_LEN + crypto_sign_BYTES * 2, (UDINT)ed25519_SIGN_END_MARKER, ed25519_SIGN_MARKER_LEN);
		// result len
		inst->signedDataLen = inst->contentLen + ed25519_SIGN_MARKERBLOCK_LEN;
		inst->status = 0;
	}
	else
	{
		inst->status = ed25519_ERR_BUFFERSIZE; // buffer too short
		inst->signedDataLen = 0;
	}
}

/* Converts a 64-character hexadecimal value to 32 bytes; sizes must be exactly 64 and 32. */
UINT EDHexToBytes(unsigned long pHexString64, unsigned long sizeHex, unsigned long pByteArray32, unsigned long sizeByte)
{
	if (pHexString64 > 0 && pByteArray32 > 0 && sizeHex == 64 && sizeByte == 32)
	{
		hex_to_bytes((const char*)pHexString64, 64, (unsigned char*)pByteArray32);
		return 0;
	}
	else
	{
		return ed25519_ERR_FH_PARAMETER;
	}
}

/* Converts 32 bytes to 64 hexadecimal characters; sizes must be exactly 32 and 64. */
UINT EDBytesToHex(unsigned long pByteArray32, unsigned long sizeByte, unsigned long pHexString64, unsigned long sizeHex)
{
	if (pHexString64 > 0 && pByteArray32 > 0 && sizeHex == 64 && sizeByte == 32)
	{
		bytes_to_hex((const unsigned char*)pByteArray32, 32, (char*)pHexString64);
		return 0;
	}
	else
	{
		return ed25519_ERR_FH_PARAMETER;
	}
}

static const char hex_chars[] = "0123456789abcdef";

void bytes_to_hex(const unsigned char *bin, size_t bin_len, char *hex_out) {
	for (size_t i = 0; i < bin_len; i++) {
		/* high nibble */
		hex_out[i * 2]     = hex_chars[(bin[i] >> 4) & 0x0F];
		/* low nibble */
		hex_out[i * 2 + 1] = hex_chars[bin[i] & 0x0F];
	}
	hex_out[bin_len * 2] = '\0';
}

void hex_to_bytes(const char *hex_in, size_t hex_len, unsigned char *bin_out) {
    /* Lookup-Table 
	to convert ASCII char to nibble value.
       Supports '0'-'9', 'a'-'f' und 'A'-'F'. Invalid chars are 0. */
	static const unsigned char hex_values[256] = {
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0, /* '0'-'9' */
		0,10,11,12,13,14,15,0,0,0,0,0,0,0,0,0, /* 'A'-'F' */
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,10,11,12,13,14,15,0,0,0,0,0,0,0,0,0, /* 'a'-'f' */
		/* last 128 init with 0 */
	};

	for (size_t i = 0; i < hex_len; i += 2) {
		unsigned char high = hex_values[(unsigned char)hex_in[i]];
		unsigned char low  = hex_values[(unsigned char)hex_in[i+1]];
        
		bin_out[i / 2] = (high << 4) | low;
	}
}