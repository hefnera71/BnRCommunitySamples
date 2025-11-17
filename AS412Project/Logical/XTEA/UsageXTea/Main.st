
PROGRAM _INIT

	// PLEASE NOTE: block cipher algorithms need a fixed block size.
	// --> the algorithm used has a block size 8 - that means:
	// input data should be of length MOD 8 = 0 - if you data isn't, fill bytes are automatically added to reach MOD 8 = 0
	// output data must be of length MOD 8 = 0 - fillbytes are part of the output data also

	// small test data buffer in readable format for simple check of functions
	brsmemset(ADR(rawIn), 0, SIZEOF(rawIn));
	sInputData := 'Das ist das Haus vom Nikolaus';
	brsmemcpy(ADR(rawIn), ADR(sInputData), brsstrlen(ADR(sInputData)));
	// some more buffers 
	rawIn;
	rawOut;
	rawOut2;
	rawOut3;
	hexOut;
	

	// respect to security: it is NOT RECOMMENDED to STORE THE KEY / A SECRET IN A VARIABLE / CONSTANT
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
			// if you want to have some radnom strin, you can use e.g. https://www.random.org/strings/
			brsmemcpy(pMem, ADR('zouEu3fYs3uor6Uj'), xteaKEY_LENGTH);
		END_IF
	END_IF
	
END_PROGRAM

PROGRAM _CYCLIC

	CASE testStep OF
		
		// step 1 and 2 -- TESTING encrypt, decrypt without further encoding
		1:
			//  xteaencdec(mode, pIn, lenIn, pOut, lenOut, pKey, lenKey); // returns 0 if ok, != 0 if error
			// pIn --> address of the variable holding the data to encrypt
			// pOut --> after function call, contains the encrypted data
			// mode xteaMODE_ENCRYPT --> lenOut has to be greater then lenIn an % 8 = 0 because of block cipher !!
			IF pMem > 0 THEN
				state := xteaencdec(xteaMODE_ENCRYPT, ADR(rawIn), SIZEOF(rawIn), ADR(rawOut), SIZEOF(rawOut), pMem, xteaKEY_LENGTH);
				testStep := 2;
			END_IF
			
		2:
			//  xteaencdec(mode, pIn, lenIn, pOut, lenOut, pKey, lenKey); // returns 0 if ok, != 0 if error
			// pIn --> address of the variable holding the encrypted data to decrypt
			// pOut --> after function call, contains the decrypted data
			// mode xteaMODE_DECRYPT --> lenIn has to be % 8 = 0, lenOut has to bee at least as big as lenIn
			IF pMem > 0 THEN
				state := xteaencdec(xteaMODE_DECRYPT, ADR(rawOut), SIZEOF(rawOut), ADR(rawOut2), SIZEOF(rawOut2), pMem, xteaKEY_LENGTH);
				testStep := 0;
			END_IF
			

			// step 10 and 11 -- alternative to step 1 + 2 -- TESTING encrypt, decrypt with further en-/de-coding data to ascii-coded hex values
		10:
			//  xteaencdec(mode, pIn, lenIn, pOut, lenOut, pKey, lenKey); // returns 0 if ok, != 0 if error
			// encrypt hex
			// pIn --> address of the variable holding the data to encrypt
			// pOut --> after function call, contains the ascii-hex encoded, encrypted data
			// mode xteaMODE_ENCRYPT_TO_HEX --> lenOut has to double greater then lenIn an % 8 = 0 because of block cipher !!
			IF pMem > 0 THEN
				state := xteaencdec(xteaMODE_ENCRYPT_TO_HEX, ADR(rawIn), SIZEOF(rawIn), ADR(hexOut), SIZEOF(hexOut), pMem, xteaKEY_LENGTH);
				testStep := 11;
			END_IF
			
		11:
			//  xteaencdec(mode, pIn, lenIn, pOut, lenOut, pKey, lenKey); // returns 0 if ok, != 0 if error
			// pIn --> address of the variable holding the ascii-hex encoded, encrypted data to decrypt
			// pOut --> after function call, contains the decrypted data
			// mode xteaMODE_DECRYPT_FROM_HEX --> lenIn has to be % 8 = 0, lenOut has to bee at least half as big as lenIn
			IF pMem > 0 THEN
				state := xteaencdec(xteaMODE_DECRYPT_FROM_HEX, ADR(hexOut), SIZEOF(hexOut), ADR(rawOut3), SIZEOF(rawOut3), pMem, xteaKEY_LENGTH);
				testStep := 0;
			END_IF
	
	END_CASE
	 
END_PROGRAM

PROGRAM _EXIT
	
	// delete memory partition
	AsMemPartDestroy_0(enable := TRUE, ident := AsMemPartCreate_0.ident);
	
	
END_PROGRAM

