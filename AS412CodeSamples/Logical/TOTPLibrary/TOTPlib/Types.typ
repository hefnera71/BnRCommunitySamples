TYPE
	Sha1ContextType : STRUCT (*per-instance SHA-1 and HMAC state*)
		buffer : ARRAY[0..15] OF UDINT;
		state : ARRAY[0..4] OF UDINT;
		bufferOffset : USINT;
		byteCount : UDINT;
		keyBuffer : ARRAY[0..63] OF USINT;
		innerHash : ARRAY[0..19] OF USINT;
	END_STRUCT;
END_TYPE
TYPE
	totplib_Internal_typ : STRUCT (* internal *)
		step : {REDUND_UNREPLICABLE} UINT; (*internal*)
		last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
		id1Buffer : {REDUND_UNREPLICABLE} ARRAY[0..40] OF USINT; (*internal*)
		id2Buffer : {REDUND_UNREPLICABLE} ARRAY[0..40] OF USINT; (*internal*)
		sha1result : {REDUND_UNREPLICABLE} ARRAY[0..19] OF USINT; (*interna*)
		secret : {REDUND_UNREPLICABLE} ARRAY[0..40] OF USINT; (*internal*)
		b32secret : {REDUND_UNREPLICABLE} ARRAY[0..127] OF USINT; (*internal*)
		otpcodes : {REDUND_UNREPLICABLE} ARRAY[0..4] OF UDINT; (*internal*)
		otpauthLink : {REDUND_UNREPLICABLE} ARRAY[0..255] OF USINT; (*internal*)
		certVFrom : {REDUND_UNREPLICABLE} DTStructure; (*internal*)
		certVTo : {REDUND_UNREPLICABLE} DTStructure; (*internal*)
		readCert : {REDUND_UNREPLICABLE} ArCertGetOwnDetails; (*internal*)
		readUTC : {REDUND_UNREPLICABLE} UtcDTGetTime; (*internal*)
		sha1Context : {REDUND_UNREPLICABLE} Sha1ContextType; (*internal*)
	END_STRUCT;
END_TYPE
