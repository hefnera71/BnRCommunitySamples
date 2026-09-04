(*
// Copyright (c) 2026 Andreas Werbelow, Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)


(* Function block to handle files that are sent to service, write them to given device and file *)
FUNCTION_BLOCK WebUploadWithUuidAuth
	
	internal.ArEventLogGetIdent_0(Execute := enable, Name := loggerName);

	IF NOT enable THEN
		internal.WebService.enable := FALSE;
		Done 			:= TRUE;
		Busy 			:= FALSE;
		Error 			:= FALSE;
		Status 			:= ERR_FUB_ENABLE_FALSE;
		sourceFileSize 	:= 0;
		userFinished	:= 0;
		internal.step 	:= WBUPUUID_STEP_WAIT;
	ELSE
		CASE internal.step OF
			WBUPUUID_STEP_WAIT:
				internal.FileCreate_0.enable := FALSE;
				internal.FileCreate_0();
				
				internal.FileOpen_0.enable := FALSE;
				internal.FileOpen_0();
				
				internal.FileWrite_0.enable := FALSE;
				internal.FileWrite_0();
				
				internal.FileClose_0.enable := FALSE;
				internal.FileClose_0();
				
				internal.FileDelete_0.enable := FALSE;
				internal.FileDelete_0();
				
				internal.DirCreate_0.enable := FALSE;
				internal.DirCreate_0();
				
				internal.GetBoundary_0.enable := FALSE;
				internal.GetBoundary_0();
				
				IF externalBufferSetup.pRequestBuffer > 0 AND externalBufferSetup.pMultipartBuffer > 0 AND externalBufferSetup.requestBufferSize > 0 AND externalBufferSetup.multipartBufferSize > 0 THEN 
					brsmemcpy(ADR(internal.bufferSetup),ADR(externalBufferSetup), SIZEOF(externalBufferSetup));
				ELSE
					internal.bufferSetup.pRequestBuffer := ADR(internal.RequestBuffer);
					internal.bufferSetup.pMultipartBuffer := ADR(internal.multipartMessage);
					internal.bufferSetup.requestBufferSize := SIZEOF(internal.RequestBuffer);
					internal.bufferSetup.multipartBufferSize := SIZEOF(internal.multipartMessage);
				END_IF
				
				internal.WebService.enable 			:= TRUE;
				internal.WebService.pServiceName 	:= ADR(serviceName);
				internal.WebService.option 			:= httpOPTION_HTTP_11 + httpOPTION_SERVICE_TYPE_NAME;
				internal.WebService.pResponseHeader := ADR(internal.ResponseHeader);
				internal.WebService.pResponseData 	:= ADR(internal.Response);
				internal.WebService.pRequestData  	:= internal.bufferSetup.pRequestBuffer;
				internal.WebService.requestDataSize := internal.bufferSetup.requestBufferSize;
				internal.WebService.pRequestHeader 	:= ADR(internal.RequestHeader);
				internal.WebService.pUri			:= ADR(internal.RequestUri);
				internal.WebService.uriSize			:= SIZEOF(internal.RequestUri);
				
				Done 	:= TRUE;
				Error 	:= FALSE;
				Busy 	:= FALSE;
				Status 	:= 0;
				internal.fileOffset 	:= 0;
				internal.closeFile 		:= FALSE;
				
				internal.step := WBUPUUID_STEP_HANDLE_REQUESTS;
			
			WBUPUUID_STEP_HANDLE_REQUESTS:
				// File completely received
				Done 	:= TRUE;
				Error 	:= FALSE;
				Busy 	:= FALSE;
				
				IF internal.WebService.send THEN 
					internal.WebService.send := FALSE;
				ELSIF internal.WebService.status = ERR_OK AND internal.WebService.phase = httpPHASE_RECEIVED AND internal.WebService.send = FALSE THEN 

					wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'wbuplduuid', 'upload webservice was called');
					
					internal.UrlParam.enable := TRUE;
					internal.UrlParam.pSrc := ADR(internal.RequestUri);

					internal.UrlParam.pParam := ADR('uuid');
					internal.UrlParam.pValue := ADR(internal.param1);
					internal.UrlParam.valueSize := SIZEOF(internal.param1);
					internal.UrlParam();

					internal.UrlParam.pParam := ADR('do_upload');
					internal.UrlParam.pValue := ADR(internal.param2);
					internal.UrlParam.valueSize := SIZEOF(internal.param2);
					internal.UrlParam();

					internal.UrlParam.pParam := ADR('mode');
					internal.UrlParam.pValue := ADR(internal.param3);
					internal.UrlParam.valueSize := SIZEOF(internal.param3);
					internal.UrlParam();
					IF internal.param3 <> 'html' THEN
						internal.ResponseHeader.contentType 	:= 'application/json';
						internal.bModeIsJson := TRUE;
					ELSE
						internal.ResponseHeader.contentType 	:= 'text/html';
						internal.bModeIsJson := FALSE;
					END_IF						

					internal.UrlParam.pParam := ADR('end_upload');
					internal.UrlParam.pValue := ADR(internal.param4);
					internal.UrlParam.valueSize := SIZEOF(internal.param4);
					internal.UrlParam();

					IF uuid <> '' AND internal.param1 = uuid THEN
						// approved
	
						IF internal.param4 = 'true' THEN
							// user signal -> finished
							userFinished := TRUE;
							IF NOT internal.bModeIsJson THEN
								brsstrcpy(ADR(internal.Response), ADR('<html><head></head><body>Ended!</body></html>'));
							ELSE
								brsstrcpy(ADR(internal.Response), ADR('{status:"ok", info:"ended"}'));
							END_IF
							internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
							internal.WebService.send := TRUE;
							internal.step := WBUPUUID_STEP_WAIT;

						ELSE
							
							IF internal.param2 <> 'true' THEN
								// send html code
								
								IF NOT internal.bModeIsJson THEN
									brsstrcpy(ADR(internal.Response), ADR('<html><head></head><body width="100%" height="100%">Choose file to upload:<br><form id="ulform" action="'));
									brsstrcat(ADR(internal.Response), ADR(serviceName));
									brsstrcat(ADR(internal.Response), ADR('?do_upload=true&mode=html&uuid='));
									brsstrcat(ADR(internal.Response),ADR(internal.param1));
									brsstrcat(ADR(internal.Response),ADR('" method="post" enctype="multipart/form-data"><input id="browseButton" name="datei" type="file" size="20000" accept="*.*" style="display:none" onchange="showFileName()"/><button type="button" onClick="document.getElementById($'browseButton$').click();">Browse...</button><span id="fileName">No file selected</span><button type="submit">Upload</button></form><script>function showFileName() {const input = document.getElementById($'browseButton$');const fileName = document.getElementById($'fileName$');if (input.files && input.files.length > 0) {fileName.textContent = input.files[0].name;} else {fileName.textContent = $'no file selected$';}}</script></body></html>'));
								ELSE
									brsstrcpy(ADR(internal.Response), ADR('{status:"error", info:"parameters missing?"}'));
								END_IF
								
								internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
								internal.WebService.send := TRUE;
								internal.step := WBUPUUID_STEP_WAIT;
								
							ELSE
								
								wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'wbuplduuid', 'upload webservice file upload started');
								// send file
								internal.GetBoundary_0.enable := TRUE;
								internal.GetBoundary_0.boundarySize := SIZEOF(internal.multipartBoundary);
								internal.GetBoundary_0.pBoundary := ADR(internal.multipartBoundary);
								internal.GetBoundary_0.pStruct := ADR(internal.RequestHeader);
								internal.step := WBUPUUID_STEP_PARSE_BOUNDARY;
								
							END_IF
						
						END_IF
						
					ELSE
						// declined
						// we have to send a negative response
						wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'wbuplduuid', 'upload webservice unauthorized or uuid missing');
						IF NOT internal.bModeIsJson THEN
							brsstrcpy(ADR(internal.Response), ADR('<html><body>Uploading unauthorized or uuid missing</body></html>'));
						ELSE
							brsstrcpy(ADR(internal.Response), ADR('{status:"error", info:"uploading unauthorized or uuid missing"}'));
						END_IF

						internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
						internal.WebService.send := TRUE;
						internal.step := WBUPUUID_STEP_WAIT;
					
					END_IF
				
				END_IF	
			
			WBUPUUID_STEP_PARSE_BOUNDARY:
				Done 	:= FALSE;
				Error 	:= FALSE;
				Busy 	:= TRUE;

				// parse Boundary-String

				// POST-Form Dateiname herausfiltern
				internal.strPosFilenameStart := wbuuid_strFindFromPos(internal.bufferSetup.pRequestBuffer, ADR('filename='), 0);
				internal.strPosFilenameEnd := wbuuid_strFindFromPos(internal.bufferSetup.pRequestBuffer, ADR('$R'), internal.strPosFilenameStart) - 2;
								
				IF internal.strPosFilenameStart = 0 OR internal.strPosFilenameEnd = 0 OR internal.strPosFilenameEnd < internal.strPosFilenameStart THEN
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				ELSE
					brsmemset(ADR(targetFileName), 0, SIZEOF(targetFileName));
					brsmemcpy(ADR(targetFileName), internal.bufferSetup.pRequestBuffer + internal.strPosFilenameStart + brsstrlen( ADR('filename=')), internal.strPosFilenameEnd - (internal.strPosFilenameStart + brsstrlen( ADR('filename='))));
				
					internal.GetBoundary_0();
				
					IF internal.GetBoundary_0.status = ERR_OK THEN
						brsstrcpy(ADR(internal.fileName), ADR(targetDirectoryName));
						brsstrcat(ADR(internal.fileName), ADR('/'));
						brsstrcat(ADR(internal.fileName), ADR(targetFileName));
						internal.step := WBUPUUID_STEP_DELETE_FILE;		
					ELSIF internal.GetBoundary_0.status < ERR_FUB_ENABLE_FALSE THEN
						Status := internal.GetBoundary_0.status;
						internal.step := WBUPUUID_STEP_SEND_ERROR;
					END_IF	
				END_IF	
					
			WBUPUUID_STEP_DELETE_FILE:
				// Delete previous file
				internal.FileDelete_0.enable 	:= TRUE;
				internal.FileDelete_0.pDevice 	:= ADR(targetDeviceName);
				internal.FileDelete_0.pName 	:= ADR(internal.fileName);
				internal.FileDelete_0();
					
				IF internal.FileDelete_0.status = ERR_OK OR internal.FileDelete_0.status = fiERR_FILE_NOT_FOUND THEN
					internal.step := WBUPUUID_STEP_CREATE_DIRECTORY;	
				ELSIF internal.FileDelete_0.status < ERR_FUB_ENABLE_FALSE THEN
					Status := internal.FileDelete_0.status;
					internal.closeFile := TRUE;
					internal.step := WBUPUUID_STEP_SEND_ERROR;	
				END_IF	
			
			WBUPUUID_STEP_CREATE_DIRECTORY:
				// Delete previous file
				internal.DirCreate_0.enable 	:= TRUE;
				internal.DirCreate_0.pDevice 	:= ADR(targetDeviceName);
				internal.DirCreate_0.pName 		:= ADR(targetDirectoryName);
				internal.DirCreate_0();
					
				IF internal.DirCreate_0.status = ERR_OK OR internal.DirCreate_0.status = fiERR_DIR_ALREADY_EXIST THEN
					internal.step := WBUPUUID_STEP_CREATE_FILE;	
				ELSIF internal.DirCreate_0.status < ERR_FUB_ENABLE_FALSE THEN
					Status := internal.DirCreate_0.status;
					internal.step := WBUPUUID_STEP_SEND_ERROR;	
				END_IF	
						
			WBUPUUID_STEP_CREATE_FILE:
				// Create file for upload
				internal.FileCreate_0.enable 	:= TRUE;
				internal.FileCreate_0.pDevice 	:= ADR(targetDeviceName);
				internal.FileCreate_0.pFile 	:= ADR(internal.fileName);
				internal.FileCreate_0();
					
				IF internal.FileCreate_0.status = ERR_OK OR internal.FileCreate_0.status = fiERR_EXIST THEN
					internal.step := WBUPUUID_STEP_OPEN_FILE;	
				ELSIF internal.FileCreate_0.status < ERR_FUB_ENABLE_FALSE THEN
					Status := internal.FileCreate_0.status;
					internal.closeFile := TRUE;
					internal.step := WBUPUUID_STEP_SEND_ERROR;	
				END_IF	
			
			WBUPUUID_STEP_OPEN_FILE:
				// open the file
				internal.FileOpen_0.enable 	:= TRUE;
				internal.FileOpen_0.mode 	:= fiREAD_WRITE;
				internal.FileOpen_0.pDevice := ADR(targetDeviceName);
				internal.FileOpen_0.pFile 	:= ADR(internal.fileName);
				internal.FileOpen_0();
			
				IF internal.FileOpen_0.status = ERR_OK THEN
					internal.fileOffset := 0;
					internal.step := WBUPUUID_STEP_PARSE_MULTIPARTS;
				ELSIF internal.FileOpen_0.status < ERR_FUB_ENABLE_FALSE THEN	
					Status := internal.FileOpen_0.status;
					internal.closeFile := TRUE;
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF
						
			WBUPUUID_STEP_PARSE_MULTIPARTS:
				// get message from buffer
				internal.GetMultipartMessage_0.enable 				:= TRUE;
				internal.GetMultipartMessage_0.pSrc 				:= internal.bufferSetup.pRequestBuffer;
				internal.GetMultipartMessage_0.pBoundary 			:= ADR(internal.multipartBoundary);
				internal.GetMultipartMessage_0.pMessageHeader 		:= ADR(internal.messageHeader);
				internal.GetMultipartMessage_0.messageHeaderSize 	:= SIZEOF(internal.messageHeader);
				internal.GetMultipartMessage_0.pMessageData 		:= internal.bufferSetup.pMultipartBuffer;
				internal.GetMultipartMessage_0.messageDataSize 		:= internal.bufferSetup.multipartBufferSize - 1;
				internal.GetMultipartMessage_0();
				
				IF internal.GetMultipartMessage_0.status = 0 THEN
					IF internal.GetMultipartMessage_0.messageDataLen = 0 THEN
						internal.step := WBUPUUID_STEP_SEND_RESPONSE;
					ELSE
						internal.step := WBUPUUID_STEP_WRITE_FILE;
					END_IF	
				ELSIF internal.GetMultipartMessage_0.status = httpERR_NO_DATA THEN
					internal.step := WBUPUUID_STEP_SEND_RESPONSE;
				ELSIF internal.GetMultipartMessage_0.status = ERR_FUB_BUSY THEN	
					// WAIT
				ELSE
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF	
			
			WBUPUUID_STEP_WRITE_FILE:
				// write parsed buffer to file
				internal.FileWrite_0.enable 	:= TRUE;
				internal.FileWrite_0.ident 		:= internal.FileOpen_0.ident;
				internal.FileWrite_0.len 		:= internal.GetMultipartMessage_0.messageDataLen;
				internal.FileWrite_0.pSrc 		:= internal.bufferSetup.pMultipartBuffer;
				internal.FileWrite_0.offset 	:= internal.fileOffset;
				internal.FileWrite_0();
				
				IF internal.FileWrite_0.status = ERR_OK THEN
					internal.fileOffset := internal.fileOffset + internal.GetMultipartMessage_0.messageDataLen;
					internal.step := WBUPUUID_STEP_PARSE_MULTIPARTS;
				ELSIF internal.FileWrite_0.status < ERR_FUB_ENABLE_FALSE THEN
					Status := internal.FileOpen_0.status;
					internal.closeFile := TRUE;
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF							  
			
			WBUPUUID_STEP_SEND_RESPONSE:
				// close file
				internal.FileClose_0.enable 	:= TRUE;
				internal.FileClose_0.ident 		:= internal.FileOpen_0.ident;
				internal.FileClose_0();
					
				IF internal.FileClose_0.status = ERR_OK THEN
					sourceFileSize 	:= internal.fileOffset;

					brsmemset(ADR(internal.sTemp), 0, SIZEOF(internal.sTemp));
					internal.sTemp := 'upload webservice file upload finished. name: ';
					brsstrcat(ADR(internal.sTemp),ADR(targetFileName));
					brsstrcat(ADR(internal.sTemp),ADR(', bytesize: '));
					brsitoa(sourceFileSize,ADR(internal.sTemp) + brsstrlen(ADR(internal.sTemp)));
					wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_SUCCESS, 'wbuplduuid', internal.sTemp);
					
					// and send response
					IF NOT internal.bModeIsJson THEN
						brsstrcpy(ADR(internal.Response), ADR('<html><body>Done!<br><a href="./'));
						brsstrcat(ADR(internal.Response), ADR(serviceName));
						brsstrcat(ADR(internal.Response), ADR('?uuid='));
						brsstrcat(ADR(internal.Response), ADR(internal.param1));
						brsstrcat(ADR(internal.Response), ADR('">Another Upload?</a><br><a href="./'));
						brsstrcat(ADR(internal.Response), ADR(serviceName));
						brsstrcat(ADR(internal.Response), ADR('?uuid='));
						brsstrcat(ADR(internal.Response), ADR(internal.param1));
						brsstrcat(ADR(internal.Response), ADR('&end_upload=true&mode=html">Finished?</a><br>'));
						brsstrcat(ADR(internal.Response), ADR('</body></html>'));
					ELSE
						brsstrcpy(ADR(internal.Response), ADR('{status:"ok", info:"upload done"}'));
					END_IF
					
					internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
					internal.WebService.send := TRUE;
					
					// upload ready, increase counter
					uploadCounter := uploadCounter + 1;
				
					internal.step := WBUPUUID_STEP_HANDLE_REQUESTS;		
				ELSIF internal.FileClose_0.status < ERR_FUB_ENABLE_FALSE THEN
					internal.closeFile := TRUE;
					internal.step 	:= WBUPUUID_STEP_SEND_ERROR;
				END_IF
			
			WBUPUUID_STEP_SEND_ERROR:
				// and send response
				brsmemset(ADR(internal.sTemp), 0, SIZEOF(internal.sTemp));
				internal.sTemp := 'upload webservice internal function error: ';
				brsitoa(Status, ADR(internal.sTemp) + brsstrlen(ADR(internal.sTemp)));
				wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'wbuplduuid', internal.sTemp);
				IF NOT internal.bModeIsJson THEN
					brsstrcpy(ADR(internal.Response), ADR('<html><body>Error!</body></html>'));
				ELSE
					brsstrcpy(ADR(internal.Response), ADR('{status:"error", info:"upload failed"}'));
				END_IF

				internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
				internal.WebService.send := TRUE;
				internal.step 	:= WBUPUUID_STEP_SEND_ERROR_WAIT;
			
			WBUPUUID_STEP_SEND_ERROR_WAIT:
				internal.WebService.send := FALSE;
							
				IF internal.WebService.status = ERR_OK THEN
					internal.step := WBUPUUID_STEP_ERROR;
				ELSIF internal.WebService.status = ERR_FUB_BUSY THEN 
				ELSE
					internal.step := WBUPUUID_STEP_ERROR;
				END_IF
			
			WBUPUUID_STEP_ERROR:
				// error step
				internal.WebService.enable := FALSE;
				
				Done 	:= TRUE;
				Busy 	:= FALSE;
				Error 	:= TRUE;
			
				IF internal.closeFile THEN
					// close file if necessary
					internal.FileClose_0.enable 	:= TRUE;
					internal.FileClose_0.ident 		:= internal.FileCreate_0.ident;
					internal.FileClose_0();
					
					IF internal.FileClose_0.status = ERR_OK THEN
						internal.closeFile := FALSE;
					ELSIF internal.FileClose_0.status < ERR_FUB_ENABLE_FALSE THEN
						internal.closeFile := FALSE;
					END_IF
				END_IF
				
				IF errorReset THEN
					internal.step := WBUPUUID_STEP_WAIT;
				END_IF	
		END_CASE
	END_IF
	
	internal.WebService();
	
END_FUNCTION_BLOCK