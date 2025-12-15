(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* ABSOLUTE positioning of the printing cursor inside the PCL coordinate system *)
FUNCTION PCLSetCursorAbs
	PCLSetCursorAbs := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, UINT_TO_REAL(x));
	PCLSetCursorAbs := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_ROW, UINT_TO_REAL(y));
END_FUNCTION
