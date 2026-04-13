
(* TODO: Add your comment here *)
FUNCTION_BLOCK INIT_StrHashTab
	
	status := 16#FFFF;
	ident := 0;
	IF nrOfHashTableElements > 0 THEN
		internal.hashModulo := nrOfHashTableElements;
		IF collisionMemSize > 0 THEN
			REPEAT
				// create a mem partition for hash table and collision memory
				AsMemPartCreate_0(enable := TRUE, len := collisionMemSize + nrOfHashTableElements * SIZEOF(HashTableBase_typ));
				UNTIL AsMemPartCreate_0.status <> 16#FFFF
			END_REPEAT
			IF AsMemPartCreate_0.status = 0 THEN
				internal.identMemPartCreate := AsMemPartCreate_0.ident;
				// allocate hash table
				REPEAT 
					AsMemPartAlloc_0(enable := TRUE, ident := AsMemPartCreate_0.ident, len := nrOfHashTableElements * SIZEOF(HashTableBase_typ));
					UNTIL AsMemPartAlloc_0.status <> 16#FFFF
				END_REPEAT
				IF AsMemPartAlloc_0.status = 0 THEN
					internal.pHashTable := AsMemPartAlloc_0.mem;
					ident := ADR(internal);
					status := 0;
				ELSE
					status := AsMemPartAlloc_0.status;
				END_IF
			ELSE
				status := AsMemPartCreate_0.status;
			END_IF
		ELSE
			status := hashERR_NULLMEM;
		END_IF
	ELSE
		status := hashERR_TABLESIZE;
	END_IF
	
	
END_FUNCTION_BLOCK
