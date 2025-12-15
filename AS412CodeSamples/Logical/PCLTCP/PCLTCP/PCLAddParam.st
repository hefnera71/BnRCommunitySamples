(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* handle some predefined parameters, add command to virtual page *)
FUNCTION PCLAddParam
	
	brsftoa(value, ADR(szVal));
 	
	CASE param OF
		
		PCL_PARAM_FONTPITCH_PRIMARY:	(* sets the font size, see PCL5 spec. for value  *)
			PCLAddParam := PCLAddString(ident, ADR('$1B(s'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('H'));
			
		PCL_PARAM_FONTHEIGHT_PRIMARY:	(* sets the font height, see PCL5 spec. for value  *)
			PCLAddParam := PCLAddString(ident, ADR('$1B(s'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('V'));

		PCL_PARAM_FONTCODE_PRIMARY:	(* sets the primary font code, see PCL5 spec. for value  *)
			PCLAddParam := PCLAddString(ident, ADR('$1B(s'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('T'));
		
		PCL_PARAM_FONTSTYLE_PRIMARY:	(* sets the primary font style, see PCL5 spec. for value *)
			PCLAddParam := PCLAddString(ident, ADR('$1B(s'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('S'));

		PCL_PARAM_MARGIN_ROW_TOP:	(* nr of lines as top margin *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&l'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('E'));
		
		PCL_PARAM_MARGIN_COL_LEFT:	(* nr of columns as left margin *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('L'));

		PCL_PARAM_MARGIN_COL_RIGHT: (* nr of colums as right margin *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('M'));
		
		PCL_PARAM_MARGIN_NR_LINES:	(* nr of lines per page *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&l'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('F'));
			
		PCL_PARAM_CURSOR_ABS_COL:	(* cursor column position, absolute to printable area *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('C'));
		
		PCL_PARAM_CURSOR_ABS_ROW:	(* cursor row position, absolute to printable area *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('R'));
		
		PCL_PARAM_CURSOR_REL_POS_COL:	(* cursor column position, positive relative to actual position *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a+'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('C'));
		
		PCL_PARAM_CURSOR_REL_POS_ROW:	(* cursor row position, positive relative to actual position *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a+'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('R'));
		
		PCL_PARAM_CURSOR_REL_NEG_COL:	(* cursor column position, negative relative to actual position *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a-'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('C'));
		
		PCL_PARAM_CURSOR_REL_NEG_ROW:	(* cursor row position, negative relative to actual position *)
			PCLAddParam := PCLAddString(ident, ADR('$1B&a-'));
			PCLAddParam := PCLAddString(ident, ADR(szVal));
			PCLAddParam := PCLAddString(ident, ADR('R'));

		

 	END_CASE	

END_FUNCTION
