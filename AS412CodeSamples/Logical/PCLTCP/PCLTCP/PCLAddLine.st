(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLAddLine.st
 * Author: hefnera
 * Created: September 23, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* add a line = string including CR+LF to virtual page *)
FUNCTION PCLAddLine
	
	PCLAddLine := PCLAddString(ident, pString);
	PCLAddLine := PCLAddCRLF(ident);

END_FUNCTION
