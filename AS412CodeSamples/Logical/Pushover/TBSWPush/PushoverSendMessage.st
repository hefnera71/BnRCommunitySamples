(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* provide the pushover web client service *)
FUNCTION_BLOCK PushoverSendMessage

	internal.interface.send := send;
	
	CASE internal.control.mainStep OF
		
		pushoverHTTP_IDLE:
			IF internal.interface.send = TRUE THEN
				internal.interface.success := FALSE;
				internal.interface.error := FALSE;
				internal.interface.busy := TRUE;
				internal.interface.msg_error := FALSE;
				internal.control.wrongParameter := FALSE;
				brsmemset(ADR(internal.interface.msg_status),0,SIZEOF(internal.interface.msg_status));
				// copy interface to internal structure to avoid overwriting of data by user while processing	
				brsmemcpy(ADR(internal.interface.message),ADR(MessageParameters),SIZEOF(internal.interface.message));
	
				internal.http.uri := 'api.pushover.net';
				internal.http.header.url := 'POST /1/messages.json HTTP/1.1$r$l';
				internal.http.header.userAgent := 'User-Agent: BuR-SG4/AR$r$l';
				internal.http.header.host := 'Host: api.pushover.net$r$l';
				internal.http.header.accept := 'Accept: */*$r$l';
				internal.http.header.contentType := 'Content-Type: application/x-www-form-urlencoded$r$l';
				internal.http.header.contentLength := 'Content-Length: ';
				internal.http.header.endOfHeader := '$r$l$r$l';
		
				internal.control.mainStep := pushoverHTTP_PREPAREMESSAGE;
			END_IF

		
		pushoverHTTP_PREPAREMESSAGE:
			
			brsmemset(ADR(internal.http.content), 0, SIZEOF(internal.http.content));
			
			internal.fub.HTTPSetParamUrl.enable := TRUE;
			internal.fub.HTTPSetParamUrl.pDest := ADR(internal.http.content);
			internal.fub.HTTPSetParamUrl.destSize := SIZEOF(internal.http.content);
			
			// set pushover application key
			IF brsstrlen(ADR(internal.interface.message.applicationKey)) > 0 THEN
				internal.fub.HTTPSetParamUrl.pParam := ADR('token');
				internal.fub.HTTPSetParamUrl.pValue := ADR(internal.interface.message.applicationKey);
				internal.fub.HTTPSetParamUrl();
			ELSE
				// is a mandatory parameter !!!
				internal.control.wrongParameter := TRUE;
				internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,pusherrorAPPKEYEMPTY);
			END_IF
			
	
			// set key to send to
			IF brsstrlen(ADR(internal.interface.message.userKey)) > 0 THEN
				internal.fub.HTTPSetParamUrl.pParam := ADR('user');
				internal.fub.HTTPSetParamUrl.pValue := ADR(internal.interface.message.userKey);
				internal.fub.HTTPSetParamUrl();
			ELSE
				// is a mandatory parameter !!!
				internal.control.wrongParameter := TRUE;
				internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,pusherrorUSERKEYEMPTY);
			END_IF
			
			// set devices to send to
			IF brsstrlen(ADR(internal.interface.message.device)) > 0 THEN
				internal.fub.HTTPSetParamUrl.pParam := ADR('device');
				internal.fub.HTTPSetParamUrl.pValue := ADR(internal.interface.message.device);
				internal.fub.HTTPSetParamUrl();
			END_IF
			
			// set suplementary url
			IF brsstrlen(ADR(internal.interface.message.supplUrl.title)) >0 AND brsstrlen(ADR(internal.interface.message.supplUrl.url)) >0 THEN
				internal.fub.HTTPSetParamUrl.pParam := ADR('url_title');
				internal.fub.HTTPSetParamUrl.pValue := ADR(internal.interface.message.supplUrl.title);
				internal.fub.HTTPSetParamUrl();
				internal.fub.HTTPSetParamUrl.pParam := ADR('url');
				internal.fub.HTTPSetParamUrl.pValue := ADR(internal.interface.message.supplUrl.url);
				internal.fub.HTTPSetParamUrl();
			END_IF
			
			// set message priority
			internal.buffer.tempString := '';
			brsitoa(internal.interface.message.priority.flag, ADR(internal.buffer.tempString));
			internal.fub.HTTPSetParamUrl.pParam := ADR('priority');
			internal.fub.HTTPSetParamUrl.pValue := ADR(internal.buffer.tempString);
			internal.fub.HTTPSetParamUrl();
			
			// if emergency prio., wie have to set "retry" and "expire" also, as seconds!! 
			IF internal.interface.message.priority.flag = pushprioEMERGENCY THEN
				IF internal.interface.message.priority.expireMinutes > 0 THEN
					internal.buffer.tempString := '';
					brsitoa(internal.interface.message.priority.expireMinutes * 60, ADR(internal.buffer.tempString));
					internal.fub.HTTPSetParamUrl.pParam := ADR('expire');
					internal.fub.HTTPSetParamUrl.pValue := ADR(internal.buffer.tempString);
					internal.fub.HTTPSetParamUrl();
				ELSE
					// is a mandatory parameter !!!
					internal.control.wrongParameter := TRUE;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,pusherrorEXPMINUTESEMPTY);
				END_IF
				IF internal.interface.message.priority.retryMinutes > 0 THEN
					internal.buffer.tempString := '';
					brsitoa(internal.interface.message.priority.retryMinutes * 60, ADR(internal.buffer.tempString));
					internal.fub.HTTPSetParamUrl.pParam := ADR('retry');
					internal.fub.HTTPSetParamUrl.pValue := ADR(internal.buffer.tempString);
					internal.fub.HTTPSetParamUrl();
				ELSE
					// is a mandatory parameter !!!
					internal.control.wrongParameter := TRUE;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,pusherrorRETRYMINUTESEMPTY);
				END_IF
			END_IF
			
			
			// finish content

			// set title
			internal.buffer.tempString := '';
			internal.fub.HTTPWStringToUTF8.enable := TRUE;
			internal.fub.HTTPWStringToUTF8.pSrc := ADR(internal.interface.message.wsTitle);
			internal.fub.HTTPWStringToUTF8.pDest := ADR(internal.buffer.tempString);
			internal.fub.HTTPWStringToUTF8.destSize := SIZEOF(internal.buffer.tempString);
			internal.fub.HTTPWStringToUTF8();

			internal.fub.HTTPSetParamUrl.pParam := ADR('title');
			internal.fub.HTTPSetParamUrl.pValue := ADR(internal.buffer.tempString);
			internal.fub.HTTPSetParamUrl();

			// set content
			IF brwcslen(ADR(internal.interface.message.wsContent)) > 0 THEN
				internal.buffer.tempString := '';
				internal.fub.HTTPWStringToUTF8.enable := TRUE;
				internal.fub.HTTPWStringToUTF8.pSrc := ADR(internal.interface.message.wsContent);
				internal.fub.HTTPWStringToUTF8.pDest := ADR(internal.buffer.tempString);
				internal.fub.HTTPWStringToUTF8.destSize := SIZEOF(internal.buffer.tempString);
				internal.fub.HTTPWStringToUTF8();
	
				internal.fub.HTTPSetParamUrl.pParam := ADR('message');
				internal.fub.HTTPSetParamUrl.pValue := ADR(internal.buffer.tempString);
				internal.fub.HTTPSetParamUrl();
			ELSE
				// is a mandatory parameter !!!
				internal.control.wrongParameter := TRUE;
				internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,pusherrorCONTENTEMPTY);
			END_IF
			
			
			// prepare header + content to send buffer
			
			// get message content length
			internal.buffer.tempString := '';
			brsitoa(brsstrlen(ADR(internal.http.content)) -1, ADR(internal.buffer.tempString)); // length -1 = remove leading "?"
			internal.http.header.contentLength := 'Content-Length: ';
			brsstrcat(ADR(internal.http.header.contentLength),ADR(internal.buffer.tempString));
			
			// prepare send buffer
			internal.buffer.sendBuffer := '';
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.url));
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.userAgent));
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.host));
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.accept));		
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.contentType));
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.contentLength));
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.header.endOfHeader));
			brsstrcat(ADR(internal.buffer.sendBuffer), ADR(internal.http.content) + 1); // address +1 = remove leading "?"
			
			IF internal.control.wrongParameter = FALSE THEN
				IF internal.control.debug = FALSE THEN
					internal.control.mainStep := pushoverHTTP_TCPOPEN;
				ELSE
					internal.control.mainStep := pushoverHTTP_IDLE;
				END_IF
			ELSE
				internal.control.mainStep := pushoverHTTPERROR_BEFORETCPOPEN;
			END_IF
		
		
		pushoverHTTP_TCPOPEN:
			internal.fub.TCPOpenSSL.enable := TRUE;
			internal.fub.TCPOpenSSL.sslCfgIdent := 0;
			internal.fub.TCPOpenSSL.options := 0;
			internal.fub.TCPOpenSSL.pIfAddr := 0;
			internal.fub.TCPOpenSSL.port := 0;
			internal.fub.TCPOpenSSL();
			IF internal.fub.TCPOpenSSL.status <> 16#FFFF THEN
				IF internal.fub.TCPOpenSSL.status = 0 THEN
					internal.control.mainStep := pushoverHTTP_CLIENT;
				ELSE
					internal.control.mainStep := pushoverHTTPERROR_BEFORETCPOPEN;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,internal.fub.TCPOpenSSL.status);
				END_IF
			END_IF
		
		pushoverHTTP_CLIENT:
			internal.fub.TCPClient.enable := TRUE;
			internal.fub.TCPClient.ident := internal.fub.TCPOpenSSL.ident;
			internal.fub.TCPClient.portserv := 443;
			internal.fub.TCPClient.pServer := ADR(internal.http.uri);
			internal.fub.TCPClient();
			IF internal.fub.TCPClient.status <> 16#FFFF THEN
				IF internal.fub.TCPClient.status = 0 THEN
					internal.control.mainStep := pushoverHTTP_SEND;
				ELSE
					internal.control.mainStep := pushoverHTTPERROR_AFTERTCPOPEN;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,internal.fub.TCPClient.status);
				END_IF
			END_IF
		
		pushoverHTTP_SEND:
			internal.fub.TCPSend.enable := TRUE;
			internal.fub.TCPSend.flags := 0;
			internal.fub.TCPSend.ident := internal.fub.TCPOpenSSL.ident;
			internal.fub.TCPSend.pData := ADR(internal.buffer.sendBuffer);
			internal.fub.TCPSend.datalen := brsstrlen(ADR(internal.buffer.sendBuffer));
			internal.fub.TCPSend();
			IF internal.fub.TCPSend.status <> 16#FFFF THEN
				IF internal.fub.TCPSend.status = 0 THEN
					internal.control.mainStep := pushoverHTTP_RECV;
					internal.fub.TON_RecvTimeout.IN := TRUE;
					internal.fub.TON_RecvTimeout.PT := T#10s;
				ELSE
					internal.control.mainStep := pushoverHTTPERROR_AFTERTCPOPEN;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,internal.fub.TCPSend.status);
				END_IF
			END_IF
		
		pushoverHTTP_RECV:
			internal.fub.TCPRecv.enable := TRUE;
			internal.fub.TCPRecv.flags := 0;
			internal.fub.TCPRecv.ident := internal.fub.TCPOpenSSL.ident;
			internal.fub.TCPRecv.pData := ADR(internal.buffer.recvBuffer);
			internal.fub.TCPRecv.datamax := SIZEOF(internal.buffer.recvBuffer);
			internal.fub.TCPRecv();
			IF internal.fub.TCPRecv.status <> 16#FFFF THEN
				IF internal.fub.TCPRecv.status = 0 THEN
					// do not close directly after first receive if recvlen is 16#FFFFFFFF -> i don't know this state, but maybe it's informational / means -1?! There'S coming more after that
					IF internal.fub.TCPRecv.recvlen > 0 AND internal.fub.TCPRecv.recvlen <> 16#FFFFFFFF THEN
						// data received! Check for success or failure and close connection
						internal.control.mainStep := pushoverHTTP_CLOSE;
						brsmemcpy(ADR(internal.interface.msg_status),ADR(internal.buffer.recvBuffer) + brsstrlen(ADR('HTTP/1.1 ')), 3);
						IF brsmemcmp(ADR(internal.buffer.recvBuffer), ADR('HTTP/1.1 200'), brsstrlen(ADR('HTTP/1.1 200'))) = 0 THEN
							// ok, message was accepted by server
						ELSE
							// some error
							internal.interface.msg_error := TRUE;
						END_IF
					ELSE
						// timeout handling below
						
					END_IF
				ELSIF internal.fub.TCPRecv.status = tcpERR_NO_DATA THEN
					// timeout handling below
				ELSE
					internal.control.mainStep := pushoverHTTPERROR_AFTERTCPOPEN;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,internal.fub.TCPRecv.status);
				END_IF
				// cancelled by user (not implemented yet)
				IF internal.control.endReceive = TRUE THEN
					internal.control.endReceive := FALSE;
					internal.control.mainStep := pushoverHTTP_CLOSE;
				END_IF
				// cancelled by timeout
				IF internal.fub.TON_RecvTimeout.Q = TRUE THEN
					internal.interface.timeout := TRUE;
					internal.control.mainStep := pushoverHTTPERROR_AFTERTCPOPEN;
					internal.interface.status := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_ERROR,0,pusherrorRECVTIMEOUT);
				END_IF
			END_IF
		
		pushoverHTTP_CLOSE:
			internal.fub.TON_RecvTimeout.IN := FALSE;
			
			internal.fub.TCPClose.enable := TRUE;
			internal.fub.TCPClose.how := 0;
			internal.fub.TCPClose.ident := internal.fub.TCPOpenSSL.ident;
			internal.fub.TCPClose();
			IF internal.fub.TCPClose.status <> 16#FFFF THEN
				IF internal.fub.TCPClose.status = 0 THEN
					internal.control.mainStep := pushoverHTTP_NEXTSEND;
				ELSE
					internal.control.mainStep := pushoverHTTPERROR_AFTERTCPCLOSE;
				END_IF
			END_IF
		
		pushoverHTTP_NEXTSEND:
			internal.interface.busy := FALSE;
			IF internal.interface.error = FALSE THEN
				internal.interface.success := TRUE;
			END_IF
			IF internal.interface.send = FALSE THEN
				internal.control.mainStep := pushoverHTTP_IDLE;
			END_IF
		
		pushoverHTTPERROR_BEFORETCPOPEN:
			// imlement error handling
			internal.control.mainStep := pushoverHTTP_NEXTSEND;
			internal.interface.error := TRUE;
		
		pushoverHTTPERROR_AFTERTCPOPEN:
			// imlement error handling
			// close socket
			internal.control.mainStep := pushoverHTTP_CLOSE;
			internal.interface.error := TRUE;
		
		pushoverHTTPERROR_AFTERTCPCLOSE:
			// imlement error handling
			internal.control.mainStep := pushoverHTTP_NEXTSEND;
			internal.interface.error := TRUE;
		
	END_CASE
	
	internal.fub.TON_RecvTimeout();
	
	busy := internal.interface.busy;
	success := internal.interface.success;
	error := internal.interface.error;
	status := internal.interface.status;
	timeout := internal.interface.timeout;
	msg_error := internal.interface.msg_error;
	msg_status := internal.interface.msg_status;
	
END_FUNCTION_BLOCK
