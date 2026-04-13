
(* TODO: Add your comment here *)
FUNCTION_BLOCK FindStrPInHashTab
	
	status := 16#FFFF;
	IF ident > 0 THEN
		IF pString > 0 THEN
			dInternal ACCESS ident;

			pData := 0;
			pNextData := 0;
			userTag := 0;
			numberOfDatasets := 0;

			// get hash
			hashVal := InternalGenStrHash(pString, dInternal.hashModulo);
							
			IF hashVal >= 0 THEN
				pData := 0;
				dTableEntryToInspect ACCESS dInternal.pHashTable + hashVal * SIZEOF(HashTableBase_typ);
				dEntryToInspect ACCESS ADR(dTableEntryToInspect.Field);
				bExit := FALSE;
				REPEAT
					IF dEntryToInspect.pString > 0 THEN
						// check if element already exists, because the strings have to be unique
						// handling for "non-unique" string function has to be done in a different fc / fb, using pDataNext !!!
						IF brsstrcmp(pString, dEntryToInspect.pString) <> 0 THEN
							IF dEntryToInspect.pNext > 0 THEN
								// move to next list element
								dEntryToInspect ACCESS dEntryToInspect.pNext;
							ELSE
								// no more entries, not found
								status := hashERR_STRINGNOTFOUND;
								bExit := TRUE;
							END_IF
						ELSE
							// found! 
							status := 0;
							pData := dEntryToInspect.Data.pData;
							pNextData := dEntryToInspect.Data.pNextData;
							userTag := dEntryToInspect.Data.userTag;
							numberOfDatasets := dEntryToInspect.datasets;
							bExit := TRUE;
						END_IF
					ELSE
						// the string field in hash table is empty (becase of the hash index is not used?!)
						status := hashERR_STRINGNOTFOUND;
						bExit := TRUE;
					END_IF
					
					UNTIL bExit = TRUE
				END_REPEAT
			ELSE
				status := hashVal;
			END_IF
		ELSE
			status := hashERR_NULLPOINTER;
		END_IF
	ELSE
		status := hashERR_NULLIDENT;
	END_IF
	
	
END_FUNCTION_BLOCK
