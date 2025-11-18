(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLSetFontSize.st
 * Author: hefnera
 * Created: September 30, 2011
 ********************************************************************
 * Implementation of library PCLTCP
 ********************************************************************) 

(* Setup font height and pitch, height in pixel, pitch in chars per inch *)
(* if input is 0, don't change parameter *)
FUNCTION PCLSetFontSize

		IF ident > 0 THEN
 		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 THEN
				IF pitch > 0 THEN
					dynInternal.font.pitch := pitch;
					PCLAddParam(ident, PCL_PARAM_FONTPITCH_PRIMARY, pitch);
				END_IF
				IF height > 0 THEN
					dynInternal.font.height := height;
					PCLAddParam(ident, PCL_PARAM_FONTHEIGHT_PRIMARY, height);
				END_IF
			END_IF
		ELSE
			dynInternal.state := PCLTCP_ERR_INVALID_IDENT;
		END_IF
  	ELSE
		dynInternal.state := PCLTCP_ERR_NO_IDENT;
	END_IF

	PCLSetFontSize := dynInternal.state;
	
END_FUNCTION
