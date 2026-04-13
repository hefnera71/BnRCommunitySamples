
(* TODO: Add your comment here *)
FUNCTION EXIT_StrHashTab
	IF ident > 0 THEN
		dInternal ACCESS ident;
		IF dInternal.identMemPartCreate > 0 THEN
			REPEAT
				AsMemPartDestroy_0(enable := TRUE, ident := dInternal.identMemPartCreate);
				UNTIL AsMemPartDestroy_0.status <> 16#FFFF
			END_REPEAT
			EXIT_StrHashTab := AsMemPartDestroy_0.status;
		ELSE
			EXIT_StrHashTab := hashERR_NULLMEM;
		END_IF
	ELSE
		EXIT_StrHashTab := hashERR_NULLIDENT;
	END_IF
END_FUNCTION
