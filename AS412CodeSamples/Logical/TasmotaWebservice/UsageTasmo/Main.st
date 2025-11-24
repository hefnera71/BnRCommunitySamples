
PROGRAM _INIT
	
	tasmotapiSendRequest_0.sHost := '192.168.168.185';	// ip of the tasmota device
	tasmotapiSendRequest_0.uPort := 80;					// web port of the tasmota device
	tasmotapiSendRequest_0.sUser := '';					// use this if authentication is enabled on the tasmota device
	tasmotapiSendRequest_0.sPassword := '';				// use this if authentication is enabled on the tasmota device
	tasmotapiSendRequest_0.sCommand := 'status 10';		// status 10 == get sensor data // see here for Tasmota commands: https://tasmota.github.io/docs/Commands/
	tasmotapiSendRequest_0.pResponseBuffer := ADR(sResponse);			// where to store the response data
	tasmotapiSendRequest_0.uResponseBufferSize := SIZEOF(sResponse);	// size of the response data buffer
	
	tasmotapiSendRequest_0.enable := TRUE; 	// activate fb
	
END_PROGRAM

PROGRAM _CYCLIC
	
	IF bSendRequest = TRUE THEN
		tasmotapiSendRequest_0.bSendCommand := TRUE;
	END_IF

	// call fb cyclic
	tasmotapiSendRequest_0();
	
	IF tasmotapiSendRequest_0.sendCommandBusy = TRUE THEN
		// busy, keep calling with .bSendCommand = TRUE	
	ELSE
		IF tasmotapiSendRequest_0.sendCommandError = TRUE THEN
			// some error happened, check status informations of fb
		ELSIF tasmotapiSendRequest_0.sendCommandSuccess = TRUE THEN
			// ok, check and process data
		END_IF

		bSendRequest := FALSE;
		// WHEN FINISHED reading / processing status outputs of the fc instance, DON'T FORGET to reset the send flag
		// most of the status information are then resetted, too
		tasmotapiSendRequest_0.bSendCommand := FALSE;
	END_IF
		
END_PROGRAM

PROGRAM _EXIT
	
	tasmotapiSendRequest_0(enable := FALSE);

END_PROGRAM

