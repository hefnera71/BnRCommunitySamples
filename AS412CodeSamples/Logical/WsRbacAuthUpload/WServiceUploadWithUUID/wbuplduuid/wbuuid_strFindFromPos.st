(* Finds position of string2 in string1. *)
FUNCTION wbuuid_strFindFromPos
	i_max := brsstrlen(string1);
	j_max := brsstrlen(string2);
	found := FALSE;
	
	wbuuid_strFindFromPos := 0; // means "not found"
	
	IF j_max > i_max THEN
		RETURN;
	END_IF	
	
	FOR i := pos TO (i_max - 1) DO
		pChar_string1 ACCESS (string1 + i);
		pChar_string2 ACCESS (string2 + j);
		
		// compare first character only
		IF pChar_string1 = pChar_string2 THEN
			found := TRUE;
			
			// if found, compare the rest
			FOR j := 0 TO (j_max - 1) DO
				pChar_string1 ACCESS (string1 + i + j);
				pChar_string2 ACCESS (string2 + j);
				
				// if not equal, go on
				IF pChar_string1 <> pChar_string2 THEN
					found := FALSE;
					// it could be faster, by setting i to i + j, but then we will not be able to find "test1" in "testest1"
					j := 0;
					EXIT;
				END_IF		
			END_FOR
		END_IF

		IF found THEN
			wbuuid_strFindFromPos := UDINT_TO_UINT(i + 1);
			EXIT;
		END_IF	
	END_FOR			
END_FUNCTION