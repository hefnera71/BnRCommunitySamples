(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLTcpPrint.st
 * Author: hefnera
 * Created: September 20, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* ONY FOR USE IN EXIT PROGRAM - Deinitialize function *)
FUNCTION_BLOCK PCLTcpExit
	
	
	(*  *)
	status := 16#FFFF;
	IF ident > 0 THEN
		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.memPartCreateIdent > 0 THEN
				AsMemPartDestroy_0(enable := TRUE, ident := dynInternal.memPartCreateIdent);
				dynInternal.state := AsMemPartDestroy_0.status;
			ELSE
				dynInternal.state := PCLTCP_ERR_MEMORY;
			END_IF
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
		END_IF
  	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
	END_IF
	status := dynInternal.state;	
	
END_FUNCTION_BLOCK
