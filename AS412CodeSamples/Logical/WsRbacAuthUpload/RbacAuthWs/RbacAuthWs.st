FUNCTION_BLOCK RbacAuthUploadWebservice

	IF enable = TRUE THEN
	
		status := 16#FFFF;
		
		internal.authServiceName := authServiceName; // input
		internal.WebUploadWithUuidAuth_0.targetDeviceName := targetDeviceName;		//input
		internal.WebUploadWithUuidAuth_0.targetDirectoryName := targetDirectoryName;		// input
		internal.WebUploadWithUuidAuth_0.serviceName := uploadServiceName;	// input
		internal.TON_UploadSwitchoff.PT := uploadServiceTimer; // input

		internal.WebUploadWithUuidAuth_0.loggerName := loggerName;		// input
		internal.ArEventLogGetIdent_0(Execute := TRUE, Name := loggerName);	//input

		internal.UUIDGenerator_0(ethIfName := ethIfName); // input
	
		internal.Webservice.pServiceName 	:= ADR(internal.authServiceName); (* Name of webservice *)
		internal.Webservice.option 			:= httpOPTION_HTTP_11 + httpOPTION_SERVICE_TYPE_NAME;
		internal.Webservice.pUri			:= ADR(internal.sUri);
		internal.Webservice.uriSize			:= SIZEOF(internal.sUri);
		internal.Webservice.pResponseHeader := ADR(internal.ResponseHeader);
		internal.Webservice.pRequestHeader	:= ADR(internal.RequestHeader);
		internal.Webservice.pRequestData  	:= ADR(internal.Request);
		internal.Webservice.requestDataSize := SIZEOF(internal.Request);
		internal.Webservice.pResponseData 	:= ADR(internal.Response);

		internal.RequestHeader.rawHeader.pData := ADR(internal.sRawHeader);
		internal.RequestHeader.rawHeader.dataSize := SIZEOF(internal.sRawHeader);
		
		internal.UUIDGenerator_0.enable := TRUE;
		IF internal.UUIDGenerator_0.phase = uuidgenPHASE_READY THEN
			internal.Webservice.enable := TRUE;
		END_IF

		IF  internal.Webservice.send = TRUE  THEN 
			internal.Webservice.send := FALSE; (* Reset *)
		ELSIF internal.Webservice.status = ERR_OK AND internal.Webservice.send = FALSE AND internal. Webservice.phase = httpPHASE_RECEIVED AND internal.bProcessing = FALSE THEN 
			(* Create Response *)	
		
			wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'RbacAuthWs', 'auth webservice was called');
		
			internal.FormParam1 := '';
			internal.FormParam2 := '';
			internal.FormParam3 := '';
			internal.FormParam4 := '';
			internal.FormParam5 := '';
			internal.UrlParam.enable := TRUE;

			// user name from RBAC
			internal.UrlParam.pParam := ADR('user');
			internal.UrlParam.pSrc := ADR(internal.Request);
			internal.UrlParam.pValue := ADR(internal.FormParam1);
			internal.UrlParam.valueSize := SIZEOF(internal.FormParam1);
			internal.UrlParam();
		
			// password of the user
			internal.UrlParam.pParam := ADR('password');
			internal.UrlParam.pSrc := ADR(internal.Request);
			internal.UrlParam.pValue := ADR(internal.FormParam2);
			internal.UrlParam.valueSize := SIZEOF(internal.FormParam2);
			internal.UrlParam();
		
			// parameter to identify if the request is possible just a copied one
			internal.UrlParam.pParam := ADR('_ts');
			internal.UrlParam.pSrc := ADR(internal.Request);
			internal.UrlParam.pValue := ADR(internal.FormParam3);
			internal.UrlParam.valueSize := SIZEOF(internal.FormParam3);
			internal.UrlParam();
		
			// defines output format -- BE AWARE: mode parameter is url encoded, not a POST variable!!
			internal.UrlParam.pParam := ADR('mode');
			internal.UrlParam.pSrc := ADR(internal.sUri);
			internal.UrlParam.pValue := ADR(internal.FormParam4);
			internal.UrlParam.valueSize := SIZEOF(internal.FormParam4);
			internal.UrlParam();
		
			// stop the upload webservice before automatic stop by timeout
			internal.UrlParam.pParam := ADR('stop_upload');
			internal.UrlParam.pSrc := ADR(internal.Request);
			internal.UrlParam.pValue := ADR(internal.FormParam5);
			internal.UrlParam.valueSize := SIZEOF(internal.FormParam5);
			internal.UrlParam();

			// all parameters read -> so delete internal buffer not to expose parameter data longer then neccessary
			brsmemset(ADR(internal.Request), 0, SIZEOF(internal.Request));
			
			IF internal.FormParam3 = internal.FormParam3Old THEN
				// this was a reload submission --> we need to break and send the empty form instead again
				internal.bSendInitialForm := TRUE;
			ELSE
				// okay, go on
				internal.rbacauthws_Step := rbacauthws_STEP_CHECKCRED;
				internal.bProcessing := TRUE;
			END_IF
			internal.FormParam3Old := internal.FormParam3;
			
			IF internal.FormParam4 <> 'html' THEN
				internal.ResponseHeader.contentType 	:= 'application/json';
				internal.bResponseIsJSON := TRUE;
			ELSE
				internal.ResponseHeader.contentType 	:= 'text/html'; (* Response is HTML data and this is the correct MIME type *)
				internal.bResponseIsJSON := FALSE;
			END_IF				

			IF internal.FormParam5 = 'true' THEN
				internal.WebUploadWithUuidAuth_0.enable := FALSE;
			END_IF
		
		
			IF internal.Webservice.method <> httpMETHOD_POST THEN
				// initial send
				internal.bSendInitialForm := TRUE;
			END_IF
		
		END_IF
	
		IF internal.bSendInitialForm = TRUE THEN
			internal.bSendInitialForm := FALSE;
			IF NOT internal.bResponseIsJSON THEN
				internal.ResponseHeader.contentType 	:= 'text/html'; (* Response is HTML data and this is the correct MIME type *)
				internal.Response := '<html><head><script>function getTs(){document.getElementById("_ts").value = Date.now();}</script></head><body><h2>Authenticate</h2><form method="POST" action="/';
				brsstrcat(ADR(internal.Response),ADR(internal.authServiceName));
				brsstrcat(ADR(internal.Response),ADR('?mode=html"><label for="user">Username:</label><input type="text" id="user" name="user" size="20" /><br><label for="password">Password:</label><input type="password" id="password" name="password" size="20" /><br><input type="submit" name="bt1" value="Submit" onclick="getTs();"><input type="hidden" name="_ts" id="_ts" value=""/></form></body></html>'));
			ELSE
				internal.ResponseHeader.contentType 	:= 'application/json';
				internal.Response := '{status:"error", info:"parameters missing?"}';
			END_IF
		
			internal.Webservice.responseDataLen := brsstrlen(ADR(internal.Response));
			internal.Webservice.send := TRUE; (* Send on positive edge*)
		END_IF		
	
		CASE internal.rbacauthws_Step OF
	
			rbacauthws_STEP_CHECKCRED:
				
				internal.ArUserAuthenticatePassword_0.Execute := TRUE;
				internal.ArUserAuthenticatePassword_0.UserName := internal.FormParam1;
				internal.ArUserAuthenticatePassword_0.Password := internal.FormParam2;
				IF internal.ArUserAuthenticatePassword_0.Done = TRUE OR internal.ArUserAuthenticatePassword_0.Error = TRUE THEN
					internal.ArUserAuthenticatePassword_0.Execute := FALSE;
					// decide how to go on
					IF internal.ArUserAuthenticatePassword_0.IsAuthentic = TRUE THEN
						internal.rbacauthws_Step := rbacauthws_STEP_CHECKROLE;
						// log it
						internal.sTemp := 'user auth: '; brsstrcat(ADR(internal.sTemp),ADR(internal.ArUserAuthenticatePassword_0.UserName));
						wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_SUCCESS, 'RbacAuthWs', internal.sTemp);
					ELSE
						internal.rbacauthws_Step := rbacauthws_STEP_SENDWSRESP;
						// log it
						internal.sTemp := 'auth failed: '; brsstrcat(ADR(internal.sTemp),ADR(internal.ArUserAuthenticatePassword_0.UserName));
						wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'RbacAuthWs', internal.sTemp);
						IF NOT internal.bResponseIsJSON THEN
							internal.Response := '<html><body>User Auth Error</body></html>';
						ELSE
							internal.Response := '{status:"error", info:"user auth error"}';
						END_IF						
					END_IF
					// internal check for username + password done - password is not longer needed, so delete internal variable
					brsmemset(ADR(internal.FormParam2), 0, SIZEOF(internal.FormParam2));
					brsmemset(ADR(internal.ArUserAuthenticatePassword_0.Password), 0, SIZEOF(internal.ArUserAuthenticatePassword_0.Password));
				END_IF
		
			rbacauthws_STEP_CHECKROLE:
				
				internal.ArUserHasRole_0.Execute := TRUE;
				internal.ArUserHasRole_0.UserName := internal.FormParam1;
				// define  the role this user has to have per definition ...
				internal.ArUserHasRole_0.RoleName := rbacRoleName;
				IF internal.ArUserHasRole_0.Done = TRUE OR internal.ArUserHasRole_0.Error = TRUE THEN
					
					internal.ArUserHasRole_0.Execute := FALSE;
					internal.rbacauthws_Step := rbacauthws_STEP_SENDWSRESP;
					IF internal.ArUserHasRole_0.HasRole = TRUE THEN
						// log it
						internal.sTemp := 'role valid: '; brsstrcat(ADR(internal.sTemp),ADR(internal.ArUserAuthenticatePassword_0.UserName));
						wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_SUCCESS, 'RbacAuthWs', internal.sTemp);

						// generate uuid
						internal.UUIDGenerator_0.getNextUUID := TRUE;
						internal.UUIDGenerator_0();
						internal.UUIDGenerator_0.getNextUUID := FALSE;
						
						// copy buffer configuration to upload webservice
						brsmemcpy(ADR(internal.WebUploadWithUuidAuth_0.externalBufferSetup),ADR(externalBufferSetup), SIZEOF(externalBufferSetup));
						// enable upload service and use uuid
						internal.WebUploadWithUuidAuth_0.enable := TRUE;
						internal.WebUploadWithUuidAuth_0.uuid := internal.UUIDGenerator_0.UUID;
						// activate timer
						internal.TON_UploadSwitchoff.IN := TRUE;
						// response
					
						//prepare some status infos
						internal.sUploadLink := '/';
						brsstrcat(ADR(internal.sUploadLink), ADR(internal.WebUploadWithUuidAuth_0.serviceName));
						brsstrcat(ADR(internal.sUploadLink), ADR('?uuid='));
						brsstrcat(ADR(internal.sUploadLink), ADR(internal.UUIDGenerator_0.UUID));
						internal.sInfoMessage := 'Access granted. Upload service now active for ';
						internal.sTemp := TIME_TO_STRING(internal.TON_UploadSwitchoff.PT);
						brsstrcat(ADR(internal.sInfoMessage), ADR(internal.sTemp));
					
						IF NOT internal.bResponseIsJSON THEN
							//internal.Response := '<html><body>';
							//brsstrcat(ADR(internal.Response), ADR(internal.sInfoMessage));
							//brsstrcat(ADR(internal.Response), ADR('! Navigate to:<br><a href="./'));
							//brsstrcat(ADR(internal.Response), ADR(internal.sUploadLink));
							//brsstrcat(ADR(internal.Response),ADR('">Upload Form</a></body></html>'));
							internal.Response := '<html><head><meta http-equiv="refresh" content="2; ';
							brsstrcat(ADR(internal.Response), ADR(internal.sUploadLink));
							brsstrcat(ADR(internal.Response), ADR('&mode=html"></head><body>'));
							brsstrcat(ADR(internal.Response), ADR(internal.sInfoMessage));
							brsstrcat(ADR(internal.Response), ADR('!<br>Forwarding in 2 seconds - if you$'re not forwarded, navigate to:<br><a href="./'));
							brsstrcat(ADR(internal.Response), ADR(internal.sUploadLink));
							brsstrcat(ADR(internal.Response),ADR('">Upload Form</a></body></html>'));
						ELSE
							internal.Response := '{status:"ok", info:"';
							brsstrcat(ADR(internal.Response), ADR(internal.sInfoMessage));
							brsstrcat(ADR(internal.Response),ADR('", uuid:"'));
							brsstrcat(ADR(internal.Response),ADR(internal.UUIDGenerator_0.UUID));
							// brsstrcat(ADR(internal.Response),ADR('", link:"'));
							//brsstrcat(ADR(internal.Response), ADR(internal.sUploadLink));
							//brsstrcat(ADR(internal.Response), ADR('&mode=json&do_upload=true'));
							brsstrcat(ADR(internal.Response),ADR('"}'));
						END_IF
					ELSE
						// log it
						internal.sTemp := 'role invalid: '; brsstrcat(ADR(internal.sTemp),ADR(internal.ArUserAuthenticatePassword_0.UserName));
						wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'RbacAuthWs', internal.sTemp);
						IF NOT internal.bResponseIsJSON THEN
							internal.Response := '<html><body>User Role Error</body></html>';
						ELSE
							internal.Response := '{status:"error", info:"user role error"}';
						END_IF						
					END_IF
					// authentication things done - delete internal variable holding username
					brsmemset(ADR(internal.FormParam1), 0, SIZEOF(internal.FormParam1));
					brsmemset(ADR(internal.ArUserHasRole_0.UserName), 0, SIZEOF(internal.ArUserHasRole_0.UserName));
					brsmemset(ADR(internal.ArUserAuthenticatePassword_0.UserName), 0, SIZEOF(internal.ArUserAuthenticatePassword_0.UserName));
				END_IF
		
			3:
				internal.Webservice.responseDataLen := brsstrlen(ADR(internal.Response));
				internal.Webservice.send := TRUE; (* Send on positive edge*)
				internal.rbacauthws_Step := rbacauthws_STEP_WAIT;
				internal.bProcessing := FALSE;
		
		END_CASE
	

		// call timer to switch off upload service
		internal.TON_UploadSwitchoff();
		// check if upload service has to be ended
		IF internal.TON_UploadSwitchoff.Q = TRUE OR internal.WebUploadWithUuidAuth_0.userFinished = TRUE THEN
			internal.TON_UploadSwitchoff.IN := FALSE;
			internal.TON_UploadSwitchoff();
			internal.WebUploadWithUuidAuth_0.enable := FALSE;
		END_IF
	
		// call RBAC fbs
		internal.ArUserAuthenticatePassword_0();
		internal.ArUserHasRole_0();
	
		// call auth webservice
		internal.Webservice();
		IF EDGEPOS(internal.Webservice.enable) = TRUE THEN
			wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'RbacAuthWs', 'auth webservice was enabled');
		END_IF
		IF EDGENEG(internal.Webservice.enable) = TRUE THEN
			wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'RbacAuthWs', 'auth webservice was disabled');
		END_IF
	
		// call upload webservice
		internal.WebUploadWithUuidAuth_0();
		IF EDGEPOS(internal.WebUploadWithUuidAuth_0.enable) = TRUE THEN
			wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO,'RbacAuthWs',  'upload webservice was enabled');
		END_IF
		IF EDGENEG(internal.WebUploadWithUuidAuth_0.enable) = TRUE THEN
			wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'RbacAuthWs', 'upload webservice was disabled');
		END_IF
	
		
	ELSE

		status := 16#FFFE;
		internal.rbacauthws_Step := rbacauthws_STEP_WAIT;

		(* Unregister Webservice *)
		internal.Webservice(enable := 0);
		internal.WebUploadWithUuidAuth_0(enable := 0);
		internal.ArUserAuthenticatePassword_0(Execute := 0);
		internal.ArUserHasRole_0(Execute := 0);
		internal.UUIDGenerator_0(enable := 0);
		
	END_IF
	
	wsUploadEnabled := internal.WebUploadWithUuidAuth_0.enable;
	statusWsUpload := internal.WebUploadWithUuidAuth_0.Status;
	wsAuthEnabled := internal.Webservice.enable;
	wsUploadCounter := internal.WebUploadWithUuidAuth_0.uploadCounter;
	wsUploadLastFileSize := internal.WebUploadWithUuidAuth_0.sourceFileSize;
	wsUploadLastFileName := internal.WebUploadWithUuidAuth_0.targetFileName;
	uuidGenPhase := internal.UUIDGenerator_0.phase;
	wsUploadTimerET := internal.TON_UploadSwitchoff.ET;
	
	
	
END_FUNCTION_BLOCK
