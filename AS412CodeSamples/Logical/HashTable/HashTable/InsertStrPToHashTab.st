
(* TODO: Add your comment here *)
FUNCTION InsertStrPToHashTab
	
	IF ident > 0 THEN
		dInternal ACCESS ident;
		IF pString > 0 AND pData > 0 THEN
		// get hash
		hashVal := InternalGenStrHash(pString, dInternal.hashModulo);
						
			IF hashVal >= 0 THEN
				dTableEntryToInspect ACCESS (dInternal.pHashTable + (hashVal * SIZEOF(HashTableBase_typ)));
				dEntryToInspect ACCESS ADR(dTableEntryToInspect.Field);
				dCollision ACCESS ADR(dTableEntryToInspect.collisions);
				bExit := FALSE;
				// store pointers to hash table
				REPEAT
					IF dEntryToInspect.pString = 0 THEN
						// empty one found in base table - done
						dEntryToInspect.pString := pString;
						dEntryToInspect.Data.pData := pData;
						dEntryToInspect.Data.userTag := userTag;
						dEntryToInspect.Data.pNextData := 0;
						dEntryToInspect.pNext := 0;
						dEntryToInspect.datasets := dEntryToInspect.datasets + 1;
						bExit := TRUE;
					ELSE
						// check if element already exists, because the strings have to be unique
						// TODO - add handling for "non-unique" strings !!!
						IF brsstrcmp(pString, dEntryToInspect.pString) <> 0 THEN
							IF dEntryToInspect.pNext = 0 THEN
								// add element
								// allocate 
								AsMemPartAlloc_0(enable := TRUE, ident := dInternal.identMemPartCreate, len := SIZEOF(dEntryToInspect));
								// add
								IF AsMemPartAlloc_0.status = 0 THEN
									// store pointer to parent
									dEntryToInspect.pNext := AsMemPartAlloc_0.mem;
									// access new list element
									dEntryToInspect ACCESS AsMemPartAlloc_0.mem;
									dEntryToInspect.pString := pString;
									dEntryToInspect.Data.pData := pData;
									dEntryToInspect.Data.userTag := userTag;
									dEntryToInspect.Data.pNextData := 0;
									dEntryToInspect.pNext := 0;
									// increment base table collision counter
									dCollision := dCollision + 1;
									//
									dEntryToInspect.datasets := dEntryToInspect.datasets + 1;
									bExit := TRUE;
									InsertStrPToHashTab := 0;
								ELSE
									// not really added but we have to break the loop
									bExit := TRUE;
									InsertStrPToHashTab := AsMemPartAlloc_0.status;
								END_IF
							ELSE
								// move to next list element
								dEntryToInspect ACCESS dEntryToInspect.pNext;
							END_IF
						ELSE
							IF multipleDataAllowed = TRUE THEN
								// more then one dataset associated with one string is allowed ....
								dDataFieldToInspect ACCESS ADR(dEntryToInspect.Data);
								REPEAT
									IF dDataFieldToInspect.pNextData = 0 THEN
										// allocate
										AsMemPartAlloc_0(enable := TRUE, ident := dInternal.identMemPartCreate, len := SIZEOF(dDataFieldToInspect));
										IF AsMemPartAlloc_0.status = 0 THEN
											dDataFieldToInspect.pNextData := AsMemPartAlloc_0.mem;
											dDataFieldToInspect ACCESS AsMemPartAlloc_0.mem;
											dDataFieldToInspect.pData := pData;
											dDataFieldToInspect.userTag := userTag;
											dDataFieldToInspect.pNextData := 0;
											dEntryToInspect.datasets := dEntryToInspect.datasets + 1;
											InsertStrPToHashTab := 0;
										ELSE
											// error allocation mem
											InsertStrPToHashTab := AsMemPartAlloc_0.status;
										END_IF
										// END
										bDataExit := TRUE;
										bExit := TRUE;
									ELSE
										// move on to next data element
										dDataFieldToInspect ACCESS dDataFieldToInspect.pNextData;
									END_IF
									
									UNTIL bDataExit = TRUE
								END_REPEAT
							ELSE
								// error! same string already exists
								bExit := TRUE;
								InsertStrPToHashTab := hashERR_STRINGEXISTS;
							END_IF
						END_IF
					END_IF
					UNTIL bExit = TRUE
				END_REPEAT
			ELSE
				InsertStrPToHashTab := hashVal; // error from getting hash
			END_IF
		ELSE
			InsertStrPToHashTab := hashERR_NULLPOINTER;
		END_IF
	ELSE
		InsertStrPToHashTab := hashERR_NULLIDENT;
	END_IF		
		
	
END_FUNCTION
