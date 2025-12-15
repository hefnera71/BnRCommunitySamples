(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* works SYNCRONOUS - read a number of logger entries into a data structure *)
FUNCTION_BLOCK ReadEvLogEntries

	IF EDGEPOS(execute) = TRUE THEN
		Internal.Ctrl.identValid := FALSE;
		Internal.Ctrl.recordValid := FALSE;
		done := FALSE;
		error := FALSE;
		statusID := 0;
		busy := TRUE;
		numberOfEntriesRead := 0;
		numberOfEntriesProcessed := 0;
		severityCounters.error := 0;
		severityCounters.info := 0;
		severityCounters.success := 0;
		severityCounters.warning := 0;
		Internal.Ctrl.arrayIndex := 0;					
		IF pResultData > 0 AND resultDataSize > 0 THEN
			IF loggerName <> '' THEN
				Internal.Ctrl.step := ReadEvLog_RUNNING;
				Internal.Ctrl.resultDataArraySize := resultDataSize / SIZEOF(ReadEvLog_Entry_type);
				IF useReadFilter = TRUE THEN
					IF readFilterSetup.maxNumberOfEntriesRead = 0 THEN
						statusID := -3;
						Internal.Ctrl.step := ReadEvLog_ERROR;
					ELSE
						Internal.Ctrl.loopSize := readFilterSetup.maxNumberOfEntriesRead;
					END_IF
				ELSE
					Internal.Ctrl.loopSize := Internal.Ctrl.resultDataArraySize;
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
		done := FALSE;
		error := FALSE;
		statusID := 0;
		busy := FALSE;
		more := FALSE;			
		Internal.Ctrl.step := ReadEvLog_IDLE;
		numberOfEntriesRead := 0;
		numberOfEntriesProcessed := 0;			
		severityCounters.error := 0;
		severityCounters.info := 0;
		severityCounters.success := 0;
		severityCounters.warning := 0;					
		Internal.Ctrl.arrayIndex := 0;					
	END_IF
	
	IF EDGEPOS(next) = TRUE THEN
		IF execute = TRUE AND error = FALSE AND numberOfEntriesRead > 0 AND more = TRUE THEN
			busy := TRUE;
			Internal.Ctrl.step := ReadEvLog_RUNNING;
			Internal.Ctrl.arrayIndex := 0;					
		ELSE
			
		END_IF
	END_IF
				
	
	IF Internal.Ctrl.step = ReadEvLog_RUNNING THEN
		
		// check if it's the first call, or if we already have a ident			
		IF Internal.Ctrl.identValid = FALSE THEN
			Internal.FB.ArEvGetIdent(Execute := FALSE);
			Internal.FB.ArEvGetIdent.Name := loggerName;
			Internal.FB.ArEvGetIdent.Execute := TRUE;
			Internal.FB.ArEvGetIdent();
			
			IF Internal.FB.ArEvGetIdent.Error = FALSE THEN
				Internal.Ctrl.identValid := TRUE;
				Internal.Ctrl.ident := Internal.FB.ArEvGetIdent.Ident;
				
				IF recordIdStart = 0 THEN
					// get the last logger entry		
					Internal.FB.ArEvGetLatestID(Execute := FALSE);
					Internal.FB.ArEvGetLatestID.Ident := Internal.Ctrl.ident;
					Internal.FB.ArEvGetLatestID.Execute := TRUE;
					Internal.FB.ArEvGetLatestID();
					IF Internal.FB.ArEvGetLatestID.Error = FALSE THEN
						Internal.Ctrl.recordValid := TRUE;
						Internal.Ctrl.RecordID := Internal.FB.ArEvGetLatestID.RecordID;
					ELSE
						statusID := Internal.FB.ArEvGetLatestID.StatusID;
						Internal.Ctrl.step := ReadEvLog_ERROR;
					END_IF
				ELSE
					// start with a specific record id 
					Internal.Ctrl.recordValid := TRUE;
					Internal.Ctrl.RecordID := recordIdStart;
				END_IF
			ELSE
				statusID := Internal.FB.ArEvGetIdent.StatusID;
				Internal.Ctrl.step := ReadEvLog_ERROR;
			END_IF
		END_IF
		
		// we got a ident and the latest record id, now it's time to read ....			
		IF Internal.Ctrl.identValid = TRUE AND Internal.Ctrl.recordValid = TRUE THEN
			FOR Internal.Ctrl.loopIndex := 0 TO Internal.Ctrl.loopSize -1 DO
				
				// read event log entry basic information
				Internal.FB.ArEvLogRead(Execute := FALSE);
				Internal.FB.ArEvLogRead.Execute := TRUE;
				Internal.FB.ArEvLogRead.Ident := Internal.Ctrl.ident;
				Internal.FB.ArEvLogRead.RecordID := Internal.Ctrl.RecordID;
				Internal.FB.ArEvLogRead();

				IF Internal.FB.ArEvLogRead.Error = FALSE THEN
					
					// clear internal memory
					brsmemset(ADR(Internal.Ctrl.tmpEntry), 0, SIZEOF(Internal.Ctrl.tmpEntry));
					
					// access result memory
					refResultEntry ACCESS ADR(Internal.Ctrl.tmpEntry);

					refResultEntry.recordID := Internal.Ctrl.RecordID;
					refResultEntry.originID := Internal.FB.ArEvLogRead.OriginRecordID;
					refResultEntry.timestamp := Internal.FB.ArEvLogRead.TimeStamp;
					refResultEntry.utcDateTime := UDINT_TO_DT(Internal.FB.ArEvLogRead.TimeStamp.sec);
					refResultEntry.additionalDataFormat := Internal.FB.ArEvLogRead.AddDataFormat;
					refResultEntry.additionalDataSize := Internal.FB.ArEvLogRead.AddDataSize;
					
					// read base data
					IF Internal.FB.ArEvLogRead.StatusID = arEVENTLOG_WRN_NO_EVENTID THEN
						// this is the old format
						refResultEntry.isLegacyFormat := TRUE;
						Internal.FB.ArEvLogReadErrNr(Execute := FALSE);
						Internal.FB.ArEvLogReadErrNr.Execute := TRUE;
						Internal.FB.ArEvLogReadErrNr.Ident := Internal.Ctrl.ident;
						Internal.FB.ArEvLogReadErrNr.RecordID := Internal.Ctrl.RecordID;
						Internal.FB.ArEvLogReadErrNr();
						IF Internal.FB.ArEvLogReadErrNr.Error = FALSE THEN
							refResultEntry.eventID := UDINT_TO_DINT(Internal.FB.ArEvLogReadErrNr.ErrorNumber);
							refResultEntry.eventInfo.severity := Internal.FB.ArEvLogReadErrNr.Severity;
						ELSE
							statusID := Internal.FB.ArEvLogReadErrNr.StatusID;
							Internal.Ctrl.step := ReadEvLog_ERROR;
							EXIT;
						END_IF
					ELSE
						// this is the actual format!
						refResultEntry.isLegacyFormat := FALSE;
						refResultEntry.eventID := Internal.FB.ArEvLogRead.EventID;
						//decode event id
						refResultEntry.eventInfo.severity := UDINT_TO_USINT(SHR((DINT_TO_UDINT(refResultEntry.eventID) AND 16#C0000000), 30));
						refResultEntry.eventInfo.c_bit := UDINT_TO_USINT(SHR((DINT_TO_UDINT(refResultEntry.eventID) AND 16#20000000), 29));
						refResultEntry.eventInfo.r_bit := UDINT_TO_USINT(SHR((DINT_TO_UDINT(refResultEntry.eventID) AND 16#10000000), 28));
						refResultEntry.eventInfo.facility := UDINT_TO_UINT(SHR((DINT_TO_UDINT(refResultEntry.eventID) AND 16#0FFF0000), 16));
						refResultEntry.eventInfo.code := UDINT_TO_UINT(DINT_TO_UDINT(refResultEntry.eventID) AND 16#0000FFFF);
					END_IF
					
					// read object identifier
					Internal.FB.ArEvLogReadOID(Execute := FALSE);
					Internal.FB.ArEvLogReadOID.Execute := TRUE;
					Internal.FB.ArEvLogReadOID.Ident := Internal.Ctrl.ident;
					Internal.FB.ArEvLogReadOID.RecordID := Internal.Ctrl.RecordID;
					Internal.FB.ArEvLogReadOID();

					// read additional data
					IF Internal.FB.ArEvLogReadOID.Error = FALSE THEN
						refResultEntry.objectID := Internal.FB.ArEvLogReadOID.ObjectID;
						
						// read additional data
						Internal.FB.ArEvLogReadAddData(Execute := FALSE);
						Internal.FB.ArEvLogReadAddData.Execute := TRUE;
						Internal.FB.ArEvLogReadAddData.Ident := Internal.Ctrl.ident;
						Internal.FB.ArEvLogReadAddData.RecordID := Internal.Ctrl.RecordID;
						Internal.FB.ArEvLogReadAddData.AddData := ADR(refResultEntry.additionalData);
						IF SIZEOF(refResultEntry.additionalData) - 1 < refResultEntry.additionalDataSize THEN
							Internal.FB.ArEvLogReadAddData.BytesToRead := SIZEOF(refResultEntry.additionalData) - 1;
							refResultEntry.additionalDataComplete := FALSE;
						ELSE
							Internal.FB.ArEvLogReadAddData.BytesToRead := refResultEntry.additionalDataSize;
							refResultEntry.additionalDataComplete := TRUE;
						END_IF
						Internal.FB.ArEvLogReadAddData();
						
						IF Internal.FB.ArEvLogReadAddData.Error = FALSE THEN
							// get next entry
							// see below ....	
						ELSE
							statusID := Internal.FB.ArEvLogReadAddData.StatusID;
							Internal.Ctrl.step := ReadEvLog_ERROR;
							EXIT;
						END_IF
					ELSE
						statusID := Internal.FB.ArEvLogReadOID.StatusID;
						Internal.Ctrl.step := ReadEvLog_ERROR;
						EXIT;
					END_IF
					
					numberOfEntriesProcessed := numberOfEntriesProcessed + 1;
					// filter??!!
					Internal.Ctrl.filteredOk := 16#FF;	// each different filter set/reset one bit
					
					IF useReadFilter = FALSE THEN
						Internal.Ctrl.filteredOk.0 := TRUE;
					ELSE
						IF readFilterSetup.severity.useFilter = TRUE THEN
							IF refResultEntry.eventInfo.severity = ReadEvLog_SEVERITY_ERROR AND readFilterSetup.severity.error = TRUE OR
							refResultEntry.eventInfo.severity = ReadEvLog_SEVERITY_WARNING AND readFilterSetup.severity.warning = TRUE OR
							refResultEntry.eventInfo.severity = ReadEvLog_SEVERITY_INFORMATION AND readFilterSetup.severity.info = TRUE OR
							refResultEntry.eventInfo.severity = ReadEvLog_SEVERITY_SUCCESS AND readFilterSetup.severity.success = TRUE THEN
								// copy
								Internal.Ctrl.filteredOk.1 := TRUE;
							ELSE
								Internal.Ctrl.filteredOk.1 := FALSE;
							END_IF
						ELSE
							// copy all
							Internal.Ctrl.filteredOk.1 := TRUE;
						END_IF
						IF readFilterSetup.eventId.useFilter = TRUE THEN
							IF refResultEntry.eventID >= readFilterSetup.eventId.smallest AND refResultEntry.eventID <= readFilterSetup.eventId.largest THEN
								Internal.Ctrl.filteredOk.2 := TRUE;
							ELSE
								Internal.Ctrl.filteredOk.2 := FALSE;
							END_IF	
						ELSE
							// copy all
							Internal.Ctrl.filteredOk.2 := TRUE;
						END_IF
					END_IF
					
					// copy data depending on filter result
					IF Internal.Ctrl.filteredOk = 16#FF THEN
						// update counters
						CASE refResultEntry.eventInfo.severity OF
							ReadEvLog_SEVERITY_SUCCESS:
								severityCounters.success := severityCounters.success + 1;
							ReadEvLog_SEVERITY_INFORMATION:
								severityCounters.info := severityCounters.info + 1;
							ReadEvLog_SEVERITY_WARNING:
								severityCounters.warning := severityCounters.warning + 1;
							ReadEvLog_SEVERITY_ERROR:
								severityCounters.error := severityCounters.error + 1;
						END_CASE

						brsmemcpy(pResultData + (Internal.Ctrl.arrayIndex * SIZEOF(ReadEvLog_Entry_type)), ADR(Internal.Ctrl.tmpEntry), SIZEOF(Internal.Ctrl.tmpEntry));
						numberOfEntriesRead := numberOfEntriesRead + 1;			
						Internal.Ctrl.arrayIndex := Internal.Ctrl.arrayIndex + 1;
					END_IF
					
					// we've reached the end of the users result storage
					IF Internal.Ctrl.arrayIndex >= Internal.Ctrl.resultDataArraySize THEN
						EXIT;
					END_IF
					
				ELSE
					statusID := Internal.FB.ArEvLogRead.StatusID;
					Internal.Ctrl.step := ReadEvLog_ERROR;
					EXIT;
				END_IF


				// we should end up here only if loop wasn't exited before ... and then we can try to read the next entry
				
				// get next entry
				Internal.FB.ArEvGetPreviousID(Execute := FALSE);
				Internal.FB.ArEvGetPreviousID.Execute := TRUE;
				Internal.FB.ArEvGetPreviousID.Ident := Internal.Ctrl.ident;
				Internal.FB.ArEvGetPreviousID.RecordID := Internal.Ctrl.RecordID;
				Internal.FB.ArEvGetPreviousID();

				IF Internal.FB.ArEvGetPreviousID.Error = FALSE THEN
					more := TRUE;
					Internal.Ctrl.RecordID := Internal.FB.ArEvGetPreviousID.PrevRecordID;
				ELSE
					IF Internal.FB.ArEvGetPreviousID.StatusID = arEVENTLOG_ERR_RECORDID_INVALID THEN
						// object id invalid .... end of logger reached
						more := FALSE;
						Internal.Ctrl.step := ReadEvLog_FINISHED;
					ELSE
						// "real" error
						statusID := Internal.FB.ArEvGetPreviousID.StatusID;
						Internal.Ctrl.step := ReadEvLog_ERROR;
					END_IF
					EXIT;
				END_IF

			END_FOR
			IF more = TRUE THEN
				Internal.Ctrl.step := ReadEvLog_MOREWAIT;
			END_IF
		END_IF
					
	ELSIF Internal.Ctrl.step = ReadEvLog_ERROR THEN			
		done := TRUE;
		error := TRUE;
		busy := FALSE;			
		
	ELSIF Internal.Ctrl.step = ReadEvLog_FINISHED THEN
		done := TRUE;
		error := FALSE;
		busy := FALSE;

	ELSIF Internal.Ctrl.step = ReadEvLog_MOREWAIT THEN			
		done := TRUE;
		error := FALSE;
		busy := FALSE;

	ELSIF Internal.Ctrl.step = ReadEvLog_IDLE THEN
		// idle, that's it

	ELSE
		// this must not be happen!!! 
		Internal.Ctrl.step := ReadEvLog_UNKNOWNSTATE;
	END_IF				


END_FUNCTION_BLOCK
