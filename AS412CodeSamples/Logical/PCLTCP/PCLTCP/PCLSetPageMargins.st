(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLSetPageMargins.st
 * Author: hefnera
 * Created: September 30, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* Setup margins of page *)
FUNCTION PCLSetPageMargins

	IF ident > 0 THEN
 		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				(* if parameter is < 0, do not change *)
				IF colLeft >= 0 THEN
					dynInternal.margins.colLeft := INT_TO_UINT(colLeft);
					PCLAddParam(ident, PCL_PARAM_MARGIN_COL_LEFT, INT_TO_REAL(colLeft));
				END_IF
				IF rowTop >= 0 THEN
					dynInternal.margins.rowTop := INT_TO_UINT(rowTop);
					PCLAddParam(ident, PCL_PARAM_MARGIN_ROW_TOP, INT_TO_REAL(rowTop));
				END_IF

				IF colRight >= 0 THEN
					IF INT_TO_UINT(colRight) > dynInternal.margins.colLeft THEN (* colRight must be > colLeft *)
						dynInternal.margins.colRight := INT_TO_UINT(colRight);
						PCLAddParam(ident, PCL_PARAM_MARGIN_COL_RIGHT, INT_TO_REAL(colRight));
					ELSE
						dynInternal.state := PCLTCP_ERR_VALUE_COLRIGHT;
					END_IF
				END_IF
				IF rowsPerPage >= 0 THEN
					IF rowsPerPage > 0 THEN (* of rows must be > 0 *)
						dynInternal.margins.rowsPerPage := INT_TO_UINT(rowsPerPage);
						PCLAddParam(ident, PCL_PARAM_MARGIN_NR_LINES, INT_TO_REAL(rowsPerPage));
					ELSE
						dynInternal.state := PCLTCP_ERR_VALUE_NRROWS;
					END_IF
				END_IF
			END_IF
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
		END_IF
  	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
	END_IF
	
	PCLSetPageMargins := dynInternal.state;

END_FUNCTION
