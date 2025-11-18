(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: testprint
 * File: testprint.st
 * Author: hefnera
 * Created: September 20, 2011
 ********************************************************************
 * Implementation of program testStepprint
 ********************************************************************)

PROGRAM _INIT

	(* init functionality, allocate 50 kB of memory for pages *)
	(* !!! the PLCTcpInit function block is only allowed for use in _INIT program !!! *)
	PCLTcpInit_0(pageSize := 50000);
	ident := PCLTcpInit_0.ident;
	
	sIpAddrOfPrinter := '127.0.0.1'; // use here the right printer IP address

END_PROGRAM


PROGRAM _CYCLIC

	
	(* this is just an example for some function calls *)
	
	IF PCLTcpInit_0.status = 0 AND ident > 0 THEN
		
		CASE testStep OF
	
			1:
				(* reset internal page memory, for creating new page(s) *)
				PCLResetMemory(ident);

				(* add the library built-in test page - this generates inside the virtual page memory one page with some different strings / formats *)
				PCLAddTestPage(ident, TRUE, TRUE, TRUE, TRUE, TRUE);

				(* set some basic printer initialization commands *)
				(* this pre-defined sequence sets the printer to: 300 dpi, 1 copy, paper A4, orientation portrait, 0 line top margin, 0 col left margin, charset ANSI *)
				(* of course, you can also set the needed settings one by one using the predefined library constants or adding directly by string - please refer to the PCL command manual *)
				PCLAddString(ident, ADR(PCL_PAGE_INITSEQ_1));

				(* set font size a little bit smaller then normal *)
				PCLSetFontSize(ident, 8.0, 14.0);
	
				(* set page margins *)
				PCLSetPageMargins(ident, 5, 70, 5, 60);
				
				(* ---- add a headline with different formatting ----- *)
				(* bold and underline on *)
				PCLAddString(ident, ADR(PCL_CMD_BOLD_ON));
				PCLAddString(ident, ADR(PCL_CMD_UNDERLINE_ON));
				(* print some text *)
				PCLAddLine(ident, ADR('PCLTCP library demo task'));
				(* bold and underline off *)
				PCLAddString(ident, ADR(PCL_CMD_UNDERLINE_OFF));
				PCLAddString(ident, ADR(PCL_CMD_BOLD_OFF));
				
				(* ---- add some data ---- *)
				FOR ii := 1 TO 30 DO
					brsitoa(ii, ADR(szTmp));
					PCLAddString(ident, ADR('Line '));
					PCLAddString(ident, ADR(szTmp));
					PCLAddLine(ident, ADR(': the quick brown fox jumped over the lazy dog'));
				END_FOR
								
				(* ---- go somewhere to the end of page, print footer ---- *)
				PCLSetCursorAbs(ident, 5, 57);
				PCLAddLine(ident, ADR('------------------------------------------------'));
				PCLAddLine(ident, ADR('End of page'));
				PCLAddString(ident, ADR(PCL_FF));
				testStep := 2;
				
			2:
				(* send the virtual page content to the printer IP to print it! *)
				PCLTcpPrint_0(ident := ident, pIpAddr := ADR(sIpAddrOfPrinter), port := 9100, pInterface := 0);
				IF PCLTcpPrint_0.status <>16#FFFF THEN
					IF PCLTcpPrint_0.status = 0 THEN
						// success
						testStep := 0;
					ELSE
						// error reported by library, very likely because of AsTcp error
						testStep := 99;
					END_IF				
				END_IF
			
		END_CASE
		
	END_IF

END_PROGRAM

PROGRAM _EXIT

	(* destroys the memory partition created in PCLTcpInit *)
	(* !!! for use in EXIT function ONLY !!!! *)
	PCLTcpExit_0(ident := ident);
	ident := 0;
	
END_PROGRAM
