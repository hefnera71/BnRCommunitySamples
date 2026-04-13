
(* TODO: Add your comment here *)
FUNCTION_BLOCK MeasureRT
	
	
	IF EDGEPOS(Start) = TRUE THEN
		musecStart := AsIOTimeStamp();
	END_IF
	
	IF EDGENEG(Start) = TRUE THEN
		// stop measurement
		musecStop := AsIOTimeStamp();
		musecDiff := musecStop - musecStart;

		DifferenceUs := musecDiff;
		DifferenceMs := DINT_TO_REAL(DifferenceUs) / 1000.0;
	END_IF
	
	
END_FUNCTION_BLOCK
