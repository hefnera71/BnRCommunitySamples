
PROGRAM _INIT
	
	// code for generating TEST DATA
	myLoggerIdent := 0;
	ArEventLogGetIdent_0(Execute := TRUE, Name := 'myLogger');
	IF ArEventLogGetIdent_0.Error = TRUE THEN
		REPEAT
			ArEventLogCreate_0(Execute := TRUE, Name := 'myLogger', Size := 1000000, Persistence := arEVENTLOG_PERSISTENCE_PERSIST, Info := 0);
			UNTIL ArEventLogCreate_0.Done = TRUE OR ArEventLogCreate_0.Error = TRUE
		END_REPEAT
		IF ArEventLogCreate_0.Error = FALSE THEN
			myLoggerIdent := ArEventLogCreate_0.Ident;
		END_IF
		ArEventLogCreate_0(Execute := FALSE);
	ELSE
		myLoggerIdent := ArEventLogGetIdent_0.Ident;
	END_IF
	ArEventLogGetIdent_0(Execute := FALSE);
	
	
END_PROGRAM

PROGRAM _CYCLIC

	
	// ---- TEST DATA ----
	
	
	// generate 1000 logging entries, some of them with origin, others dont
	IF bGenerateLoggerEntries = TRUE AND myLoggerIdent > 0 THEN
	
		originID := 0;
		FOR jj := 0 TO MAX_INDEX_RESULT DO
			
			sJJ := UINT_TO_STRING(jj);
			eventID := ArEventLogMakeEventID(UINT_TO_USINT(jj MOD 4), jj MOD 16, jj);
			sObjectID := 'TestDataGenerator';
			sAddText := 'this is my custom text - loop run ';
			brsstrcat(ADR(sAddText), ADR(sJJ));
			
			CASE jj MOD 10 OF
				0..1:
					originID := 0;
				2..5:
					tempOriginID := originID;
				6..8:
					originID := tempOriginID;
				9:
				originID := jj MOD 100;	// force some origin ids that not exists in my exported data
			END_CASE
			ArEventLogWrite_0(Execute := TRUE, Ident := myLoggerIdent, EventID := eventID, OriginRecordID := originID, ObjectID := sObjectID, AddDataSize := brsstrlen(ADR(sAddText)), AddDataFormat := arEVENTLOG_ADDFORMAT_TEXT, AddData := ADR(sAddText));
			originID := ArEventLogWrite_0.RecordID;						
			IF ArEventLogWrite_0.Error = TRUE THEN
				// we don't need the super-good error handling if generating test data
				EXIT;
			END_IF
			ArEventLogWrite_0(Execute := FALSE);
		END_FOR

		bGenerateLoggerEntries := FALSE;	
	END_IF
	
	
END_PROGRAM

PROGRAM _EXIT

END_PROGRAM

