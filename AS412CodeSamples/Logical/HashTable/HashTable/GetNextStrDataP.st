
(* access the next dataset after the actual one (only if more then one dataset was associated with a string - multipleDataAllowed = TRUE when inserting) *)
FUNCTION_BLOCK GetNextStrDataP
	status := 16#FFFF;
	IF ident > 0 THEN
		dInternal ACCESS ident;
		IF pDataset > 0 THEN
			dNextDataset ACCESS pDataset;
			pData := dNextDataset.pData;
			userTag := dNextDataset.userTag;
			pNextData := dNextDataset.pNextData;
			status := 0;
		ELSE
			status := hashERR_NULLPOINTER;
		END_IF
	ELSE
		status := hashERR_NULLIDENT;
	END_IF

END_FUNCTION_BLOCK
