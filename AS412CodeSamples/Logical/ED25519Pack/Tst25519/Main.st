
PROGRAM _INIT
	(* Example key for the externally signed file flow. *)
	sPublicKeyFromExtFile := '2b6e0ccc471aae11bf851edfd54c2049248efc3faf993953ded0a587de6e7a97';
	(* Example key pair for the in-task signing flows. *)
	sPrivateInternal := '379f0a234b028d5cebe463511ce8c3f3efcf48e8728e0708309377ff21b18fb6';
	sPublicInternal := 'bacf592416461167353d4449cb88f5664d402473531897cce6cb99150b1aef08';
	(* Generate approximately 10 kB of example data. *)
	testStep := TEST_STEP_IDLE;
	brsmemset(ADR(data), 0, SIZEOF(data));
	FOR i := 0 TO 274 DO
		brsstrcat(ADR(data), ADR('Das ist das Haus vom Nikolaus '));
		brsitoa(UDINT_TO_DINT(i), ADR(tmp));
		brsstrcat(ADR(data), ADR(tmp));
		brsstrcat(ADR(data), ADR(' -> '));
	END_FOR

END_PROGRAM

PROGRAM _CYCLIC
	(* Operation: while online, set testStep to 10, 20, or 30 to start a flow.
	   Each flow advances automatically and returns testStep to TEST_STEP_IDLE.
	   10: sign and verify data in memory; expect dataOut to match data.
	   20: sign data, write/read USER/SignInContent.txt, then verify it;
	       expect contentLoaded to match data.
	   30: read USER/ExternSignedContent.txt and verify it with the external
	       public key; the file must already contain a matching signed content block.
	   After completion, inspect memoryVerificationSucceeded,
	   contentFileVerificationSucceeded, or externalVerificationSucceeded;
	   TRUE means the verifier status and validationResult were both zero.
	   TEST_STEP_ERROR indicates a key-conversion, signing, or file-I/O error;
	   inspect the relevant status outputs.
	*)

	(* Flow 1: sign and verify contiguous memory data. *)
	CASE testStep OF
		(* Decode the internal key pair and sign the source data. *)
		TEST_STEP_MEMORY_SIGN:
			memoryVerificationSucceeded := FALSE;
			brsmemset(ADR(buffer), 0, SIZEOF(buffer));
			keyStatus := EDHexToBytes(ADR(sPrivateInternal), 64, ADR(bPrivateKey), SIZEOF(bPrivateKey));
			IF keyStatus = 0 THEN
				keyStatus := EDHexToBytes(ADR(sPublicInternal), 64, ADR(bPublicKey), SIZEOF(bPublicKey));
			END_IF
			IF keyStatus = 0 THEN
				SignMemoryData_0(pData := ADR(data), dataLen := brsstrlen(ADR(data)), pBuffer := ADR(buffer), bufferSize := SIZEOF(buffer), public_key := bPublicKey, private_key := bPrivateKey);
				IF SignMemoryData_0.status = 0 THEN
					signedMessageLen := SignMemoryData_0.signedDataLen;
					testStep := TEST_STEP_MEMORY_VERIFY;
				ELSE
					testStep := TEST_STEP_ERROR;
				END_IF
			ELSE
				testStep := TEST_STEP_ERROR;
			END_IF

		(* Verify the signed buffer and copy the original data to dataOut. *)
		TEST_STEP_MEMORY_VERIFY:
			brsmemset(ADR(dataOut), 0, SIZEOF(dataOut));
			keyStatus := EDHexToBytes(ADR(sPublicInternal), 64, ADR(bPublicKey), SIZEOF(bPublicKey));
			IF keyStatus = 0 THEN
				VerifyMemoryData_0(pSignedMessage := ADR(buffer), signedMessageLen := signedMessageLen, pData := ADR(dataOut), dataSize := SIZEOF(dataOut), public_key := bPublicKey);
				memoryVerificationSucceeded := (VerifyMemoryData_0.status = 0) AND (VerifyMemoryData_0.validationResult = 0);
				testStep := TEST_STEP_IDLE;
			ELSE
				testStep := TEST_STEP_ERROR;
			END_IF
	END_CASE

	(* Flow 2: sign content, write it, read it back, and verify it. *)
	CASE testStep OF
		(* Sign source data in the marker-delimited content format. *)
		TEST_STEP_CONTENT_SIGN:
			contentFileVerificationSucceeded := FALSE;
			brsmemset(ADR(contentBuffer), 0, SIZEOF(contentBuffer));
			keyStatus := EDHexToBytes(ADR(sPrivateInternal), 64, ADR(bPrivateKey), SIZEOF(bPrivateKey));
			IF keyStatus = 0 THEN
				keyStatus := EDHexToBytes(ADR(sPublicInternal), 64, ADR(bPublicKey), SIZEOF(bPublicKey));
			END_IF
			IF keyStatus = 0 THEN
				SignToContent_0(pContent := ADR(data), contentLen := brsstrlen(ADR(data)), pBuffer := ADR(contentBuffer), bufferSize := SIZEOF(contentBuffer), public_key := bPublicKey, private_key := bPrivateKey);
				IF SignToContent_0.status = 0 THEN
					testStep := TEST_STEP_CONTENT_STORE;
				ELSE
					testStep := TEST_STEP_ERROR;
				END_IF
			ELSE
				testStep := TEST_STEP_ERROR;
			END_IF

		(* Write the signed content buffer to the USER device. *)
		TEST_STEP_CONTENT_STORE:
			EDFileIOHelper_0(Enable := TRUE, Command := ED_FH_CMD_WRITE_FILE, sFileDevice := 'USER', sFileName := 'SignInContent.txt', bytesToTransfer := SignToContent_0.signedDataLen, maxBufferSize := SIZEOF(contentBuffer), pBuffer := ADR(contentBuffer));
			IF EDFileIOHelper_0.bBusy = FALSE AND EDFileIOHelper_0.fileStep = ED_FH_STEP_IDLE THEN
				EDFileIOHelper_0(Enable := FALSE, Command := ED_FH_CMD_NONE);
				IF EDFileIOHelper_0.bError THEN
					testStep := TEST_STEP_ERROR;
				ELSE
					testStep := TEST_STEP_CONTENT_LOAD;
				END_IF
			END_IF

		(* Read the complete signed file into the external buffer. *)
		TEST_STEP_CONTENT_LOAD:
			EDFileIOHelper_0(Enable := TRUE, Command := ED_FH_CMD_READ_FILE, sFileDevice := 'USER', sFileName := 'SignInContent.txt', bytesToTransfer := 0, maxBufferSize := SIZEOF(contentBufferLoaded), pBuffer := ADR(contentBufferLoaded));
			IF EDFileIOHelper_0.bBusy = FALSE AND EDFileIOHelper_0.fileStep = ED_FH_STEP_IDLE THEN
				EDFileIOHelper_0(Enable := FALSE, Command := ED_FH_CMD_NONE);
				IF EDFileIOHelper_0.bError THEN
					testStep := TEST_STEP_ERROR;
				ELSE
					testStep := TEST_STEP_CONTENT_VERIFY;
				END_IF
			END_IF

		(* Verify the loaded content with the internal public key. *)
		TEST_STEP_CONTENT_VERIFY:
			brsmemset(ADR(contentLoaded), 0, SIZEOF(contentLoaded));
			keyStatus := EDHexToBytes(ADR(sPublicInternal), 64, ADR(bPublicKey), SIZEOF(bPublicKey));
			IF keyStatus = 0 THEN
				VerifyFromContent_0(pBuffer := ADR(contentBufferLoaded), bufferLen := EDFileIOHelper_0.bytesRead, pContent := ADR(contentLoaded), contentSize := SIZEOF(contentLoaded), public_key := bPublicKey);
				contentFileVerificationSucceeded := (VerifyFromContent_0.status = 0) AND (VerifyFromContent_0.validationResult = 0);
				testStep := TEST_STEP_IDLE;
			ELSE
				testStep := TEST_STEP_ERROR;
			END_IF
	END_CASE

	(* Flow 3: read a separately signed file and verify with its public key. *)
	CASE testStep OF
		(* Read the externally signed file from the USER device. *)
		TEST_STEP_EXTERNAL_LOAD:
		externalVerificationSucceeded := FALSE;
			EDFileIOHelper_0(Enable := TRUE, Command := ED_FH_CMD_READ_FILE, sFileDevice := 'USER', sFileName := 'ExternSignedContent.txt', bytesToTransfer := 0, maxBufferSize := SIZEOF(contentBufferLoaded), pBuffer := ADR(contentBufferLoaded));
			IF EDFileIOHelper_0.bBusy = FALSE AND EDFileIOHelper_0.fileStep = ED_FH_STEP_IDLE THEN
				EDFileIOHelper_0(Enable := FALSE, Command := ED_FH_CMD_NONE);
				IF EDFileIOHelper_0.bError THEN
					testStep := TEST_STEP_ERROR;
				ELSE
					testStep := TEST_STEP_EXTERNAL_VERIFY;
				END_IF
			END_IF

		(* Verify the loaded file with the separately provided public key. *)
		TEST_STEP_EXTERNAL_VERIFY:
			brsmemset(ADR(contentLoaded), 0, SIZEOF(contentLoaded));
			keyStatus := EDHexToBytes(ADR(sPublicKeyFromExtFile), 64, ADR(bPublicKeyFromExtFile), SIZEOF(bPublicKeyFromExtFile));
			IF keyStatus = 0 THEN
				VerifyFromContent_0(pBuffer := ADR(contentBufferLoaded), bufferLen := EDFileIOHelper_0.bytesRead, pContent := ADR(contentLoaded), contentSize := SIZEOF(contentLoaded), public_key := bPublicKeyFromExtFile);
				externalVerificationSucceeded := (VerifyFromContent_0.status = 0) AND (VerifyFromContent_0.validationResult = 0);
				testStep := TEST_STEP_IDLE;
			ELSE
				testStep := TEST_STEP_ERROR;
			END_IF
	END_CASE

END_PROGRAM

PROGRAM _EXIT
	(* No cleanup required. *)
END_PROGRAM

