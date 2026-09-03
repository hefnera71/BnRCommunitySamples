
TYPE
	WebUpload_internal_wbuuid_typ : 	STRUCT 
		step : WebUploadStep_wbuuid_enum;
		ResponseHeader : httpResponseHeader_t;
		RequestHeader : httpRequestHeader_t;
		Response : STRING[1500];
		strPosFilenameStart : UDINT;
		strPosFilenameEnd : UDINT;
		messageHeader : STRING[300];
		multipartBoundary : STRING[100];
		fileName : STRING[100];
		closeFile : BOOL;
		fileOffset : UDINT;
		RequestUri : STRING[500];
		param1 : STRING[80];
		param2 : STRING[80];
		param3 : STRING[80];
		param4 : STRING[80];
		bModeIsJson : BOOL;
		sTemp : STRING[255];
		RequestBuffer : ARRAY[0..WBUUIDUPLOAD_MAX_REQUEST_SIZE]OF USINT;
		multipartMessage : ARRAY[0..WBUUIDUPLOAD_MAX_REQUEST_SIZE]OF USINT;
		bufferSetup : WebUpload_extbuffer_wbuuid_typ;
		WebService : httpsService;
		GetMultipartMessage_0 : httpGetMultipartMessage;
		GetBoundary_0 : httpGetBoundary;
		UrlParam : httpGetParamUrl;
		ArEventLogGetIdent_0 : ArEventLogGetIdent;
		FileCreate_0 : FileCreate;
		FileOpen_0 : FileOpen;
		FileWrite_0 : FileWriteEx;
		FileClose_0 : FileClose;
		FileDelete_0 : FileDelete;
		DirCreate_0 : DirCreate;
	END_STRUCT;
	WebUploadStep_wbuuid_enum : 
		(
		WBUPUUID_STEP_WAIT,
		WBUPUUID_STEP_HANDLE_REQUESTS,
		WBUPUUID_STEP_PARSE_BOUNDARY,
		WBUPUUID_STEP_PARSE_MULTIPARTS,
		WBUPUUID_STEP_DELETE_FILE,
		WBUPUUID_STEP_CREATE_DIRECTORY,
		WBUPUUID_STEP_CREATE_FILE,
		WBUPUUID_STEP_OPEN_FILE,
		WBUPUUID_STEP_WRITE_FILE,
		WBUPUUID_STEP_SEND_RESPONSE,
		WBUPUUID_STEP_SEND_ERROR,
		WBUPUUID_STEP_SEND_ERROR_WAIT,
		WBUPUUID_STEP_ERROR
		);
	WebUpload_extbuffer_wbuuid_typ : 	STRUCT 
		pRequestBuffer : UDINT;
		pMultipartBuffer : UDINT;
		requestBufferSize : UDINT;
		multipartBufferSize : UDINT;
	END_STRUCT;
END_TYPE
