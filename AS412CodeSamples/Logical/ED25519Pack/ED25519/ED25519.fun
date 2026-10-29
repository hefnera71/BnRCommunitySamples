
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK SignMemoryData (*Signs data and writes the signature-prefixed message to a caller buffer.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pData : {REDUND_UNREPLICABLE} UDINT; (* pointer to the data to sign *)
		dataLen : {REDUND_UNREPLICABLE} UDINT; (* number of data bytes to sign *)
		pBuffer : {REDUND_UNREPLICABLE} UDINT; (* writable buffer for signature followed by data *)
		bufferSize : {REDUND_UNREPLICABLE} UDINT; (* capacity of pBuffer; allow 64 signature bytes plus data *)
		public_key : {REDUND_UNREPLICABLE} ARRAY[0..31] OF USINT; (* 32-byte Ed25519 public key *)
		private_key : {REDUND_UNREPLICABLE} ARRAY[0..31] OF USINT; (* 32-byte Ed25519 private seed *)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (* 0 when processed; otherwise an ED25519 error code *)
		signedDataLen : {REDUND_UNREPLICABLE} UDINT; (* total bytes written: signature plus data *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK VerifyMemoryData (*Verifies a signature-prefixed message and returns its data.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pSignedMessage : {REDUND_UNREPLICABLE} UDINT; (* pointer to signature-prefixed message *)
		signedMessageLen : {REDUND_UNREPLICABLE} UDINT; (* total signed-message bytes, including 64-byte signature *)
		pData : {REDUND_UNREPLICABLE} UDINT; (* writable destination for verified data *)
		dataSize : {REDUND_UNREPLICABLE} UDINT; (* capacity of the destination buffer *)
		public_key : {REDUND_UNREPLICABLE} ARRAY[0..31] OF USINT; (* 32-byte Ed25519 public key *)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (* 0 when verification was attempted; otherwise an ED25519 error code *)
		validationResult : {REDUND_UNREPLICABLE} INT; (* 0 for a valid signature; nonzero if verification fails *)
		dataLen : {REDUND_UNREPLICABLE} UDINT; (* length of the verified data reported by the verifier *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK SignToContent (*Signs content and adds a marker-delimited hexadecimal signature.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pContent : {REDUND_UNREPLICABLE} UDINT; (* pointer to the content to sign *)
		contentLen : {REDUND_UNREPLICABLE} UDINT; (* number of content bytes to sign *)
		pBuffer : {REDUND_UNREPLICABLE} UDINT; (* writable output for marker block followed by content *)
		bufferSize : {REDUND_UNREPLICABLE} UDINT; (* capacity of pBuffer; allow contentLen plus 176 bytes *)
		public_key : {REDUND_UNREPLICABLE} ARRAY[0..31] OF USINT; (* 32-byte Ed25519 public key *)
		private_key : {REDUND_UNREPLICABLE} ARRAY[0..31] OF USINT; (* 32-byte Ed25519 private seed *)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (* 0 when processed; otherwise an ED25519 error code *)
		signedDataLen : {REDUND_UNREPLICABLE} UDINT; (* total bytes written: marker block plus content *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK VerifyFromContent (*Verifies content with a marker-delimited hexadecimal signature.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pBuffer : {REDUND_UNREPLICABLE} UDINT; (* signed content buffer; used as scratch and modified *)
		bufferLen : {REDUND_UNREPLICABLE} UDINT; (* total bytes in the signed content buffer *)
		pContent : {REDUND_UNREPLICABLE} UDINT; (* writable destination for verified content *)
		contentSize : {REDUND_UNREPLICABLE} UDINT; (* capacity of the destination buffer *)
		public_key : {REDUND_UNREPLICABLE} ARRAY[0..31] OF USINT; (* 32-byte Ed25519 public key *)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (* 0 when verification was attempted; otherwise an ED25519 error code *)
		validationResult : {REDUND_UNREPLICABLE} INT; (* 0 for a valid signature; nonzero if verification fails *)
		contentLen : {REDUND_UNREPLICABLE} UDINT; (* length of the verified content reported by the verifier *)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_UNREPLICABLE} FUNCTION_BLOCK EDFileIOHelper (*State machine for file create / open / read / write / close using the FileIO library. The transfer buffer is always an external buffer provided by the caller via pBuffer. The state machine is advanced by calling the FB cyclically.*)
	VAR_INPUT
		Enable : {REDUND_UNREPLICABLE} BOOL; (* enables cyclic execution of the file operation *)
		Command : {REDUND_UNREPLICABLE} USINT := 0; (*command: ED_FH_CMD_NONE (0) / ED_FH_CMD_WRITE_FILE (1) / ED_FH_CMD_READ_FILE (2). The caller has to set the command to ED_FH_CMD_NONE to re-arm the block for the next flow.*)
		sFileDevice : {REDUND_UNREPLICABLE} STRING[80]; (*file device name, e.g. 'USER' (standard user file device)*)
		sFileName : {REDUND_UNREPLICABLE} STRING[80]; (*name of the file to create / open / read / delete*)
		bytesToTransfer : {REDUND_UNREPLICABLE} UDINT; (* requested write length; must not exceed maxBufferSize *)
		maxBufferSize : {REDUND_UNREPLICABLE} UDINT; (* capacity of the external transfer buffer *)
		pBuffer : {REDUND_UNREPLICABLE} UDINT; (* pointer to the external buffer used for read and write *)
	END_VAR
	VAR_OUTPUT
		fileStep : {REDUND_UNREPLICABLE} USINT; (*current state of the flow, for HMI / debugging*)
		bBusy : {REDUND_UNREPLICABLE} BOOL; (*TRUE while a flow is running*)
		bError : {REDUND_UNREPLICABLE} BOOL; (*TRUE if the last flow ended with an error*)
		lastStatus : {REDUND_UNREPLICABLE} UINT; (*status code of the last error, see FileIO error codes*)
		status : {REDUND_UNREPLICABLE} UINT; (*0 = flow finished without error, otherwise the FileIO error code, same as lastStatus*)
		bytesRead : {REDUND_UNREPLICABLE} UDINT; (*number of bytes read*)
	END_VAR
	VAR
		internal : {REDUND_UNREPLICABLE} EDFileIOHelperInternalType; (*internal state: file offset and the FileIO function block instances*)
	END_VAR
END_FUNCTION_BLOCK

	(* Converts a 64-character hexadecimal key into 32 bytes; returns 0 or a parameter error. *)
{REDUND_ERROR} FUNCTION EDHexToBytes : UINT (*Convert a 64-character hexadecimal key into 32 bytes*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pHexString64 : UDINT; (*pointer to string with 64 chars*)
		sizeHex : UDINT; (* input length; must be 64 bytes *)
		pByteArray32 : UDINT; (*pointer to byte array with len 32*)
		sizeByte : UDINT; (* output capacity; must be 32 bytes *)
	END_VAR
END_FUNCTION

	(* Converts 32 bytes into 64 hexadecimal characters; returns 0 or a parameter error. *)
{REDUND_ERROR} FUNCTION EDBytesToHex : UINT (*Convert 32 bytes into 64 hexadecimal characters*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pByteArray32 : UDINT; (*pointer to byte array with len 32*)
		sizeByte : UDINT; (* input length; must be 32 bytes *)
		pHexString64 : UDINT; (*pointer to string with 64 chars*)
		sizeHex : UDINT; (* output capacity; must be 64 bytes *)
	END_VAR
END_FUNCTION
