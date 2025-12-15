(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(*
	TODO:

	extended error handling for tcp!! (e.g. what to do if not all data could be sent


*)
(* send data to printer *)
FUNCTION_BLOCK PCLTcpPrint
	
	(*  *)
	status := 16#FFFF;
	IF ident > 0 THEN
		dynInternal ACCESS ident;
		IF dynInternal.STRUCT_START = STRUCT_IDENT AND dynInternal.STRUCT_END = STRUCT_IDENT THEN
			IF dynInternal.state = 0 AND tcpStep = TCP_STEP_IDLE THEN
				PCLAddString(dynInternal.ident,ADR(PCL_PJL_FOOTER));
				IF dynInternal.state = 0 THEN
					tcpStep := TCP_STEP_OPEN;
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
	
	(*  *)
	CASE tcpStep OF
		
		(* nothing to do *)
		TCP_STEP_IDLE:
			status := dynInternal.state;
		
		(* open tcp socket *)
		TCP_STEP_OPEN:
			(* do some parameter checks tcp client fub *)
			IF port = 0 THEN
				(* set port to default port *)
   				TcpClient_0.portserv := 9100;
			ELSE
   				TcpClient_0.portserv := port;
			END_IF				
						
			IF pIpAddr = 0 THEN
				(*error: no ip address *)
				tcpStep := TCP_STEP_IDLE;
				dynInternal.state := PCLTCP_ERR_NOIP;
			ELSE
				(* open tcp socket *)
				TcpOpen_0(enable := 1, pIfAddr := pInterface, port := 0, options := 0);
				dynInternal.tcp.state := TcpOpen_0.status;
				IF TcpOpen_0.status <> 16#FFFF THEN
					IF TcpOpen_0.status = 0 THEN
						tcpStep := TCP_STEP_CLIENT;
					ELSE
						tcpStep := TCP_STEP_IDLE;
						dynInternal.tcp.err_step := tcpStep;
					END_IF
				END_IF
			END_IF

		(* try to open tcp connection *)			
		TCP_STEP_CLIENT:
			TcpClient_0(enable := 1, ident := TcpOpen_0.ident, pServer := pIpAddr);
			dynInternal.tcp.state := TcpClient_0.status;
			IF TcpClient_0.status <> 16#FFFF THEN
   				IF TcpClient_0.status = 0 THEN
					tcpStep := TCP_STEP_SEND;
					(* set some parameters for TcpSend *)
					TcpSend_0.pData := dynInternal.pStartMem;
					TcpSend_0.datalen := dynInternal.lenData;
   				ELSE
					tcpStep := TCP_STEP_ERR_CLOSE;
					dynInternal.tcp.err_step := tcpStep;
				END_IF
			END_IF
			
		(* send page to printer *)			
		TCP_STEP_SEND:
			TcpSend_0(enable := 1, ident := TcpOpen_0.ident, flags := 0);
			dynInternal.tcp.state := TcpSend_0.status;
			IF TcpSend_0.status <> 16#FFFF THEN
				CASE TcpSend_0.status OF
   					0:
						tcpStep := TCP_STEP_CLOSE;
					
					tcpERR_SENTLEN:
						(* not all data could be sent, send rest of it *)
						TcpSend_0.pData := dynInternal.pStartMem + TcpSend_0.sentlen;
						TcpSend_0.datalen := dynInternal.lenData - TcpSend_0.sentlen;
					
					tcpERR_WOULDBLOCK:
						(* cant send, try again later *)
						tcpStep := TCP_STEP_WAITSEND;
						dynInternal.tcp.enableSendWait := TRUE;
					
					ELSE
						(* some error happened that we could not resolve in actual cycle: close socket *)
						tcpStep := TCP_STEP_ERR_CLOSE;
						dynInternal.tcp.err_step := tcpStep;
						
				END_CASE
			END_IF
		
		(* close tcp after sending page *)		
		TCP_STEP_CLOSE:
			TcpClose_0(enable := 1, ident := TcpOpen_0.ident, how := 0);
			dynInternal.tcp.state := TcpClose_0.status;
			IF TcpClose_0.status <> 16#FFFF THEN
				tcpStep := TCP_STEP_IDLE;
   				IF TcpClose_0.status = 0 THEN
					dynInternal.state := 0;
				ELSE
					dynInternal.tcp.err_step := tcpStep;
				END_IF
			END_IF
		
		(* wait some time, then try to send again *)
		TCP_STEP_WAITSEND:
			IF TON_0.Q = TRUE THEN
   				dynInternal.tcp.enableSendWait := FALSE;
				tcpStep := TCP_STEP_SEND;
			END_IF							
		
		(* close tcp after error happened *)
		TCP_STEP_ERR_CLOSE:
			TcpClose_0(enable := 1, ident := TcpOpen_0.ident, how := 0);
			IF TcpClose_0.status <> 16#FFFF THEN
				tcpStep := TCP_STEP_IDLE;
			END_IF

 	END_CASE	
	
	(* timer for send wait *)
	TON_0(IN := dynInternal.tcp.enableSendWait, PT := T#200ms);

	dynInternal.tcp.step := tcpStep;
	
	IF dynInternal.tcp.state > 0 AND tcpStep = TCP_STEP_IDLE THEN
		dynInternal.state := dynInternal.tcp.state;
	END_IF
	
	IF tcpStep = TCP_STEP_IDLE THEN
		status := dynInternal.state;
	END_IF

END_FUNCTION_BLOCK
