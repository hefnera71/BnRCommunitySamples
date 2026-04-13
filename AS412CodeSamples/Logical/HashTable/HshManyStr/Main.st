
PROGRAM _INIT
	
	(* TEST DATA GENERATION = GENERATE A HUGH NUMBER OF UNIQUE STRINGS FOR USE AS HASH KEY *)
	(* String generator - generates about 67600 strings <A..Z><0..9><a..z><0..9> *)
	FOR i := 65 TO 90 DO	// A .. Z
		FOR j := 48 TO 57 DO	// 0 .. 9
			FOR k := 97 TO 122 DO	// a .. z
				FOR l := 48 TO 57 DO	// 0..9
					mychar[0] := i;
					mychar[1] := j;
					mychar[2] := k;
					mychar[3] := l;
					mychar[4] := 0;
					IF c < SIZEOF(sString)/SIZEOF(sString[0]) - 1 THEN
						// build the string
						brsstrcpy(ADR(sString[c]), ADR(mychar));
					END_IF
					c := c + 1;
				END_FOR
			END_FOR
		END_FOR
	END_FOR
	dDummyDataString ACCESS ADR('not yet used');
	
	(* INTERNAL TESTING ONLY - DO NOT START TEST ROUTINE AUTOMATICALLY *)
	// avoid auto-start of measure test and set-up test
	measureFullTest := MAX_UDINT;
	diffLoopMin := 1000;
	diffFindMin := 1000;
	
	(* INITIALIZE HASH *)
	(* initialize the hash table - here I use a table with 1024 elements *)
	INIT_StrHashTab_0(nrOfHashTableElements := 2048, collisionMemSize := 2048 * 2048); // at least collision mem size needed is around 67600 * 24 = 1.63 MB, but we should have some more than the minimum
	
	IF INIT_StrHashTab_0.status = 0 THEN
		(* SECOND SET OF DUMMY DATA GENERATION -- GENERATION OF DATA SEGMENTS FOR ALL OF THE HASH KEYS *)
		FOR ii := 0 TO SIZEOF(sString) / SIZEOF(sString[0]) - 1 DO
			(* generate some dummy data *)
			brsitoa(UDINT_TO_DINT(ii), ADR(sDummyData[ii]));
			brsstrcat(ADR(sDummyData[ii]),ADR(' --> '));
			brsstrcat(ADR(sDummyData[ii]),ADR(sString[ii]));
			// insert EVERY KEY + DATA SEGMENT to hash 
			statusInsert := InsertStrPToHashTab(INIT_StrHashTab_0.ident, ADR(sString[ii]), ADR(sDummyData[ii]), 1, FALSE);
			IF statusInsert <> 0 THEN
				// error happened, break here!
				bError := TRUE;
				EXIT;
			END_IF
		END_FOR
		// read out usage information
		GetHashTableInfo(INIT_StrHashTab_0.ident, ADR(tHashTableInfo));
	END_IF
	
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)

	IF INIT_StrHashTab_0.status = 0 THEN
	
		// FOLLOWING IS TEST CODE
		// If the local variable bError = TRUE (see INIT) .... means that we were not able to hash all string, normally because of the collision memory size is too small !!
		
		// manual test ==> find one specific string = hash key inside hash - string is set in Watch, in variable "sSearchstring"
		IF bSearch THEN
			bSearch := FALSE;
			
			// find "sSearchstring" in hash
			MeasureRT_0(Start := TRUE); // measurement only to get a impression of code runtime
			FindStrPInHashTab_0(ident := INIT_StrHashTab_0.ident, pString := ADR(sSearchstring));
			MeasureRT_0(Start := FALSE);  // measurement only to get a impression of code runtime
			IF FindStrPInHashTab_0.status = 0 THEN
				// e.g. "check datatype stored in userTag"
				IF FindStrPInHashTab_0.userTag = 1 THEN	// i set that to 1, 1 means "string" for me
					// now read data
					dDummyDataString ACCESS FindStrPInHashTab_0.pData;
				END_IF
			END_IF
			
			
			// compare to linear search -- find "sSearchstring" by looping through data
			MeasureRT_1(Start := TRUE); // measurement only to get a impression of code runtime
			FOR mm := 0 TO SIZEOF(sString)/SIZEOF(sString[0]) - 1 DO
				IF brsstrcmp(ADR(sString[mm]),ADR(sSearchstring)) = 0 THEN
					// found;
					EXIT;
				END_IF
			END_FOR
			MeasureRT_1(Start := FALSE); // measurement only to get a impression of code runtime
			
		END_IF
	END_IF

	
	// "automatic" test ==> find key by key (all keys from dummy data generated in init), measure runtime and store min / max value ever reached within the automatic test run
	// this routine runs very long, as just one call per cycle is executed
	CASE measureFullTest OF
	
		MAX_UDINT:
			// do nothing
			
		0..MAX_IDX_TESTDATA:

			// search key in hash
			MeasureRT_0(Start := TRUE); // measurement only to get a impression of code runtime
			FindStrPInHashTab_0(ident := INIT_StrHashTab_0.ident, pString := ADR(sString[measureFullTest]));
			MeasureRT_0(Start := FALSE);  // measurement only to get a impression of code runtime
			IF FindStrPInHashTab_0.status <> 0 THEN
				cntErrorFind := cntErrorFind + 1;
			END_IF
			IF MeasureRT_0.DifferenceUs < diffFindMin THEN
				diffFindMin := MeasureRT_0.DifferenceUs;
			END_IF
			IF MeasureRT_0.DifferenceUs > diffFindMax THEN
				diffFindMax := MeasureRT_0.DifferenceUs;
			END_IF
				
			// compare to linear search -- search key by loop
			MeasureRT_1(Start := TRUE); // measurement only to get a impression of code runtime
			FOR mmm := 0 TO SIZEOF(sString)/SIZEOF(sString[0]) - 1 DO
				IF brsstrcmp(ADR(sString[mmm]),ADR(sString[measureFullTest])) = 0 THEN
					// found;
					EXIT;
				END_IF
			END_FOR
			MeasureRT_1(Start := FALSE); // measurement only to get a impression of code runtime
			IF MeasureRT_1.DifferenceUs < diffLoopMin THEN
				diffLoopMin := MeasureRT_1.DifferenceUs;
			END_IF
			IF MeasureRT_1.DifferenceUs > diffLoopMax THEN
				diffLoopMax := MeasureRT_1.DifferenceUs;
			END_IF
		
			measureFullTest := measureFullTest + 1;

	
	END_CASE
	
	
	// manual test ==> add a new key, add multiple datasets to this key, after that remove key --> if everything is ok, then the memory usage must be same like before the test start
	// ... means: the memory usage stored in "tHashTableInfoBeforeInsert" must be the same then in "tHashTableInfoAfterDelete", in "tHashTableInfoAfterInsert" ist must be different
	IF bTestRemove THEN
		bTestRemove := FALSE;

		GetHashTableInfo(INIT_StrHashTab_0.ident, ADR(tHashTableInfoBeforeInsert));
		
		// insert new key with multiple data segments
		statusInsert := InsertStrPToHashTab(INIT_StrHashTab_0.ident, ADR('TestMultipleDatasets'), ADR('DummyData1'), -1, TRUE);
		statusInsert := InsertStrPToHashTab(INIT_StrHashTab_0.ident, ADR('TestMultipleDatasets'), ADR('DummyData2'), -2, TRUE);
		statusInsert := InsertStrPToHashTab(INIT_StrHashTab_0.ident, ADR('TestMultipleDatasets'), ADR('DummyData3'), -3, TRUE);
		statusInsert := InsertStrPToHashTab(INIT_StrHashTab_0.ident, ADR('TestMultipleDatasets'), ADR('DummyData4'), -4, TRUE);
		statusInsert := InsertStrPToHashTab(INIT_StrHashTab_0.ident, ADR('TestMultipleDatasets'), ADR('DummyData5'), -5, TRUE);

		GetHashTableInfo(INIT_StrHashTab_0.ident, ADR(tHashTableInfoAfterInsert));
		
		// remove the new key
		RemoveStrPFromHashTab_0(ident := INIT_StrHashTab_0.ident, pString := ADR('TestMultipleDatasets'));
		
		GetHashTableInfo(INIT_StrHashTab_0.ident, ADR(tHashTableInfoAfterDelete));

		// check if key was removed - must not be found here, FB has to return a error
		FindStrPInHashTab_0(ident := INIT_StrHashTab_0.ident, pString := ADR('TestMultipleDatasets'));

		
	END_IF
	
	
END_PROGRAM

PROGRAM _EXIT
	
	(* free the memory allocated by INIT_xxx fb *)
	EXIT_StrHashTab(INIT_StrHashTab_0.ident);
	
END_PROGRAM

