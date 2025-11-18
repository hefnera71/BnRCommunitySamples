(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLSetCursorAbs.st
 * Author: hefnera
 * Created: September 29, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* TODO: Add your comment here *)
FUNCTION PCLSetCursorAbs
	PCLSetCursorAbs := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, UINT_TO_REAL(x));
	PCLSetCursorAbs := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_ROW, UINT_TO_REAL(y));
END_FUNCTION
