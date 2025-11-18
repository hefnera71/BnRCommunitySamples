(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLAddCRLF.st
 * Author: hefnera
 * Created: September 30, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* Adds a PCL conform CR LF via cursor positioning commands *)
FUNCTION PCLAddCRLF


	IF ident > 0 THEN
 		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, UINT_TO_REAL(dynInternal.margins.colLeft));
				PCLAddParam(ident, PCL_PARAM_CURSOR_REL_POS_ROW, 1.0);
			END_IF
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
		END_IF
  	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
	END_IF
	
	PCLAddCRLF := dynInternal.state;	
	
END_FUNCTION
