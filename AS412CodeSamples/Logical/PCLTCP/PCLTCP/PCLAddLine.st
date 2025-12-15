(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* add a line = string including CR+LF to virtual page *)
FUNCTION PCLAddLine
	
	PCLAddLine := PCLAddString(ident, pString);
	PCLAddLine := PCLAddCRLF(ident);

END_FUNCTION
