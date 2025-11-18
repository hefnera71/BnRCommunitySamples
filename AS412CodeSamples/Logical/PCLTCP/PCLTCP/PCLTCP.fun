(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: PCLTCP
 * File: PCLTCP.fun
 * Author: hefnera
 * Created: September 20, 2011
 ********************************************************************
 * Functions and function blocks of library PCLTCP
 ********************************************************************)

FUNCTION_BLOCK PCLTcpInit (*Initialize function, ONLY FOR INIT USE*)
	VAR_INPUT
		pageSize : UDINT; (* number of bytes of page memory*)
	END_VAR
	VAR_OUTPUT
		status : UINT; (* state of fub / function call *)
		ident : UDINT; (* ident for other functions *)
	END_VAR
	VAR
		internal : PCLTCP_Internal_type;
		AsMemPartCreate_0 : AsMemPartCreate;
		AsMemPartAlloc_0 : AsMemPartAlloc;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK PCLTcpPrint (* send page memory to printer *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		pIpAddr : UDINT; (* pointer to ip address of printer, given as string *)
		port : UINT; (* printer tcp port, if set to 0 default is used, default = 9100 *)
		pInterface : UDINT; (* pointer to interface address, if set to 0, no specific interface is used *)
	END_VAR
	VAR_OUTPUT
		status : UINT; (* state of fub / function call *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
		tcpStep : UINT;
		TcpOpen_0 : TcpOpen;
		TcpClient_0 : TcpClient;
		TcpClose_0 : TcpClose;
		TcpSend_0 : TcpSend;
		TON_0 : TON;
	END_VAR
	VAR CONSTANT
		TCP_STEP_IDLE : UINT := 0;
		TCP_STEP_OPEN : UINT := 10;
		TCP_STEP_CLIENT : UINT := 20;
		TCP_STEP_SEND : UINT := 30;
		TCP_STEP_CLOSE : UINT := 40;
		TCP_STEP_ERR_CLOSE : UINT := 900;
		TCP_STEP_WAITSEND : UINT := 50;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK PCLTcpExit
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
	END_VAR
	VAR_OUTPUT
		status : UINT; (* state of fub / function call *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
		AsMemPartDestroy_0 : AsMemPartDestroy;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION PCLAddString : UINT (* add a character or command string to page *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		pString : UDINT; (* pointer to string to add *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
		szLen : UDINT;
	END_VAR
END_FUNCTION

FUNCTION PCLResetMemory : UINT (* initialize page memory *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
	END_VAR
END_FUNCTION

FUNCTION PCLAddLine : UINT (* add a character or command string to page, with PCL_CRLF at end *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		pString : UDINT; (* pointer to string to add *)
	END_VAR
END_FUNCTION

FUNCTION PCLAddParam : UINT (* add a PCL command parameter to page *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		param : UINT; (* wanted parameter, use constants PCL_PARAM_xxxx *)
		value : REAL; (* wanted value of parameter *)
	END_VAR
	VAR
		szVal : STRING[20];
	END_VAR
END_FUNCTION

FUNCTION PCLAddTestPage : UINT (* add a test page to page memory *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		printTestSentence : BOOL;
		printAsciiCharset : BOOL; (* print out table of value and sign from 32 - 126 *)
		printExtCharset : BOOL; (* print out table of value and sign 128 - 255 *)
		printInternalCfg : BOOL; (*print out some internal information*)
		printFormFeed : BOOL; (* add form feed at end of page *)
	END_VAR
	VAR
		j : USINT;
		szTemp : STRING[10];
		char : USINT;
		i : USINT;
		y : USINT;
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
		tmpMargins : PCLTCP_Internal_Cfg_Margins_type;
		x : USINT;
	END_VAR
END_FUNCTION

FUNCTION PCLAddChar : UINT (* add a single character value to page *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		charVal : USINT; (* value to add *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
		tmp : ARRAY[0..1] OF USINT;
	END_VAR
END_FUNCTION

FUNCTION PCLSetCursorAbs : UINT (* set a absolute cursor position, x= row, y = column *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		x : UINT; (* cursor row *)
		y : UINT; (* cursor column *)
	END_VAR
END_FUNCTION

FUNCTION PCLSetCursorRel : UINT (* set a relative cursor position, x= row, y = column *)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		x : INT; (* cursor row *)
		y : INT; (* cursor column *)
	END_VAR
END_FUNCTION

FUNCTION PCLAddCRLF : UINT (*Adds a PCL conform CR LF via cursor positioning commands*)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
	END_VAR
END_FUNCTION

FUNCTION PCLSetPageMargins : UINT (*Setup margins of page*)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		colLeft : INT; (* left margin in columns *)
		colRight : INT; (* right margin in columns *)
		rowTop : INT; (* top margin in rows *)
		rowsPerPage : INT; (* number of rows per page *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
	END_VAR
END_FUNCTION

FUNCTION PCLSetFontSize : UINT (*Setup font height and pitch, height in pixel, pitch in chars per inch*)
	VAR_INPUT
		ident : UDINT; (* ident from init function *)
		height : REAL; (* height in pixel *)
		pitch : REAL; (* pitch in characters per inch *)
	END_VAR
	VAR
		dynInternal : REFERENCE TO PCLTCP_Internal_type;
	END_VAR
END_FUNCTION
