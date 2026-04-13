
(* TODO: Add your comment here *)
FUNCTION_BLOCK RemoveStrPFromHashTab
	
	status := 16#FFFF;
	IF ident > 0 THEN
		IF pString > 0 THEN
			dInternal ACCESS ident;

			pData := 0;
			pNextData := 0;

			// get hash
			hashVal := InternalGenStrHash(pString, dInternal.hashModulo);
							
			IF hashVal >= 0 THEN
				pData := 0;
				dTableEntryToInspect ACCESS dInternal.pHashTable + hashVal * SIZEOF(HashTableBase_typ);
				dEntryToInspect ACCESS ADR(dTableEntryToInspect.Field);
				pParentEntry := 0;
				bExit := FALSE;
				status := 0;
				REPEAT
					IF dEntryToInspect.pString > 0 THEN
						// check if element already exists, because the strings have to be unique
						// handling for "non-unique" string function has to be done in a different fc / fb, using pDataNext !!!
						IF brsstrcmp(pString, dEntryToInspect.pString) <> 0 THEN
							IF dEntryToInspect.pNext > 0 THEN
								// remember parent
								pParentEntry := ADR(dEntryToInspect);
								// move to next list element
								dEntryToInspect ACCESS dEntryToInspect.pNext;
							ELSE
								// no more entries, not found
								status := hashERR_STRINGNOTFOUND;
								bExit := TRUE;
							END_IF
						ELSE
							// found! 
							IF pParentEntry > 0 THEN
								// we're in a allocated area
								dParentEntry ACCESS pParentEntry;
								// 
								pThis := dParentEntry.pNext;
								// link parent and child
								dParentEntry.pNext := dEntryToInspect.pNext;
								
								// de-allocate data segments
								IF dEntryToInspect.Data.pNextData > 0 THEN
									pNext := dEntryToInspect.Data.pNextData;
									REPEAT
										GetNextStrDataP_0(ident := ident, pDataset := pNext);
										AsMemPartFree_0(enable := TRUE, ident := dInternal.identMemPartCreate, mem := pNext);
										IF AsMemPartFree_0.status > 0 THEN
											status := AsMemPartFree_0.status;
										END_IF								
										IF GetNextStrDataP_0.status = 0 THEN
											pNext := GetNextStrDataP_0.pNextData;
										ELSE
											status := GetNextStrDataP_0.status;
										END_IF
										UNTIL pNext = 0 OR GetNextStrDataP_0.status <> 0 OR AsMemPartFree_0.status <> 0
									END_REPEAT
								END_IF
								
								// de-allocate entry
								AsMemPartFree_0(enable := TRUE, ident := dInternal.identMemPartCreate, mem := pThis);
								IF AsMemPartFree_0.status > 0 THEN
									status := AsMemPartFree_0.status;
								END_IF								
								
								// done!
							ELSE
								// we're in the base table, so delete the base table entry
								brsmemset(ADR(dTableEntryToInspect), 0, SIZEOF(dTableEntryToInspect));
								status := 0;
							END_IF
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
