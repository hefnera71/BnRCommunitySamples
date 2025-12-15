(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* Adds a predefined test page to the virtual page - can be used to test printing functionality without adding much code  *)
FUNCTION PCLAddTestPage

	IF ident > 0 THEN
		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				
				(* store user defined page margins *)
				tmpMargins := dynInternal.margins;
				PCLAddTestPage := PCLSetPageMargins(ident, 0, 78, 1, 60);
				
			ELSE
				RETURN;
			END_IF
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
			RETURN;
		END_IF
  	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
		RETURN;
	END_IF



	PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
	PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_ROW, 5);

	PCLAddTestPage := PCLAddLine(ident, ADR('PCLTCP library test page printout'));
	PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));

	IF printTestSentence = TRUE THEN
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('the quick brown fox jumped over the lazy dog'));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('THE QUICK BROWN FOX JUMPED OVER THE LAZY DOG'));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CMD_BOLD_ON));
		PCLAddTestPage := PCLAddString(ident, ADR('BOLD: the quick brown fox jumped over the lazy dog'));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CMD_BOLD_OFF));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CMD_UNDERLINE_ON));
		PCLAddTestPage := PCLAddString(ident, ADR('UNDERLINED: the quick brown fox jumped over the lazy dog'));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CMD_UNDERLINE_OFF));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CMD_STYLE_ITALIC));
		PCLAddTestPage := PCLAddString(ident, ADR('ITALIC: the quick brown fox jumped over the lazy dog'));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CMD_STYLE_NORMAL));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
	END_IF
	
	(* Printable ASCII charset *)
	IF printAsciiCharset = TRUE THEN
		(* set cursor start position for charset *)
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddLine(ident, ADR('ASCII printable character set (32 - 126):'));
		FOR j := 0 TO 92 DO
			IF j MOD 7 = 0 THEN
				PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
				PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
			END_IF
			IF j < 10 THEN
				PCLAddTestPage := PCLAddString(ident, ADR('00'));
			ELSIF j < 100 THEN
				PCLAddTestPage := PCLAddString(ident, ADR('0'));
			END_IF
			brsitoa(j + 32, ADR(szTemp));
			PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
			PCLAddTestPage := PCLAddString(ident, ADR('= '));
			char := j + 32;
			PCLAddTestPage := PCLAddString(ident, ADR(char));
			PCLAddTestPage := PCLAddString(ident, ADR(' '));
		END_FOR
	END_IF
	
	IF printExtCharset = TRUE THEN
		(* extended charset *)
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddLine(ident, ADR('extended character set (128 - 255):'));
		FOR j := 0 TO 127 DO
			IF j MOD 7 = 0 THEN
				PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
				PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
			END_IF
			brsitoa(j + 128, ADR(szTemp));
			PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
			PCLAddTestPage := PCLAddString(ident, ADR('= '));
			char := j + 128;
			PCLAddTestPage := PCLAddString(ident, ADR(char));
			PCLAddTestPage := PCLAddString(ident, ADR(' '));
		END_FOR
	END_IF
	
	IF printInternalCfg = TRUE THEN
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('left margin (column): '));
		brsitoa(tmpMargins.colLeft, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('right margin (column): '));
		brsitoa(tmpMargins.colRight, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('top margin (row): '));
		brsitoa(tmpMargins.rowTop, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('number of lines per page (row): '));
		brsitoa(tmpMargins.rowsPerPage, ADR(szTemp));
		PCLAddString(ident, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('font height (pixel): '));
		brsftoa(dynInternal.font.height, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
		PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 5);
		PCLAddTestPage := PCLAddString(ident, ADR('font pitch (characters per inch): '));
		brsftoa(dynInternal.font.pitch, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));
	END_IF
	
	(* horizontal raster, print 70 columns *)				
	PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_COL, 1);
	PCLAddTestPage := PCLAddParam(ident, PCL_PARAM_CURSOR_ABS_ROW, 0);
	x := 1;
	FOR j := 0 TO 6 DO
		FOR i := x TO 9 DO
			IF i = 0 THEN
				brsitoa(j, ADR(szTemp));
				PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
			ELSE
				PCLAddTestPage := PCLAddString(ident, ADR('.'));
			END_IF
		END_FOR
		x := 0;
	END_FOR
	PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
	FOR j := 0 TO 6 DO
		PCLAddTestPage := PCLAddString(ident, ADR('0123456789'));
	END_FOR
	PCLAddTestPage := PCLAddString(ident, ADR(PCL_CRLF));				
	
	(* vertical raster, print 60 lines *)
	y := 2;
	FOR j := 0 TO 5 DO
		FOR i := y TO 9 DO
			IF i = 0 THEN
				brsitoa(j, ADR(szTemp));
				PCLAddTestPage := PCLAddString(ident, ADR(szTemp));
			ELSE
				PCLAddTestPage := PCLAddString(ident, ADR('.'));
			END_IF
		 	brsitoa(i, ADR(szTemp));
			PCLAddTestPage := PCLAddLine(ident, ADR(szTemp));
		END_FOR
		y := 0;
	END_FOR
	
	(* form fead for releasing page *)
	IF printFormFeed = TRUE THEN
		PCLAddTestPage := PCLAddString(ident, ADR(PCL_FF));
	END_IF
	
	(* restore user margin settings *)
	PCLAddTestPage := PCLSetPageMargins(ident, tmpMargins.colLeft, tmpMargins.colRight, tmpMargins.rowTop, tmpMargins.rowsPerPage);


END_FUNCTION
