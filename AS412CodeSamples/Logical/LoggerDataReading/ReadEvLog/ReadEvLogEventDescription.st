
(* Works ASYNCHRONOUS, can be used as extension for ReadEvLogEntries to get the event id description texts *)
FUNCTION_BLOCK ReadEvLogEventDescription

	IF EDGEPOS(execute) = TRUE THEN
		busy := TRUE;
		error := FALSE;
		statusID := 0;
		done := FALSE;
		Internal.FB.ArEvGetIdent(Execute := FALSE);
		Internal.FB.ArEvGetIdent.Execute := TRUE;
		Internal.FB.ArEvGetIdent.Name := loggerName;
		Internal.FB.ArEvGetIdent();
		IF pResultData > 0 AND resultDataSize > 0 THEN
			Internal.Ctrl.resultDataArraySize := resultDataSize / SIZEOF(ReadEvLog_Entry_type);
			IF loggerName <> '' THEN
				IF Internal.FB.ArEvGetIdent.Error = FALSE THEN
					IF nrOfReadDescFBInsts < 1 THEN
						Internal.Ctrl.nrOfReadDescInstances := 1;
					ELSIF nrOfReadDescFBInsts > SIZEOF(Internal.FB.ArEvLogReadDesc)/SIZEOF(Internal.FB.ArEvLogReadDesc[0]) THEN
						Internal.Ctrl.nrOfReadDescInstances := 	SIZEOF(Internal.FB.ArEvLogReadDesc)/SIZEOF(Internal.FB.ArEvLogReadDesc[0]);
					ELSE
						Internal.Ctrl.nrOfReadDescInstances := nrOfReadDescFBInsts;
					END_IF
					Internal.Ctrl.step := ReadEvLog_RUNNING;
					Internal.Ctrl.entryArrayStartIndex := 0;
					numberOfDescriptionsRead := 0;
				ELSE
					statusID := Internal.FB.ArEvGetIdent.StatusID;
					Internal.Ctrl.step := ReadEvLog_ERROR;
				END_IF
			ELSE		
				statusID := -2;
				Internal.Ctrl.step := ReadEvLog_ERROR;
			END_IF
		ELSE
			statusID := -1;
			Internal.Ctrl.step := ReadEvLog_ERROR;
		END_IF
	END_IF

	IF EDGENEG(execute) = TRUE THEN
		Internal.Ctrl.step := ReadEvLog_IDLE;
		numberOfDescriptionsRead := 0;
	END_IF
	
	
	CASE Internal.Ctrl.step OF
	
		ReadEvLog_RUNNING:
		
			Internal.Ctrl.fbBusyState := 0;
			FOR Internal.Ctrl.loopIndex := 0 TO Internal.Ctrl.nrOfReadDescInstances - 1 DO	// run trough all instances
				IF Internal.Ctrl.entryArrayStartIndex + Internal.Ctrl.loopIndex < Internal.Ctrl.resultDataArraySize THEN 	// check if the end of the data array size is reached 
					// get access to the next data array entry
					refResultEntry ACCESS pResultData + Internal.Ctrl.entryArrayStartIndex * SIZEOF(ReadEvLog_Entry_type) + Internal.Ctrl.loopIndex * SIZEOF(ReadEvLog_Entry_type);
					// get access to the next FB instance
					refArEvLogReadDesc ACCESS ADR(Internal.FB.ArEvLogReadDesc[Internal.Ctrl.loopIndex]);
					// check if data array has a value to check ... if zero, end of the data is reached
					IF refResultEntry.recordID > 0 THEN
						// run the FB instance async
						refArEvLogReadDesc.Execute := TRUE;
						refArEvLogReadDesc.Ident := Internal.FB.ArEvGetIdent.Ident;
						refArEvLogReadDesc.LanguageCode := languageCode;
						refArEvLogReadDesc.Qualifier := '';
						refArEvLogReadDesc.RecordID := refResultEntry.recordID;
						refArEvLogReadDesc.TextBuffer := ADR(refResultEntry.reservedForDesciption);
						refArEvLogReadDesc.TextBufferSize := SIZEOF(refResultEntry.reservedForDesciption);
						refArEvLogReadDesc();
						
						// OR all FB instances busy states to get the information when all instances are done
						Internal.Ctrl.fbBusyState := Internal.Ctrl.fbBusyState OR refArEvLogReadDesc.Busy;
						// if error happened when readind information text, stop here ... but first all FB instances have to finish
						IF refArEvLogReadDesc.Error = TRUE THEN
							IF Internal.Ctrl.fbBusyState = FALSE THEN
								Internal.Ctrl.step := ReadEvLog_ERROR;
								Internal.Ctrl.fbReset := TRUE;
							END_IF
							statusID := refArEvLogReadDesc.StatusID;
						ELSE
							IF refArEvLogReadDesc.Done = TRUE THEN
								// next entry from data array was read
								numberOfDescriptionsRead := numberOfDescriptionsRead + 1;
							END_IF
						END_IF 
						
					ELSE
						// empty record ID ... we're at the end of data inside the array, but we have to wait until all instances have finished
						IF Internal.Ctrl.fbBusyState = FALSE THEN
							Internal.Ctrl.step := ReadEvLog_FINISHED;
							Internal.Ctrl.fbReset := TRUE;
						END_IF
					END_IF
				ELSE
					// end of array reached, but we have to wait until all instances have finished
					IF Internal.Ctrl.fbBusyState = FALSE THEN
						Internal.Ctrl.step := ReadEvLog_FINISHED;
						Internal.Ctrl.fbReset := TRUE;
					END_IF
				END_IF
			END_FOR

			// more to read, no error until now ...
			IF Internal.Ctrl.fbBusyState = FALSE AND Internal.Ctrl.step = ReadEvLog_RUNNING THEN
				Internal.Ctrl.entryArrayStartIndex := Internal.Ctrl.entryArrayStartIndex + Internal.Ctrl.nrOfReadDescInstances;
				Internal.Ctrl.fbReset := TRUE;
			END_IF
			
			// don't forget to call all instances wit Execute = FALSE to reset the FB for next run
			IF Internal.Ctrl.fbReset = TRUE THEN
				FOR Internal.Ctrl.loopIndex := 0 TO SIZEOF(Internal.FB.ArEvLogReadDesc)/SIZEOF(Internal.FB.ArEvLogReadDesc[0]) - 1 DO
					Internal.FB.ArEvLogReadDesc[Internal.Ctrl.loopIndex]( Execute := FALSE );
				END_FOR
				Internal.Ctrl.fbReset := FALSE;
			END_IF
			
		ReadEvLog_ERROR:
			done := TRUE;
			error := TRUE;
			busy := FALSE;
		
		ReadEvLog_FINISHED:
			done := TRUE;
			error := FALSE;
			busy := FALSE;
		
		ReadEvLog_IDLE:
			done := FALSE;
			error := FALSE;
			busy := FALSE;
		
		ELSE
			Internal.Ctrl.step := ReadEvLog_UNKNOWNSTATE;
			error := TRUE;
	
	END_CASE	
	
	

END_FUNCTION_BLOCK
