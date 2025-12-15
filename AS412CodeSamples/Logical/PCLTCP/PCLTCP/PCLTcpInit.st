(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* ONLY FOR USE IN INIT PROGRAM - Initialize function *)
FUNCTION_BLOCK PCLTcpInit

	internal.STRUCT_START := STRUCT_IDENT;
	internal.STRUCT_END := STRUCT_IDENT;
	internal.state := 16#FFFF;
	ident := 0;
	IF pageSize > 0 THEN
 		AsMemPartCreate_0(enable := 1, len := pageSize + 128);
		internal.state := AsMemPartCreate_0.status;
		IF AsMemPartCreate_0.status = 0 THEN
			AsMemPartAlloc_0(enable := 1, ident := AsMemPartCreate_0.ident, len := pageSize);
  			internal.state := AsMemPartAlloc_0.status;
			IF AsMemPartAlloc_0.status = 0 THEN
				ident := ADR(internal);
				internal.ident := ident;
				internal.lenMem := pageSize;
				internal.pStartMem := AsMemPartAlloc_0.mem;
				internal.memPartCreateIdent := AsMemPartCreate_0.ident;
				internal.pNext := internal.pStartMem;
				internal.state := PCLResetMemory(ident);
				
				(* set some valid values *)
				internal.margins.colLeft := 0;
				internal.margins.colRight := 78;
				internal.margins.rowTop := 1;
				internal.margins.rowsPerPage := 60;
				
			END_IF
		END_IF
	END_IF
	status := internal.state;
	
END_FUNCTION_BLOCK
