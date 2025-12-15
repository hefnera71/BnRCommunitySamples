(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* reset the virtual page memory *)
FUNCTION PCLResetMemory

	IF ident > 0 THEN
		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			dynInternal.state := 0;
			dynInternal.pNext := dynInternal.pStartMem;
			PCLAddString(dynInternal.ident, ADR(PCL_PJL_HEADER));
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
		END_IF
	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
	END_IF
	PCLResetMemory := dynInternal.state;

END_FUNCTION
