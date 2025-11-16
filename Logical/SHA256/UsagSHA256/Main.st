
PROGRAM _INIT
	
	// test string to get the SHA256 hash out of it
	sTestData := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz?!-+*/#<>[](),.;:';
	
	// this test string should have the hash result 434ab2440d0f6ac4b94a7c433a13efe734ea030e8e649917ef10e52d6dd6db38
	// to crosscheck, e.g. use https://emn178.github.io/online-tools/sha256.html
	 
END_PROGRAM

PROGRAM _CYCLIC

	// test string to get the SHA256 hash out of it
	IF bTest = TRUE THEN
		// variable to store the hash, has to be STRING[64]
		sHash := '';
		// function call 
		dResult := GetSha256Hash(ADR(sTestData), brsstrlen(ADR(sTestData)), sHash);
		// done
		bTest := FALSE;
	END_IF
	
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

