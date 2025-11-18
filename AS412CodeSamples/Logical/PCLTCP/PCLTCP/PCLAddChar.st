(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLAddChar.st
 * Author: hefnera
 * Created: September 29, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* TODO: Add your comment here *)
FUNCTION PCLAddChar

	IF ident > 0 THEN
 		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				IF dynInternal.lenMem > 2 THEN
					tmp[0] := charVal;
					tmp[1] := 0;
					dynInternal.pNext := brsstrcpy(dynInternal.pNext, ADR(tmp));
					dynInternal.lenData := dynInternal.pNext - dynInternal.pStartMem;
				ELSE
					dynInternal.state := PCLTCP_ERR_MEMORY;
				END_IF
			END_IF
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
		END_IF
  	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
	END_IF
	PCLAddChar := dynInternal.state;

END_FUNCTION
