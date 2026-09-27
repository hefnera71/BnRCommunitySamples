(*
// Copyright (c) 2026 Andreas Werbelow, Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

// changes
// V1.00.4 added filename check, changed way of reading filename out of message, some bug fixing + debug infos
// V1.00.3 fixed string sizes
// V1.00.2 added html mode suspression
// V1.00.1 initial version

(*
	UUID-authenticated HTTP upload service.
	The client first requests the upload form, then posts multipart file data in
	chunks. The UUID in the request URI must match uuid before file operations
	are allowed. Responses can be JSON or optional HTML, selected by the mode
	request parameter.

	State flow: initialize service -> handle request -> parse multipart data ->
	delete/create/open file -> write chunks -> close file and respond. Errors
	are reported through Status and the response, with errorReset returning to
	the waiting state.

	externalBufferSetup is optional. When all of its pointer and size fields
	are valid, the caller-provided buffers are used; otherwise internal buffers
	are used. targetDirectoryName and targetDeviceName determine the upload
	destination, and the received filename is validated before being appended.
*)
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
		uploadCounter	:= 0;
		targetFileName	:= '';
	ELSE
		CASE internal.step OF
			WBUPUUID_STEP_WAIT:
				// Reset subordinate function blocks and configure the HTTP service.
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
				
				internal.GetBoundary_0.enable := FALSE;
				internal.GetBoundary_0();
				
				internal.GetMultipartMessage_0.enable := FALSE;
				internal.GetMultipartMessage_0();
				
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
				internal.WebService.pStatistics		:= ADR(internal.tStatistics);
				
				Done 	:= TRUE;
				Error 	:= FALSE;
				Busy 	:= FALSE;
				Status 	:= 0;
				internal.fileOffset 	:= 0;
				internal.closeFile 		:= FALSE;
				
				internal.step := WBUPUUID_STEP_HANDLE_REQUESTS;
				
			WBUPUUID_STEP_HANDLE_REQUESTS:
				// Parse request parameters and authorize the upload with the UUID.
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
							internal.bUserFinished := TRUE;
							IF NOT internal.bModeIsJson AND enableHtmlMode = TRUE THEN
								brsstrcpy(ADR(internal.Response), ADR('<html><head></head><body><h2>Ended!</h2></body></html>'));
							ELSE
								brsstrcpy(ADR(internal.Response), ADR('{status:"ok", info:"ended"}'));
							END_IF
							internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
							internal.WebService.send := TRUE;
							internal.step := WBUPUUID_STEP_WAIT;

						ELSE
							
							IF internal.param2 <> 'true' THEN
								// send html code
								
								IF NOT internal.bModeIsJson AND enableHtmlMode = TRUE THEN
									brsstrcpy(ADR(internal.Response), ADR('<html><head><style> body { width: 100%; height: 100%; } .hidden { display: none; } .buttonStyle { position: relative; width: 90px; height: 35px; margin: 5px; cursor: pointer; } #fileName { margin: 5px; font-family: Arial, sans-serif; } </style></head><body width="100%" height="100%"><h2>Select file to upload</h2><form id="ulform" action="'));
									brsstrcat(ADR(internal.Response), ADR(serviceName));
									brsstrcat(ADR(internal.Response), ADR('?do_upload=true&mode=html&uuid='));
									brsstrcat(ADR(internal.Response),ADR(internal.param1));
									brsstrcat(ADR(internal.Response),ADR('" method="post" enctype="multipart/form-data"><input id="browseButton" name="datei" type="file" accept="*.*" class="hidden" onchange="showFileName()"/><button type="button" class="buttonStyle" onClick="document.getElementById($'browseButton$').click();">Browse...</button><span id="fileName">No file selected</span><button type="submit" class="buttonStyle">Upload</button></form><script>function showFileName() {const input = document.getElementById($'browseButton$');const fileName = document.getElementById($'fileName$');if (input.files && input.files.length > 0) {fileName.textContent = input.files[0].name;} else {fileName.textContent = $'no file selected$';}}</script></body></html>'));
								ELSE
									brsstrcpy(ADR(internal.Response), ADR('{status:"error", info:"parameters missing?"}'));
								END_IF
								
								internal.WebService.responseDataLen := brsstrlen(ADR(internal.Response));
								internal.WebService.send := TRUE;
								internal.step := WBUPUUID_STEP_WAIT;
								
							ELSE
								
								wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_INFO, 'wbuplduuid', 'upload webservice file upload started');
								// send file
								internal.bFirstWrite 	:= TRUE;
								internal.step := WBUPUUID_STEP_PARSE_BOUNDARY;
								
							END_IF
						
						END_IF
						
					ELSE
						// declined
						// we have to send a negative response
						wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'wbuplduuid', 'upload webservice unauthorized or uuid missing');
						IF NOT internal.bModeIsJson AND enableHtmlMode = TRUE THEN
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
				// Extract the multipart boundary from the HTTP request header.
				Done 	:= FALSE;
				Error 	:= FALSE;
				Busy 	:= TRUE;

				// get boundary
				internal.GetBoundary_0.enable := TRUE;
				internal.GetBoundary_0.boundarySize := SIZEOF(internal.multipartBoundary);
				internal.GetBoundary_0.pBoundary := ADR(internal.multipartBoundary);
				internal.GetBoundary_0.pStruct := ADR(internal.RequestHeader);
				
				internal.GetBoundary_0();
						
				IF internal.GetBoundary_0.status = ERR_OK THEN
					internal.step := WBUPUUID_STEP_PARSE_MULTIPARTS;		
				ELSIF internal.GetBoundary_0.status < ERR_FUB_ENABLE_FALSE THEN
					Status := internal.GetBoundary_0.status;
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF	
					
			WBUPUUID_STEP_DELETE_FILE:
				// Delete previous file
				internal.FileDelete_0.enable 	:= TRUE;
				internal.FileDelete_0.pDevice 	:= ADR(targetDeviceName);
				internal.FileDelete_0.pName 	:= ADR(internal.fileName);
				internal.FileDelete_0();
					
				IF internal.FileDelete_0.status = ERR_OK OR internal.FileDelete_0.status = fiERR_FILE_NOT_FOUND THEN
					internal.step := WBUPUUID_STEP_CREATE_FILE;	
				ELSIF internal.FileDelete_0.status < ERR_FUB_ENABLE_FALSE THEN
					Status := internal.FileDelete_0.status;
					internal.closeFile := TRUE;
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
					//internal.step := WBUPUUID_STEP_PARSE_MULTIPARTS;
					internal.step := WBUPUUID_STEP_WRITE_FILE;
				ELSIF internal.FileOpen_0.status < ERR_FUB_ENABLE_FALSE THEN	
					Status := internal.FileOpen_0.status;
					internal.closeFile := TRUE;
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF
						
			WBUPUUID_STEP_PARSE_MULTIPARTS:
				// Extract one multipart chunk; the first chunk also supplies the filename.
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
						IF	internal.bFirstWrite = TRUE THEN
							internal.bFirstWrite := FALSE;
	
							internal.sTemp := 'filename="';						
							internal.fnFirstPos := wbuuid_strFindFromPos(ADR(internal.messageHeader), ADR(internal.sTemp), 0) + brsstrlen(ADR(internal.sTemp));
							internal.fnLastPos := wbuuid_strFindFromPos(ADR(internal.messageHeader), ADR('"'), internal.fnFirstPos);
							IF internal.fnFirstPos > 0 AND internal.fnLastPos > internal.fnFirstPos AND (internal.fnLastPos - internal.fnFirstPos) < SIZEOF(targetFileName) THEN
								brsmemset(ADR(targetFileName), 0, SIZEOF(targetFileName));
								brsmemcpy(ADR(targetFileName), ADR(internal.messageHeader) + internal.fnFirstPos - 1, internal.fnLastPos - internal.fnFirstPos);
								// check file name
								IF wbuuid_ValidateFileName(ADR(targetFileName), SIZEOF(targetFileName)) = FALSE THEN
									Status := wbuplduuid_ERR_CHARFN;
									wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'wbuplduuid', 'upload webservice error illegal chars in filename');
									internal.step := WBUPUUID_STEP_SEND_ERROR;
								ELSE
									// build complete filename + path
									brsstrcpy(ADR(internal.fileName), ADR(targetDirectoryName));
									brsstrcat(ADR(internal.fileName), ADR('/'));
									brsstrcat(ADR(internal.fileName), ADR(targetFileName));
									// go on with delete + create + oprn
									internal.step := WBUPUUID_STEP_DELETE_FILE;
								END_IF

							ELSE
								// had problems parsing the filename out of the header
								Status := wbuplduuid_ERR_PARSEFN;
								wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'wbuplduuid', 'upload webservice error parsing filename from message');
								internal.step := WBUPUUID_STEP_SEND_ERROR;
							END_IF
						ELSE
							internal.step := WBUPUUID_STEP_WRITE_FILE;
						END_IF
					END_IF	
				ELSIF internal.GetMultipartMessage_0.status = httpERR_NO_DATA THEN
					internal.step := WBUPUUID_STEP_SEND_RESPONSE;
				ELSIF internal.GetMultipartMessage_0.status = ERR_FUB_BUSY THEN	
					// WAIT
				ELSE
					Status := internal.GetMultipartMessage_0.status;
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF	
			
			WBUPUUID_STEP_WRITE_FILE:
				// Append the current multipart data chunk at the tracked file offset.
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
					Status := internal.FileWrite_0.status;
					internal.closeFile := TRUE;
					internal.step := WBUPUUID_STEP_SEND_ERROR;
				END_IF							  
			
			WBUPUUID_STEP_SEND_RESPONSE:
				// Close the completed file and return the success response.
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
					IF NOT internal.bModeIsJson AND enableHtmlMode = TRUE THEN
						brsstrcpy(ADR(internal.Response), ADR('<html><head><style> body { width: 100%; height: 100%; } .textStyle { margin-left: 10px; font-family: Arial, sans-serif; }</style></head><body><h2>Done!</h2><span style="textStyle"><a href="./'));
						brsstrcat(ADR(internal.Response), ADR(serviceName));
						brsstrcat(ADR(internal.Response), ADR('?uuid='));
						brsstrcat(ADR(internal.Response), ADR(internal.param1));
						brsstrcat(ADR(internal.Response), ADR('&mode=html">Another Upload?</a><br><a href="./'));
						brsstrcat(ADR(internal.Response), ADR(serviceName));
						brsstrcat(ADR(internal.Response), ADR('?uuid='));
						brsstrcat(ADR(internal.Response), ADR(internal.param1));
						brsstrcat(ADR(internal.Response), ADR('&end_upload=true&mode=html"><br>Finished?</a></span><br>'));
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
					Status := internal.FileClose_0.status;
					internal.step 	:= WBUPUUID_STEP_SEND_ERROR;
				END_IF
			
			WBUPUUID_STEP_SEND_ERROR:
				// Return the internal error and prepare cleanup in the error state.
				brsmemset(ADR(internal.sTemp), 0, SIZEOF(internal.sTemp));
				internal.sTemp := 'upload webservice internal function error: ';
				brsitoa(Status, ADR(internal.sTemp) + brsstrlen(ADR(internal.sTemp)));
				wbuuid_FcWriteArLog(internal.ArEventLogGetIdent_0.Ident, frcwritearlog_ERROR, 'wbuplduuid', internal.sTemp);
				IF NOT internal.bModeIsJson AND enableHtmlMode = TRUE THEN
					brsstrcpy(ADR(internal.Response), ADR('<html><body>Error!<br>'));
					brsstrcat(ADR(internal.Response), ADR(internal.sTemp));
					brsstrcat(ADR(internal.Response), ADR('</body></html>'));
				ELSE
					brsstrcpy(ADR(internal.Response), ADR('{status:"error", info:"upload failed. '));
					brsstrcat(ADR(internal.Response), ADR(internal.sTemp));
					brsstrcat(ADR(internal.Response), ADR('"}'));
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
				// Disable the service, finish the current request, and close open files.
				internal.WebService.enable := FALSE;
				
				Done 	:= TRUE;
				Busy 	:= FALSE;
				Error 	:= TRUE;
			
				IF internal.closeFile THEN
					// close file if necessary
					internal.FileClose_0.enable 	:= TRUE;
					internal.FileClose_0.ident 		:= internal.FileOpen_0.ident;
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
	
	// reset user signal if existing to ensure last response was sent
	IF internal.bUserFinished = TRUE AND internal.WebService.status <> 16#FFFF THEN 
		userFinished := TRUE;
		internal.bUserFinished := FALSE;
	END_IF
			
	
	
END_FUNCTION_BLOCK