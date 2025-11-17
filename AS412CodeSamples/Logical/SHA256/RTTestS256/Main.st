
PROGRAM _INIT

	// test data for runtime performance testing (data integrity is checked also)
	testData;
	FOR i := 0 TO SIZEOF(testData.data_64Byte.in) - 1 DO
		testData.data_64Byte.in[i] := UDINT_TO_USINT(i MOD 256);
	END_FOR
	FOR i := 0 TO SIZEOF(testData.data_4kB.in) - 1 DO
		testData.data_4kB.in[i] := UDINT_TO_USINT(i MOD 256);
	END_FOR
	FOR i := 0 TO SIZEOF(testData.data_1MB.in) - 1 DO
		testData.data_1MB.in[i] := UDINT_TO_USINT(i MOD 256);
	END_FOR

END_PROGRAM

PROGRAM _CYCLIC
	
	// testing runtime perfomance with 3 data sets: 64 byte, 4 kByte, 1MB
	CASE testRuntimeMeasurementStep OF

		1:
			LogStart_0(enable := TRUE);
				
			tsStart := AsIOTimeStamp();
			LogEvent_0(enable := TRUE, objIdent := 16#FFFFFE00, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
			GetSha256Hash(ADR(testData.data_64Byte.in), SIZEOF(testData.data_64Byte.in), testData.data_64Byte.hash);
			LogEvent_0(enable := TRUE, objIdent := 16#FFFFFE00, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
			testData.data_64Byte.tsDiff := ABS(AsIOTimeStamp() - tsStart);
			testRuntimeMeasurementStep := 2;
			
		2:
			tsStart := AsIOTimeStamp();
			LogEvent_0(enable := TRUE, objIdent := 16#FFFFFE01, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
			GetSha256Hash(ADR(testData.data_4kB.in), SIZEOF(testData.data_4kB.in), testData.data_4kB.hash);
			LogEvent_0(enable := TRUE, objIdent := 16#FFFFFE01, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
			testData.data_4kB.tsDiff := ABS(AsIOTimeStamp() - tsStart);
			testRuntimeMeasurementStep := 3;
		3:
			tsStart := AsIOTimeStamp();
			LogEvent_0(enable := TRUE, objIdent := 16#FFFFFE02, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
			GetSha256Hash(ADR(testData.data_1MB.in), SIZEOF(testData.data_1MB.in), testData.data_1MB.hash);
			LogEvent_0(enable := TRUE, objIdent := 16#FFFFFE02, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
			testData.data_1MB.tsDiff := ABS(AsIOTimeStamp() - tsStart);
			testRuntimeMeasurementStep := 4;

			LogStop_0(enable := TRUE);
		
		4:
			// test string
			sData := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz?!-+*/#<>[](),.;:';
			// test result 
			sResultWanted := '434ab2440d0f6ac4b94a7c433a13efe734ea030e8e649917ef10e52d6dd6db38';
			// result responded by function call
			sResult := '';
			bResult := FALSE;
			
			GetSha256Hash(ADR(sData), brsstrlen(ADR(sData)), sResult);
			
			IF brsmemcmp(ADR(sResult),ADR(sResultWanted),SIZEOF(sResult)) = 0 THEN
				bResult := TRUE;
			END_IF
			
		
	END_CASE
	
		
	
	
	 
END_PROGRAM

PROGRAM _EXIT
	
	
END_PROGRAM

