(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* add a single character to virtual page *)
FUNCTION PCLAddChar

	IF ident > 0 THEN
		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				IF dynInternal.lenMem > 2 THEN
					tmp[0] := charVal;
					tmp[1] := 0;
					dynInternal.pNext := brsstrcpy(dynInternal.pNext, ADR(tmp));
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
	PCLAddChar := dynInternal.state;

END_FUNCTION
