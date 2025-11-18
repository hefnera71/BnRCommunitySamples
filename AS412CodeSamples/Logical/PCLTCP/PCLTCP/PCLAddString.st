(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLAddString.st
 * Author: hefnera
 * Created: September 20, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* TODO: Add your comment here *)
FUNCTION PCLAddString

	IF ident > 0 THEN
 		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				szLen := brsstrlen(pString);
				IF dynInternal.lenMem > (dynInternal.pNext - dynInternal.pStartMem + szLen) THEN
					dynInternal.pNext := brsstrcpy(dynInternal.pNext, pString);
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
	PCLAddString := dynInternal.state;

END_FUNCTION
