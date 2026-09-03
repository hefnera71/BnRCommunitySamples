
{REDUND_UNREPLICABLE} FUNCTION_BLOCK RbacAuthUploadWebservice (*webservice to authenticate with AR RBAC system and upload files*)
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enable the function block*)
		authServiceName : {REDUND_UNREPLICABLE} STRING[80]; (*name of the main webservice*)
		uploadServiceName : {REDUND_UNREPLICABLE} STRING[80]; (*name of the upload webservice*)
		loggerName : {REDUND_UNREPLICABLE} STRING[32]; (*logger module name where messages from the webservices are logged*)
		rbacRoleName : {REDUND_UNREPLICABLE} STRING[80]; (*name of the user role that has to match to grant upload*)
		targetDirectoryName : {REDUND_UNREPLICABLE} STRING[100]; (*directory name where uploads are stored*)
		targetDeviceName : {REDUND_UNREPLICABLE} STRING[100]; (*file device name for the upload service*)
		ethIfName : {REDUND_UNREPLICABLE} STRING[80]; (*name of the active ethernet interface (needed for token generator)*)
		uploadServiceTimer : {REDUND_UNREPLICABLE} TIME; (*time how long the upload webservice is enabled until auto closing*)
		externalBufferSetup : {REDUND_UNREPLICABLE} WebUpload_extbuffer_wbuuid_typ; (*external memory buffer configuration*)
	END_VAR
	VAR_OUTPUT
		wsAuthEnabled : {REDUND_UNREPLICABLE} BOOL; (*main webservice is enabled*)
		status : {REDUND_UNREPLICABLE} UINT; (*status of the main webservice *)
		wsUploadEnabled : {REDUND_UNREPLICABLE} BOOL; (*upload webservice is enabled*)
		statusWsUpload : {REDUND_UNREPLICABLE} UINT; (*status of the upload webservice*)
		wsUploadCounter : {REDUND_UNREPLICABLE} USINT; (*number of uploads since reboot*)
		wsUploadLastFileName : {REDUND_UNREPLICABLE} STRING[100]; (*name of the last file uploaded*)
		wsUploadLastFileSize : {REDUND_UNREPLICABLE} UDINT; (*size in byte of the last file uploaded*)
		wsUploadTimerET : {REDUND_UNREPLICABLE} TIME; (*elapsed time since upload service was enabled*)
		uuidGenPhase : {REDUND_UNREPLICABLE} USINT; (*phase of the token generator -> 2 = ready*)
	END_VAR
	VAR
		internal : {REDUND_UNREPLICABLE} RbacAuthWs_Internal_typ; (*internal!!*)
		zzEdge00000 : {REDUND_UNREPLICABLE} BOOL; (*internal!!*)
		zzEdge00001 : {REDUND_UNREPLICABLE} BOOL; (*internal!!*)
		zzEdge00002 : {REDUND_UNREPLICABLE} BOOL; (*internal!!*)
		zzEdge00003 : {REDUND_UNREPLICABLE} BOOL; (*internal!!*)
	END_VAR
END_FUNCTION_BLOCK
