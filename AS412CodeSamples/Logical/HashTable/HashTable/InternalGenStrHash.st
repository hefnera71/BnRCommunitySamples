
(* TODO: Add your comment here *)
FUNCTION InternalGenStrHash
	
	IF pString > 0 THEN
		IF hashModulo > 0 THEN
			pNext := pString;
			udSum := 0;
			REPEAT
				usChar ACCESS pNext;
				usPrimeIndex := UDINT_TO_USINT((pNext - pString + 1) MOD 100);
				udSum := udSum + USINT_TO_UDINT(usChar) * uPrimeFactor[usPrimeIndex]; //difference of pointers used as "coutner"
				pNext := pNext + 1;
				UNTIL usChar = 0
			END_REPEAT;
			InternalGenStrHash := udSum MOD hashModulo;			
		ELSE
			InternalGenStrHash := hashERR_NULLMODULO;
		END_IF
	ELSE
		InternalGenStrHash := hashERR_NULLPOINTER;
	END_IF
	
	
END_FUNCTION
