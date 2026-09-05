
TYPE
	rbacauthws_InternalSteps_enum : 
		( (*internal*)
		rbacauthws_STEP_WAIT,
		rbacauthws_STEP_CHECKCRED,
		rbacauthws_STEP_CHECKROLE,
		rbacauthws_STEP_SENDWSRESP
		);
	RbacAuthWs_Internal_typ : {REDUND_UNREPLICABLE} 	STRUCT  (*internal!!*)
		Request : {REDUND_UNREPLICABLE} STRING[400];
		RequestHeader : {REDUND_UNREPLICABLE} httpRequestHeader_t := (0);
		ResponseHeader : {REDUND_UNREPLICABLE} httpResponseHeader_t := (0);
		sRawHeader : {REDUND_UNREPLICABLE} ARRAY[0..19]OF STRING[80];
		sUri : {REDUND_UNREPLICABLE} STRING[255];
		Response : {REDUND_UNREPLICABLE} STRING[1500];
		FormParam1 : {REDUND_UNREPLICABLE} STRING[80] := '';
		FormParam3Old : {REDUND_UNREPLICABLE} STRING[80] := '';
		FormParam5 : {REDUND_UNREPLICABLE} STRING[80] := '';
		FormParam4 : {REDUND_UNREPLICABLE} STRING[80] := '';
		FormParam3 : {REDUND_UNREPLICABLE} STRING[80] := '';
		FormParam2 : {REDUND_UNREPLICABLE} STRING[80] := '';
		rbacauthws_Step : {REDUND_UNREPLICABLE} DINT;
		bProcessing : {REDUND_UNREPLICABLE} BOOL;
		bSendInitialForm : {REDUND_UNREPLICABLE} BOOL;
		TON_UploadSwitchoff : {REDUND_UNREPLICABLE} TON;
		bResponseIsJSON : {REDUND_UNREPLICABLE} BOOL;
		authServiceName : {REDUND_UNREPLICABLE} STRING[80];
		sTemp : {REDUND_UNREPLICABLE} STRING[255];
		sUploadLink : {REDUND_UNREPLICABLE} STRING[255];
		sInfoMessage : {REDUND_UNREPLICABLE} STRING[255];
		Webservice : {REDUND_UNREPLICABLE} httpsService := (0);
		UrlParam : {REDUND_UNREPLICABLE} httpGetParamUrl := (0);
		UUIDGenerator_0 : {REDUND_UNREPLICABLE} UUIDGenerator;
		WebUploadWithUuidAuth_0 : {REDUND_UNREPLICABLE} WebUploadWithUuidAuth;
		ArEventLogGetIdent_0 : {REDUND_UNREPLICABLE} ArEventLogGetIdent;
		ArUserAuthenticatePassword_0 : {REDUND_UNREPLICABLE} ArUserAuthenticatePassword;
		ArUserHasRole_0 : {REDUND_UNREPLICABLE} ArUserHasRole;
	END_STRUCT;
END_TYPE
