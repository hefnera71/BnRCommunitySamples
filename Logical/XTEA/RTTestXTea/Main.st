
PROGRAM _INIT

	// test data for runtime performance testing (data integrity is checked also)
	testData;
	FOR i := 0 TO SIZEOF(testData[0].data_64Byte.in) - 1 DO
		testData[0].data_64Byte.in[i] := UDINT_TO_USINT(i MOD 256);
	END_FOR
	FOR i := 0 TO SIZEOF(testData[0].data_4kB.in) - 1 DO
		testData[0].data_4kB.in[i] := UDINT_TO_USINT(i MOD 256);
	END_FOR
	FOR i := 0 TO SIZEOF(testData[0].data_1MB.in) - 1 DO
		testData[0].data_1MB.in[i] := UDINT_TO_USINT(i MOD 256);
	END_FOR

	

	// respect cyber security: it is NOT RECOMMENDED to STORE THE KEY / A SECRET IN A VARIABLE / CONSTANT
	// --> IEC variables / constants are readable via online servioes, so better hide such data
	// here, I'm using allocated memory as an example -> the're other methods available to hide data, but data hiding is not part of this sample
	pMem := 0;
	AsMemPartCreate_0(enable := TRUE, len := xteaKEY_LENGTH);
	IF AsMemPartCreate_0.status = 0 THEN
		AsMemPartAlloc_0(enable := TRUE, ident := AsMemPartCreate_0.ident, len := xteaKEY_LENGTH);
		IF AsMemPartAlloc_0.status = 0 THEN
			pMem := AsMemPartAlloc_0.mem;
			// !!! --> choose YOUR OWN KEY WITH 16 BYTE LEN, and KEEP IT SECRET <-- !!!
			// KEY HAS ALWAYS TO HAVE SIZE: 16 BYTE
			brsmemcpy(pMem, ADR('qdEyCbCb36d3hut7'), xteaKEY_LENGTH);
		END_IF
	END_IF
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// testing runtime perfomance with 3 data sets: 64 byte, 4 kByte, 1MB
	CASE testRuntimeMeasurementStep OF

		// --- part 1: encrypt
		1:
			IF pMem > 0 THEN
				LogStart_0(enable := TRUE);
				
				tsStart := AsIOTimeStamp();
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF00, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
				state := xteaencdec(xteaMODE_ENCRYPT, ADR(testData[0].data_64Byte.in), SIZEOF(testData[0].data_64Byte.in), ADR(testData[0].data_64Byte.out), SIZEOF(testData[0].data_64Byte.out), pMem, xteaKEY_LENGTH);
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF00, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
				testData[0].data_64Byte.tsDiff := ABS(AsIOTimeStamp() - tsStart);
				testRuntimeMeasurementStep := 2;
			END_IF
			
		2:
			IF pMem > 0 THEN
				tsStart := AsIOTimeStamp();
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF01, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
				state := xteaencdec(xteaMODE_ENCRYPT, ADR(testData[0].data_4kB.in), SIZEOF(testData[0].data_4kB.in), ADR(testData[0].data_4kB.out), SIZEOF(testData[0].data_4kB.out), pMem, xteaKEY_LENGTH);
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF01, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
				testData[0].data_4kB.tsDiff := ABS(AsIOTimeStamp() - tsStart);
				testRuntimeMeasurementStep := 3;
			END_IF
		3:
			IF pMem > 0 THEN
				tsStart := AsIOTimeStamp();
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF02, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
				state := xteaencdec(xteaMODE_ENCRYPT, ADR(testData[0].data_1MB.in), SIZEOF(testData[0].data_1MB.in), ADR(testData[0].data_1MB.out), SIZEOF(testData[0].data_1MB.out), pMem, xteaKEY_LENGTH);
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF02, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
				testData[0].data_1MB.tsDiff := ABS(AsIOTimeStamp() - tsStart);
				testRuntimeMeasurementStep := 11;
			END_IF
		

			// --- part 2: decrypt using the out-data from encrypt
		11:
			IF pMem > 0 THEN
				tsStart := AsIOTimeStamp();
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF03, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
				state := xteaencdec(xteaMODE_DECRYPT, ADR(testData[0].data_64Byte.out), SIZEOF(testData[0].data_64Byte.out), ADR(testData[1].data_64Byte.out), SIZEOF(testData[1].data_64Byte.out), pMem, xteaKEY_LENGTH);
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF03, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
				testData[1].data_64Byte.tsDiff := ABS(AsIOTimeStamp() - tsStart);
				testRuntimeMeasurementStep := 12;
			END_IF
			
		12:
			IF pMem > 0 THEN
				tsStart := AsIOTimeStamp();
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF04, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
				state := xteaencdec(xteaMODE_DECRYPT, ADR(testData[0].data_4kB.out), SIZEOF(testData[0].data_4kB.out), ADR(testData[1].data_4kB.out), SIZEOF(testData[1].data_4kB.out), pMem, xteaKEY_LENGTH);
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF04, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
				testData[1].data_4kB.tsDiff := ABS(AsIOTimeStamp() - tsStart);
				testRuntimeMeasurementStep := 13;
			END_IF
		13:
			IF pMem > 0 THEN
				tsStart := AsIOTimeStamp();
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF05, userEvent := profUSER_EVENT_START, pAddData := 0, addDataLen := 0);
				state := xteaencdec(xteaMODE_DECRYPT, ADR(testData[0].data_1MB.out), SIZEOF(testData[0].data_1MB.out), ADR(testData[1].data_1MB.out), SIZEOF(testData[1].data_1MB.out), pMem, xteaKEY_LENGTH);
				LogEvent_0(enable := TRUE, objIdent := 16#FFFFFF05, userEvent := profUSER_EVENT_STOP, pAddData := 0, addDataLen := 0);
				testData[1].data_1MB.tsDiff := ABS(AsIOTimeStamp() - tsStart);
				testRuntimeMeasurementStep := 90;
			END_IF

			// --- part 3: check data consistency 
		90:
			bEqual := FALSE;
			IF brsmemcmp(ADR(testData[0].data_64Byte.in), ADR(testData[1].data_64Byte.out), SIZEOF(testData[1].data_64Byte.out)) = 0 THEN
				IF brsmemcmp(ADR(testData[0].data_4kB.in), ADR(testData[1].data_4kB.out), SIZEOF(testData[1].data_4kB.out)) = 0 THEN
					IF brsmemcmp(ADR(testData[0].data_1MB.in), ADR(testData[1].data_1MB.out), SIZEOF(testData[1].data_1MB.out)) = 0 THEN
						IF brsmemcmp(ADR(testData[0].data_64Byte.in), ADR(testData[0].data_64Byte.out), SIZEOF(testData[0].data_64Byte.out)) <> 0 THEN
							IF brsmemcmp(ADR(testData[0].data_4kB.in), ADR(testData[0].data_4kB.out), SIZEOF(testData[0].data_4kB.out)) <> 0 THEN
								IF brsmemcmp(ADR(testData[0].data_1MB.in), ADR(testData[0].data_1MB.out), SIZEOF(testData[0].data_1MB.out)) <> 0 THEN
									bEqual := TRUE;
								END_IF
							END_IF
						END_IF
					END_IF
				END_IF
			END_IF
			testRuntimeMeasurementStep := 0;
			
			
			LogStop_0(enable := TRUE);
					
		
	END_CASE
	
		
	
	
	 
END_PROGRAM

PROGRAM _EXIT
	
	// delete memory partition
	AsMemPartDestroy_0(enable := TRUE, ident := AsMemPartCreate_0.ident);
	
	
END_PROGRAM

