(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

FUNCTION_BLOCK tasmotapiSendRequest

	IF EDGEPOS(enable) = TRUE THEN
		sendCommandError := FALSE;
		sendCommandSuccess := FALSE;
		sendCommandBusy := FALSE;
		status := 0;
		stepSendRequest := tasmotapiSTEP_IDLE;
		// client is ebanbeld when this instance is called the first time 
	END_IF
	
	IF EDGENEG(enable) = TRUE THEN
		Client.enable := FALSE;
		sendCommandBusy := FALSE;
		stepSendRequest := tasmotapiSTEP_IDLE;
		responseDataLen := 0;
	END_IF
	
	IF enable = TRUE THEN

		// bSendCommand is resetted by user -> so reset all status information when bSendCommand is set to 0
		IF EDGENEG(bSendCommand) = TRUE THEN
			sendCommandBusy := FALSE;
			sendCommandError := FALSE;
			sendCommandSuccess := FALSE;
			httpStatus := 0;
		END_IF
		

		IF EDGEPOS(bSendCommand) = TRUE THEN
			sendCommandBusy := TRUE;
			sendCommandError := FALSE;
			sendCommandSuccess := FALSE;
			httpStatus := 0;
			responseDataLen := 0;
			
			// check some basics
			IF sHost = '' OR sCommand = '' OR pResponseBuffer = 0 AND uResponseBufferSize = 0 THEN
				// PARAMETER ERROR!!
				status := tasmotapiERROR_PARAMETER;
				sendCommandError := TRUE;
			ELSE
				// clear buffers
				brsmemset(ADR(requestBuffer), 0, SIZEOF(requestBuffer));
				brsmemset(pResponseBuffer, 0, uResponseBufferSize);
								
				// set pot 80 = http to default if port is not setup externally
				IF uPort = 0 THEN
					tAPI.Config.Port := 80;
				ELSE
					tAPI.Config.Port := uPort;
				END_IF
				
				// copy request specific data to internal struct to avoid changes while request is running
				tAPI.Config.Host := sHost;
				tAPI.Parameter.cmnd := sCommand;
				IF (sUser <> '') THEN
					tAPI.Parameter.user := sUser;
					tAPI.Parameter.password := sPassword;
				END_IF
		
				// build request URI - add user and password only, if user string is set (user + password is optional in tasmota)
				IF tAPI.Parameter.user <> '' THEN
					SetParam.enable := TRUE;
					SetParam.pDest := ADR(requestBuffer);
					SetParam.destSize := SIZEOF(requestBuffer);
					SetParam.pParam := ADR('user');
					SetParam.pValue := ADR(tAPI.Parameter.user);
					SetParam();
			
					SetParam.enable := TRUE;
					SetParam.pDest := ADR(requestBuffer);
					SetParam.destSize := SIZEOF(requestBuffer);
					SetParam.pParam := ADR('password');
					SetParam.pValue := ADR(tAPI.Parameter.password);
					SetParam();
				END_IF
					
				SetParam.enable := TRUE;
				SetParam.pDest := ADR(requestBuffer);
				SetParam.destSize := SIZEOF(requestBuffer);
				SetParam.pParam := ADR('cmnd');
				SetParam.pValue := ADR(tAPI.Parameter.cmnd);
				SetParam();
		
				// using GET -> /cm is the tasmota webservice name
				tAPI.Config.Uri := '/cm';
				brsstrcat(ADR(tAPI.Config.Uri),ADR(requestBuffer));
				
				// setup http client instance
				Client.pResponseData := pResponseBuffer;
				Client.responseDataSize := uResponseBufferSize;

				Client.option 			:= httpOPTION_HTTP_11;
				Client.hostPort			:= tAPI.Config.Port;
				Client.pHost			:= ADR(tAPI.Config.Host);
				Client.pUri				:= ADR(tAPI.Config.Uri);

				Client.method 			:= httpMETHOD_GET;
				Client.pRequestData		:= 0;
				Client.requestDataLen 	:= 0;
	
				Client.pResponseHeader	:= ADR(tAPI.Header.tResponseHeader);

				// enable http client
				Client.enable := TRUE;

				// start sending!!
				stepSendRequest := tasmotapiSTEP_SEND;
				sendCommandBusy := TRUE;
				
			END_IF // parameter error check
		
		END_IF // edgepos bSendCommand


		CASE stepSendRequest OF
		
			tasmotapiSTEP_IDLE:
			// do nothing
			
			tasmotapiSTEP_SEND:
				Client.send := TRUE;
				stepSendRequest := tasmotapiSTEP_WAIT_RESPONSE;

			tasmotapiSTEP_WAIT_RESPONSE:
				// wait some time for connect & response, also to protect tasmota device from too many requests
				TONWaitForResponse.IN := TRUE;
				TONWaitForResponse.PT := T#1s;
				TONWaitForResponse();
				IF TONWaitForResponse.Q = TRUE THEN
					TONWaitForResponse.IN := FALSE;
					TONWaitForResponse();
					stepSendRequest := tasmotapiSTEP_RESPONSE;
				END_IF
			
			tasmotapiSTEP_RESPONSE:
				CASE Client.phase OF
					httpPHASE_RECEIVED, httpPHASE_NOT_CONNECTED:
						IF Client.httpStatus = 200 THEN
							// http status 200 = positive response from web server
							stepSendRequest := tasmotapiSTEP_END;
							sendCommandSuccess := TRUE;
							sendCommandError := FALSE;
							Client.send := FALSE;
						ELSE
							stepSendRequest := tasmotapiSTEP_ABORTED;
							sendCommandSuccess := FALSE;
							sendCommandError := TRUE;
							Client.abort := TRUE;
						END_IF
						httpStatus := Client.httpStatus;

					httpPHASE_SENDING:
					httpPHASE_WAITING:
					httpPHASE_RECEIVING:
				END_CASE

			tasmotapiSTEP_ABORTED:
				Client.abort := FALSE;
				Client.send := FALSE;
				stepSendRequest := tasmotapiSTEP_END;
		
			tasmotapiSTEP_END:
				stepSendRequest := tasmotapiSTEP_IDLE;
				responseDataLen := Client.responseDataLen;
				sendCommandBusy := FALSE;
			
		END_CASE
			
	END_IF // enable = TRUE
	
	
	Client();
	IF status <> tasmotapiERROR_PARAMETER THEN
		status := Client.status;
	END_IF
	

	
	
	
	
	
END_FUNCTION_BLOCK