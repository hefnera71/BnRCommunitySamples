(*
	Validates a client-supplied filename before it is appended to the target
	directory. The pointer must reference a null-terminated string. Empty or
	oversized names are rejected; permitted characters are letters, digits,
	period, underscore, and space.
*)
FUNCTION wbuuid_ValidateFileName
	i := 0;
	lenS := brsstrlen(pFileName);
	wbuuid_ValidateFileName := TRUE;
	
	IF lenS = 0 OR lenS > maxSizeFileName THEN
		wbuuid_ValidateFileName := FALSE;
	ELSE
		WHILE i < lenS DO
			pChar ACCESS pFileName + i;
			char := pChar;
			
			// Check for valid characters: a-z (97-122), A-Z (65-90), 0-9 (48-57), . (46), _ (95), "space" (32)
			IF (char >= 97 AND char <= 122) OR      // a-z
			   (char >= 65 AND char <= 90) OR       // A-Z
			   (char >= 48 AND char <= 57) OR       // 0-9
			   (char = 46) OR                       // .
				(char = 32) OR                       // "space"
				(char = 95) THEN                     // _
				// valid character
			ELSE
				wbuuid_ValidateFileName := FALSE;
				i := lenS; // break loop
			END_IF
			
			i := i + 1;
		END_WHILE
	END_IF
	
END_FUNCTION
