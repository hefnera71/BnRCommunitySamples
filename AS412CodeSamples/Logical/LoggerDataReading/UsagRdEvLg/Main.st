
PROGRAM _INIT

	
END_PROGRAM

PROGRAM _CYCLIC

	IF bRead = TRUE THEN
		bRead := FALSE;
		uReadStep := 1;
	END_IF
	
	CASE uReadStep OF
		
		// sample: read the last 100 entries of type error and warning out of the system logger
		1:
			// define the logger module and the result memory
			ReadEvLogEntries_0.loggerName := '$$arlogsys';
			ReadEvLogEntries_0.pResultData := ADR(tResultData);
			ReadEvLogEntries_0.resultDataSize := SIZEOF(tResultData);
			ReadEvLogEntries_0.recordIdStart := 0;
			// define the severity filter with errors and warnings only
			ReadEvLogEntries_0.readFilterSetup.severity.warning := TRUE;
			ReadEvLogEntries_0.readFilterSetup.severity.error := TRUE;
			ReadEvLogEntries_0.readFilterSetup.severity.success := FALSE;
			ReadEvLogEntries_0.readFilterSetup.severity.info := FALSE;
			// activate severity filter
			ReadEvLogEntries_0.readFilterSetup.severity.useFilter := TRUE;
			// disable the event id filter
			ReadEvLogEntries_0.readFilterSetup.eventId.useFilter := FALSE;
			// define maximum filtered entries to read
			ReadEvLogEntries_0.readFilterSetup.maxNumberOfEntriesRead := 100;
			// activate the filters usage
			ReadEvLogEntries_0.useReadFilter := TRUE;
			
			// enable read! - !! PLEASE: THIS IS A SYNCHRONOUS CALL -> BE AWARE OF YOUR CYCLE TIME AND TOLERANCE TO USE !!
			ReadEvLogEntries_0.execute := TRUE;
			uReadStep := 2;
				
		2:
			IF ReadEvLogEntries_0.busy = FALSE THEN
				IF ReadEvLogEntries_0.error = TRUE THEN
					// error happened, don't proceed
					uReadStep := 99;
				ELSE
					// proceed with reading textual data
					// please note: let the .execute of ReadEvLogEntries at TRUE,  even if execution is finished, as long as you want to access the output informations of the fb
					uReadStep := 10;
				END_IF
			END_IF
		
		// after ReadEvLogEntries was processed, additionally read the description data (if wanted / needed)
		10:
			ReadEvLogEventDescription_0.loggerName := '$$arlogsys';
			ReadEvLogEventDescription_0.languageCode := 'de';
			// important - use the same memory as with the ReadEvLogEntries call
			ReadEvLogEventDescription_0.pResultData := ADR(tResultData);
			ReadEvLogEventDescription_0.resultDataSize := SIZEOF(tResultData);
			// you can configure up to 10 instances running in parallel to get a faster execution - but you will then also need more computing power!!
			ReadEvLogEventDescription_0.nrOfReadDescFBInsts := 2;

			// enable reading description - !! PLEASE NOTE: THIS IS A ASYNCHRONOUS CALL -> will need multiple / many cycles to finish !!
			ReadEvLogEventDescription_0.execute := TRUE;
			uReadStep := 11;
		
		11:
			IF ReadEvLogEventDescription_0.busy = FALSE THEN
				IF ReadEvLogEventDescription_0.error = TRUE THEN
					// error happened, don't proceed
					uReadStep := 99;
				ELSE
					// proceed with reading textual data
					uReadStep := 0;
					// reset both fb executes 
					ReadEvLogEntries_0.execute := FALSE;
					ReadEvLogEventDescription_0.execute := FALSE;
				END_IF
			END_IF
		
		
	END_CASE

	// call the fb
	ReadEvLogEntries_0();
	// call the fb
	ReadEvLogEventDescription_0();

	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

