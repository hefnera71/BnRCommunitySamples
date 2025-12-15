(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(*  RELATIVE positioning of the printing cursor inside the PCL coordinate system  *)
FUNCTION PCLSetCursorRel

	IF x >= 0 THEN
		PCLSetCursorRel := PCLAddParam(ident, PCL_PARAM_CURSOR_REL_POS_COL, INT_TO_REAL(x));
 	ELSE
		PCLSetCursorRel := PCLAddParam(ident, PCL_PARAM_CURSOR_REL_NEG_COL, INT_TO_REAL(ABS(x)));
	END_IF

	IF y >= 0 THEN
		PCLSetCursorRel := PCLAddParam(ident, PCL_PARAM_CURSOR_REL_POS_ROW, INT_TO_REAL(y));
 	ELSE
		PCLSetCursorRel := PCLAddParam(ident, PCL_PARAM_CURSOR_REL_NEG_ROW, INT_TO_REAL(ABS(y)));
	END_IF


END_FUNCTION
