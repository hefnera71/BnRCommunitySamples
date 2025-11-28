FUNCTION_BLOCK ReadFile_INIT

	IF RTInit() = TRUE THEN

		// CONFIG FILE HANDLING - check if a config file exists, and read it
		status := 16#FFFF;
		// clear the result memory
		brsmemset(pBuffer, 0, bufferSize);
		REPEAT
			FileInfo_0(enable := TRUE, pDevice := ADR(sDevice), pName := ADR(sFile), pInfo := ADR(fInfo));
			UNTIL FileInfo_0.status <> 16#FFFF
		END_REPEAT
		
		IF FileInfo_0.status = 0 THEN
			// load infos from file, parse them and use them as setup
			REPEAT
				FileOpen_0(enable := TRUE, pDevice := ADR(sDevice), pFile := ADR(sFile), mode := fiREAD_ONLY);
				UNTIL FileOpen_0.status <> 16#FFFF
			END_REPEAT
			IF FileOpen_0.status = 0 THEN
				IF FileOpen_0.filelen < bufferSize THEN
					REPEAT
						FileRead_0(enable := TRUE, ident := FileOpen_0.ident, offset := 0, pDest := pBuffer, len := bufferSize);
						UNTIL FileRead_0.status <> 16#FFFF
					END_REPEAT
					IF FileRead_0.status = 0 THEN
						// parse file
						status := 0;
					ELSE
						// error in file reading
						status := FileRead_0.status;
					END_IF
				ELSE
					// not enough memory to read file
					status := freadinitERROR_NOT_ENOUGH_MEM;
				END_IF
				REPEAT
					FileClose_0(enable := TRUE, ident := FileOpen_0.ident);
					UNTIL FileClose_0.status <> 16#FFFF
				END_REPEAT
			ELSE
				// error in file open
				status := FileOpen_0.status;
			END_IF
		ELSE
			// error in file identification
			status := FileInfo_0.status;
		END_IF

	ELSE
		status := freadinitERROR_NOT_IN_INIT; // not running in INIT
	END_IF
	
END_FUNCTION_BLOCK