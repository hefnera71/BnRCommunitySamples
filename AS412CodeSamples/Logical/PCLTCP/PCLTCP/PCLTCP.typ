(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLTCP.typ
 * Author: hefnera
 * Created: September 20, 2011
 ********************************************************************
 * Data types of library PCLTCP
 ********************************************************************)

TYPE
	PCLTCP_Internal_Cfg_Font_type : 	STRUCT 
		pitch : REAL;
		height : REAL;
	END_STRUCT;
	PCLTCP_Internal_Cfg_Margins_type : 	STRUCT 
		colLeft : UINT;
		colRight : UINT;
		rowTop : UINT;
		rowsPerPage : UINT;
	END_STRUCT;
	PCLTCP_Internal_TCP_type : 	STRUCT 
		state : UINT;
		step : UINT;
		err_step : UINT;
		enableSendWait : BOOL;
	END_STRUCT;
	PCLTCP_Internal_type : 	STRUCT 
		STRUCT_START : UDINT;
		state : UINT;
		pNext : UDINT;
		pStartMem : UDINT;
		lenMem : UDINT;
		lenData : UDINT;
		ident : UDINT;
		tcp : PCLTCP_Internal_TCP_type;
		margins : PCLTCP_Internal_Cfg_Margins_type;
		font : PCLTCP_Internal_Cfg_Font_type;
		STRUCT_END : UDINT;
	END_STRUCT;
END_TYPE
