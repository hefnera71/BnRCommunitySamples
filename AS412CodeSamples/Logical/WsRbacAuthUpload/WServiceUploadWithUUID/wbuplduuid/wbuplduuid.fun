
{REDUND_UNREPLICABLE} FUNCTION_BLOCK WebUploadWithUuidAuth (*webservice to upload files (if allowed, authenticated by token)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enable the function block*)
		errorReset : {REDUND_UNREPLICABLE} BOOL; (*reset internal webservice error*)
		serviceName : {REDUND_UNREPLICABLE} STRING[100]; (*name of the upload webservice*)
		targetDeviceName : {REDUND_UNREPLICABLE} STRING[100]; (*file device where uploads are stored*)
		targetDirectoryName : {REDUND_UNREPLICABLE} STRING[100]; (*directory where uploads are stored*)
		uuid : {REDUND_UNREPLICABLE} STRING[32]; (*token that is allowed for upload*)
		loggerName : {REDUND_UNREPLICABLE} STRING[32]; (*logger where the messages are logged to*)
		externalBufferSetup : {REDUND_UNREPLICABLE} WebUpload_extbuffer_wbuuid_typ; (*external memory buffer configuration if needed (upload file > 10kByte*)
	END_VAR
	VAR_OUTPUT
		targetFileName : {REDUND_UNREPLICABLE} STRING[100]; (*name of the last file uploaded*)
		sourceFileSize : {REDUND_UNREPLICABLE} UDINT; (*size of the file*)
		uploadCounter : {REDUND_UNREPLICABLE} USINT; (*upload counter*)
		userFinished : {REDUND_UNREPLICABLE} BOOL; (*user has signaled via webservice, that upload is finished*)
		Done : {REDUND_UNREPLICABLE} BOOL; (*done*)
		Busy : {REDUND_UNREPLICABLE} BOOL; (*busy*)
		Error : {REDUND_UNREPLICABLE} BOOL; (*error*)
		Status : {REDUND_UNREPLICABLE} UINT; (*status of the FB*)
	END_VAR
	VAR
		internal : {REDUND_UNREPLICABLE} WebUpload_internal_wbuuid_typ; (*internal!!*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION wbuuid_strFindFromPos : UDINT (*Finds position of string2 in string1.*) (*$GROUP=User*)
	VAR_INPUT
		string1 : UDINT; (*String where it should be searched in*)
		string2 : UDINT; (*String that should be searched*)
		pos : UDINT; (*Starting position*)
	END_VAR
	VAR
		found : BOOL;
		j : UDINT;
		pChar_string2 : REFERENCE TO SINT;
		pChar_string1 : REFERENCE TO SINT;
		j_max : UDINT;
		i_max : UDINT;
		i : UDINT;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION wbuuid_FcWriteArLog : BOOL (*write message to logger*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		arLogIdent : ArEventLogIdentType; (*logger ident*)
		arLogEvent : DINT; (*event id*)
		arLogObjID : STRING[32]; (*object id*)
		arLogText : STRING[255]; (*text to log*)
	END_VAR
	VAR
		ArEventLogWrite_0 : ArEventLogWrite;
	END_VAR
END_FUNCTION
