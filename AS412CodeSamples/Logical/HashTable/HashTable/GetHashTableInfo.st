
(* TODO: Add your comment here *)
FUNCTION GetHashTableInfo
	IF ident > 0 THEN
		dInternal ACCESS ident;
		IF pHashInfo > 0 THEN
			dHashInfo ACCESS pHashInfo;
			dHashInfo.highestNrOfCollisions := 0;
			dHashInfo.sumOfCollisions := 0;
			dHashInfo.unusedTableFields := 0;
			dHashInfo.numBytesFree := 0;
			dHashInfo.maxBlockSizeFree := 0;
			FOR i := 0 TO dInternal.hashModulo - 1 DO
				dTableEntryToInspect ACCESS dInternal.pHashTable + i * SIZEOF(HashTableBase_typ);
				dCollision ACCESS ADR(dTableEntryToInspect.collisions);
				dHashInfo.sumOfCollisions := dHashInfo.sumOfCollisions + dCollision;
				IF dCollision > dHashInfo.highestNrOfCollisions THEN
					dHashInfo.highestNrOfCollisions := dCollision;
				END_IF
				IF dTableEntryToInspect.Field.pString = 0 THEN
					dHashInfo.unusedTableFields := dHashInfo.unusedTableFields + 1;
				END_IF
			END_FOR
			AsMemPartInfo_0(enable := TRUE, ident := dInternal.identMemPartCreate);
			IF AsMemPartInfo_0.status = 0 THEN
				dHashInfo.numBytesFree := AsMemPartInfo_0.numBytesFree;
				dHashInfo.maxBlockSizeFree := AsMemPartInfo_0.maxBlockSizeFree;
				GetHashTableInfo := 0;
			ELSE
				GetHashTableInfo := AsMemPartInfo_0.status;
			END_IF
		ELSE
			GetHashTableInfo := hashERR_NULLPOINTER;
		END_IF
	ELSE
		GetHashTableInfo := hashERR_NULLIDENT;
	END_IF
	
END_FUNCTION
