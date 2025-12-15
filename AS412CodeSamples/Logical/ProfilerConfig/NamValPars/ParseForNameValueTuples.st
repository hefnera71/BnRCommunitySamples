(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

FUNCTION_BLOCK ParseForNameValueTuples
	
	status := 16#FFFF;
	// clear result memory
	brsmemset(ADR(sOutput), 0, SIZEOF(sOutput));
	// reset addresses / index counters
	uArrayIndex := 0;
	uResultCharIndex := 0;
	bSkipComment := FALSE;
	uParseUnwantedChar := 0;
	uMaxResultLength := SIZEOF(sOutput[0].Name);
	// at the beginning, we always start with "Label"
	pResultMemory := ADR(sOutput[0].Name);
				
	FOR uCharIndex := 0 TO contentLength DO
		// access the next byte inside the input string
		dynInputChar ACCESS pContentToParse + uCharIndex;
		// decide where to copy the byte to
					
		// if '$n', switch the result array index and set result element to Label
		IF dynInputChar = 10 THEN	// 10 = ASCII '$n'
			// line end, reset skip if comment was before
			IF bSkipComment = TRUE AND uResultCharIndex = 0 THEN
				// this was a complete line of comment, so we do not need to switch to next array index
				// to keep the following code simple, substract array index here, it will be added below and so stays like it was ;-)
				uArrayIndex := uArrayIndex - 1;
			END_IF
			bSkipComment := FALSE;
			// switch to next array index
			uResultCharIndex := 0;
			uArrayIndex := uArrayIndex + 1;
			uMaxResultLength := SIZEOF(sOutput[0].Name);
			// "secure" the pointer - checking maximum array size declared
			IF uArrayIndex < SIZEOF(sOutput)/SIZEOF(sOutput[0]) THEN
				pResultMemory := ADR(sOutput[uArrayIndex].Name);
			ELSE
				// no more array memory, brake here !!!!
				status := namvalparsERROR_ELEMENTARRAY;
				EXIT;
			END_IF
						
		ELSIF dynInputChar = 13 OR dynInputChar = 9 OR dynInputChar = 32 THEN // 13 = ASCII '$r', 9 = '$t', 32 = ' ' ... we want to ignore those, and not have them added to the counter of unwanted characters
			// do nothing, just skip
	
		ELSIF dynInputChar = 35 THEN 	// 35 = ASCII '#'
			// comment: skip the rest of the line
			bSkipComment := TRUE;
		
			// if '=', switch the result element to Value
		ELSIF  bSkipComment = FALSE AND dynInputChar = 61 THEN	// 61 = ASCII '='
			// switch to "Value"
			uResultCharIndex := 0;
			pResultMemory := ADR(sOutput[uArrayIndex].Value);
			uMaxResultLength := SIZEOF(sOutput[0].Value);	
					
		ELSIF bSkipComment = FALSE AND ((dynInputChar >= 48 AND dynInputChar <= 57) OR (dynInputChar >= 65 AND dynInputChar <= 90) OR (dynInputChar >= 97 AND dynInputChar <= 122) OR dynInputChar = 95) THEN	
			// if 'no other special character', copy the char to the result memory
			// "secure" access - check result length limit
			IF uResultCharIndex < uMaxResultLength THEN
				// copy the character
				// shift pointer
				dynOutputChar ACCESS pResultMemory + uResultCharIndex;
				// copy the character
				dynOutputChar := dynInputChar;
				uResultCharIndex := uResultCharIndex + 1;
			ELSE
				// no more element memory, input is too long, brake here !!!!
				status := namvalparsERROR_ELEMENTSIZE;
				EXIT;
			END_IF
					
		ELSE
			// skip it, contains other chars then our "special chars" and 0..9 or A..Z or a..z or _
			// BE AWARE - this is not a full-featured parser - unwanted characters are skipped also "in the middle of something"
			// if not allowed characters are used, this could lead to unexpected parsing results
			IF bSkipComment = FALSE THEN
				uParseUnwantedChar := uParseUnwantedChar + 1;
			END_IF
		END_IF
	END_FOR
	
	IF status = 16#FFFF THEN
		status := 0;
	END_IF
	
END_FUNCTION_BLOCK
