
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK VerifyTOTPCode (* implementation of TOTP algorithm as described in RFC 6238*)
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enable the function block*)
		code : {REDUND_UNREPLICABLE} UDINT; (*the external code from authenticator app*)
		tolerance : {REDUND_UNREPLICABLE} USINT; (*0 = accepts just the actual 30 seconds token, 1 = accepts actual token and previous + next one, 2 = accepts actual token plus last 2 and next 2 ones*)
		validity : {REDUND_UNREPLICABLE} UINT; (*0 - 30 = default = 30 seconds; > 30 code validity in seconds. WARNING! Using values > 30 seconds does not work with common Authenticator apps!*)
		pId1 : {REDUND_UNREPLICABLE} UDINT; (*pointer to own free string[32] value which is used for shared secret generation*)
		pId2 : {REDUND_UNREPLICABLE} UDINT; (*pointer to own free string[32] value or name of certificate name which is used for shared secret generation*)
		id2IsOwnCertificate : {REDUND_UNREPLICABLE} BOOL; (*1 = use the id2 as certificate name, 0 = use id2 as free value*)
		otpauthLabel : {REDUND_UNREPLICABLE} STRING[64]; (*label of the otpauth link, oten used with following pattern <IssuerName:AccountName>*)
	END_VAR
	VAR_OUTPUT
		codeValid : {REDUND_UNREPLICABLE} BOOL; (*true = code is valid, false = code is invalid*)
		phase : {REDUND_UNREPLICABLE} USINT; (*0 = starting, 1 = reading cert, 2 = preparing secret, 3 = READY TO CHECK CODES*)
		status : {REDUND_UNREPLICABLE} UINT; (*FB status - 65535 if running, 65534 if disable, error if anything else*)
		statusID : {REDUND_UNREPLICABLE} DINT; (*Extended status (internal FB call StatusID in case of FB call error)*)
		pCertValidFrom : {REDUND_UNREPLICABLE} UDINT; (*pointer to DTStructure -> certificate from date (just for information/external reaction! FB internally this is ignored!)*)
		pCertValidTo : {REDUND_UNREPLICABLE} UDINT; (*pointer to DTStructure -> certificate to date (just for information/external reaction! FB internally this is ignored!)*)
		pOtpSharedB32S : {REDUND_UNREPLICABLE} UDINT; (*pointer to string[128] holding the otp shared secret - string has to have size 128!!*)
		pOtpauthLink : {REDUND_UNREPLICABLE} UDINT; (*pointer to string[256] holding the otpauth link - string has to have size 255!!*)
	END_VAR
	VAR
		step : {REDUND_UNREPLICABLE} UINT; (*internal*)
		last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
	END_VAR
END_FUNCTION_BLOCK
