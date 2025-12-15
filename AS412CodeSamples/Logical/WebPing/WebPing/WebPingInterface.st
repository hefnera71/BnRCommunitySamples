
(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

(* Provide the ping webservice *)
FUNCTION_BLOCK WebPingInterface
	
	IF EDGENEG(enable) THEN
		bExit := TRUE;
		bInit := FALSE;
	END_IF
	
	IF EDGEPOS(enable) THEN
		IF bInit = FALSE THEN
			bInit := TRUE;
			WsPing.Control.eStep := WsPingINIT;
		ELSE
			WsPing.Control.eStep := WsPingIDLE;
		END_IF
	END_IF
	
	IF bExit THEN
		(* Unregister Webservice *)
		WsPing.FB.Webservice(enable := 0);
		bExit := FALSE;
	END_IF
	
	IF bInit AND NOT bExit THEN
		CASE WsPing.Control.eStep OF
			
			WsPingINIT:
				WsPing.FB.Webservice.pServiceName 		:= ADR('ping.cgi'); (* Name of webservice *)
				WsPing.FB.Webservice.option 			:= httpOPTION_HTTP_11 + httpOPTION_SERVICE_TYPE_NAME;
				WsPing.FB.Webservice.pRequestData		:= ADR(WsPing.Data.szRequest);
				WsPing.FB.Webservice.pRequestHeader		:= ADR(WsPing.Data.tRequestHeader);
				WsPing.FB.Webservice.pUri				:= ADR(WsPing.Data.szUri);
				WsPing.FB.Webservice.uriSize			:= SIZEOF(WsPing.Data.szUri);
	
				WsPing.FB.Webservice.pResponseData 		:= ADR(WsPing.Data.szResponse);
				WsPing.FB.Webservice.responseDataLen 	:= brsstrlen(ADR(WsPing.Data.szResponse));
				WsPing.FB.Webservice.pResponseHeader 	:= ADR(WsPing.Data.tResponseHeader);
	
				(* register webservice*)
				WsPing.FB.Webservice(enable := 1);
	
				// ETH interface where statistics should be read from
				IF enableIfStats = TRUE THEN
					IF ifStatsName = '' THEN
						WsPing.Data.szEthIfPRESET := 'IF2';
					ELSE
						WsPing.Data.szEthIfPRESET := ifStatsName;
					END_IF
				END_IF
				
				 WsPing.Control.eStep := WsPingIDLE;
				
				(* wait for new request *)
			WsPingIDLE:
				IF  WsPing.FB.Webservice.send = TRUE  THEN 
					WsPing.FB.Webservice.send := FALSE; (* Reset *)
				END_IF

				IF WsPing.FB.Webservice.status = ERR_OK AND  WsPing.FB.Webservice.phase = httpPHASE_RECEIVED  THEN
					WsPing.Control.eStep := WsPingGET_PARAMETER;
				END_IF
		
				(* read request variables *)
			WsPingGET_PARAMETER:
			
				brsstrcpy(ADR(WsPing.Data.szSdmAddress),ADR(WsPing.Data.tRequestHeader.host));
				brsstrcat(ADR(WsPing.Data.szSdmAddress),ADR('/sdm'));
			
				WsPing.Data.szTimeout := '1000';
				WsPing.FB.GetParamUrl.enable := TRUE;
				WsPing.FB.GetParamUrl.pSrc := ADR(WsPing.Data.szUri);
				WsPing.FB.GetParamUrl.pParam := ADR('timeout');
				WsPing.FB.GetParamUrl.pValue := ADR(WsPing.Data.szTimeout);
				WsPing.FB.GetParamUrl.valueSize := SIZEOF(WsPing.Data.szTimeout);
				WsPing.FB.GetParamUrl();

				WsPing.Data.szHost := '';
				WsPing.FB.GetParamUrl.enable := TRUE;
				WsPing.FB.GetParamUrl.pSrc := ADR(WsPing.Data.szUri);
				WsPing.FB.GetParamUrl.pParam := ADR('host');
				WsPing.FB.GetParamUrl.pValue := ADR(WsPing.Data.szHost);
				WsPing.FB.GetParamUrl.valueSize := SIZEOF(WsPing.Data.szHost);
				WsPing.FB.GetParamUrl();

				(* if no variables set, send initial html + js, else execute ping *)
				WsPing.Data.szResolve := '';
				WsPing.FB.GetParamUrl.enable := TRUE;
				WsPing.FB.GetParamUrl.pSrc := ADR(WsPing.Data.szUri);
				WsPing.FB.GetParamUrl.pParam := ADR('resolve');
				WsPing.FB.GetParamUrl.pValue := ADR(WsPing.Data.szResolve);
				WsPing.FB.GetParamUrl.valueSize := SIZEOF(WsPing.Data.szResolve);
				WsPing.FB.GetParamUrl();

				WsPing.Data.szEthStats := '';
				WsPing.FB.GetParamUrl.enable := TRUE;
				WsPing.FB.GetParamUrl.pSrc := ADR(WsPing.Data.szUri);
				WsPing.FB.GetParamUrl.pParam := ADR('ethstats');
				WsPing.FB.GetParamUrl.pValue := ADR(WsPing.Data.szEthStats);
				WsPing.FB.GetParamUrl.valueSize := SIZEOF(WsPing.Data.szEthStats);
				WsPing.FB.GetParamUrl();

				WsPing.Data.szEthIf := '';
				WsPing.FB.GetParamUrl.enable := TRUE;
				WsPing.FB.GetParamUrl.pSrc := ADR(WsPing.Data.szUri);
				WsPing.FB.GetParamUrl.pParam := ADR('ethif');
				WsPing.FB.GetParamUrl.pValue := ADR(WsPing.Data.szEthIf);
				WsPing.FB.GetParamUrl.valueSize := SIZEOF(WsPing.Data.szEthIf);
				WsPing.FB.GetParamUrl();
				IF WsPing.Data.szEthIf = '' THEN
					WsPing.Data.szEthIf := WsPing.Data.szEthIfPRESET;
				END_IF

				IF WsPing.Data.szHost <> '' THEN
					IF WsPing.Data.szResolve = '1' THEN
						WsPing.Control.eStep := WsPingGET_CONFIG;
					ELSE
						WsPing.Control.eStep := WsPingPREPARE_RESPONSE;
					END_IF
				ELSE
					IF WsPing.Data.szEthStats = '1' THEN
						WsPing.Control.eStep := WsPingREAD_ETHSTAT;
					ELSE
						(* first start - send html+js part as repsonse *)
						WsPing.Control.eStep := WsPingGET_DNSMODE;
					END_IF
				END_IF
		
			WsPingREAD_ETHSTAT:
				WsPing.FB.GetEthStat.enable := TRUE;
				WsPing.FB.GetEthStat.pDevice := ADR(WsPing.Data.szEthIf);
				WsPing.FB.GetEthStat.pStat := ADR(WsPing.Data.tEthStat);
				WsPing.FB.GetEthStat();
				IF WsPing.FB.GetEthStat.status <> 16#FFFF THEN
					WsPing.Control.eStep := WsPingREAD_ETHBD;
				END_IF

			WsPingREAD_ETHBD:
				WsPing.FB.GetEthBd.enable := TRUE;
				WsPing.FB.GetEthBd.pDevice := ADR(WsPing.Data.szEthIf);
				WsPing.FB.GetEthBd();
				IF WsPing.FB.GetEthBd.status <> 16#FFFF THEN
					IF WsPing.FB.GetEthBd.status = 0 THEN
						CASE WsPing.FB.GetEthBd.Baudrate OF
							cfgETHBAUDRATE_AUTO:
								WsPing.Data.szBaudrate := 'auto';
							cfgETHBAUDRATE_10:
								WsPing.Data.szBaudrate := '10 hd';
							cfgETHBAUDRATE_10FD:
								WsPing.Data.szBaudrate := '10 fd';
							cfgETHBAUDRATE_10AUTO:
								WsPing.Data.szBaudrate := '10 auto';
							cfgETHBAUDRATE_100:
								WsPing.Data.szBaudrate := '100 hd';
							cfgETHBAUDRATE_100FD:
								WsPing.Data.szBaudrate := '100 fd';
							cfgETHBAUDRATE_100AUTO:
								WsPing.Data.szBaudrate := '100 auto';
							cfgETHBAUDRATE_1000FD:
								WsPing.Data.szBaudrate := '1000 fd';
							ELSE
								WsPing.Data.szBaudrate := 'baudrate setting: ';
								WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.FB.GetEthBd.Baudrate);
								brsstrcat(ADR(WsPing.Data.szBaudrate),ADR(WsPing.Data.szTemp32));
						END_CASE
					ELSE
						WsPing.Data.szBaudrate := 'error reading baudrate setting: ';
						WsPing.Data.szTemp32 := UINT_TO_STRING(WsPing.FB.GetEthBd.status);
						brsstrcat(ADR(WsPing.Data.szBaudrate),ADR(WsPing.Data.szTemp32));
					END_IF
					WsPing.Control.eStep := WsPingREAD_ETHMAC;
				END_IF

			WsPingREAD_ETHMAC:
				WsPing.FB.GetEthMac.enable := TRUE;
				WsPing.FB.GetEthMac.pDevice := ADR(WsPing.Data.szEthIf);
				WsPing.FB.GetEthMac.pMacAddr := ADR(WsPing.Data.uaMacAddr);
				WsPing.FB.GetEthMac.Len := SIZEOF(WsPing.Data.uaMacAddr);
				WsPing.FB.GetEthMac();
				IF WsPing.FB.GetEthMac.status <> 16#FFFF THEN
					brsmemset(ADR(WsPing.Data.szMacAddr), 0, SIZEOF(WsPing.Data.szMacAddr));
					IF WsPing.FB.GetEthMac.status = 0 THEN
						FOR WsPing.Data.usI := 0 TO SIZEOF(WsPing.Data.uaMacAddr)-1 DO
							WsPing.Data.usUHB := WsPing.Data.uaMacAddr[WsPing.Data.usI] / 16;
							WsPing.Data.usLHB := WsPing.Data.uaMacAddr[WsPing.Data.usI] MOD 16;
							IF (WsPing.Data.usUHB > 9) THEN
								WsPing.Data.usCHR := 55 + WsPing.Data.usUHB;
							ELSE
								WsPing.Data.usCHR := 48 + WsPing.Data.usUHB;
							END_IF
							brsmemset(ADR(WsPing.Data.szMacAddr) + WsPing.Data.usI * 2, WsPing.Data.usCHR, 1);
							IF (WsPing.Data.usLHB > 9) THEN
								WsPing.Data.usCHR := 55 + WsPing.Data.usLHB;
							ELSE
								WsPing.Data.usCHR := 48 + WsPing.Data.usLHB;
							END_IF
							brsmemset(ADR(WsPing.Data.szMacAddr) + WsPing.Data.usI * 2 + 1, WsPing.Data.usCHR, 1);
						END_FOR
					ELSE
						WsPing.Data.szMacAddr := 'error reading mac addr: ';
						WsPing.Data.szTemp32 := UINT_TO_STRING(WsPing.FB.GetEthMac.status);
						brsstrcat(ADR(WsPing.Data.szMacAddr),ADR(WsPing.Data.szTemp32));
					END_IF
					WsPing.Control.eStep := WsPingSEND_ETHSTATS;
				END_IF

			WsPingGET_DNSMODE:
				(* check if dns is activated *)
				WsPing.Data.szDNS1 := '';
				WsPing.Data.szDNS2 := '';
				WsPing.Data.szDNS3 := '';
				WsPing.FB.GetDnsMode(enable := TRUE);
				IF WsPing.FB.GetDnsMode.status <> 16#FFFF THEN
					CASE WsPing.FB.GetDnsMode.mode OF
						cfgOPTION_DNS_OFF:
							WsPing.Data.szDnsMode := 'deactivated';	
							WsPing.Control.eStep := WsPingSEND_HTMLFORM;
							WsPing.Data.szHostnameOrIpAddr := 'no DNS';
						cfgOPTION_DNS_ON_CONFIG:
							WsPing.Data.szDnsMode := 'activated, set manually';	
							WsPing.Control.eStep := WsPingGET_DNSADDR;
						cfgOPTION_DNS_ON_DHCP:
							WsPing.Data.szDnsMode := 'activated, set by DHCP';	
							WsPing.Control.eStep := WsPingGET_DNSADDR;
					END_CASE
				END_IF

			WsPingGET_DNSADDR:
				(* get DNS addresses *)
				WsPing.FB.GetDnsAddress(enable := TRUE, pDnsAddr1 := ADR(WsPing.Data.szDNS1), pDnsAddr2 := ADR(WsPing.Data.szDNS2), pDnsAddr3 := ADR(WsPing.Data.szDNS3), Len1 := SIZEOF(WsPing.Data.szDNS1), Len2 := SIZEOF(WsPing.Data.szDNS2), Len3 := SIZEOF(WsPing.Data.szDNS3));
				IF WsPing.FB.GetDnsAddress.status <> 16#FFFF THEN
					WsPing.Control.eStep := WsPingSEND_HTMLFORM;
				END_IF
			
			WsPingGET_CONFIG:
				CASE WsPing.Control.eConfigStep OF
					
					(* check if it's a ip adress or a hostname *)
					WsPingCFG_CHECK_HOSTNAME:
						WsPing.Control.uiStatusInetAton := ethInetAton(ADR(WsPing.Data.szHost),ADR(WsPing.Data.udiIpAddr));
						IF WsPing.FB.GetDnsMode.mode > cfgOPTION_DNS_OFF THEN
							WsPing.Control.eConfigStep := WsPingCFG_RESOLVE_HOSTNAME;
						ELSE
							WsPing.Control.eConfigStep := WsPingCFG_GOON;
						END_IF

					WsPingCFG_RESOLVE_HOSTNAME:
						IF WsPing.Control.uiStatusInetAton = 0 THEN
							(* host = ip address *)
							WsPing.FB.GetHostByAddress(enable := TRUE, address := WsPing.Data.udiIpAddr, pName := ADR(WsPing.Data.szHostnameOrIpAddr), buflng := SIZEOF(WsPing.Data.szHostnameOrIpAddr));
							IF WsPing.FB.GetHostByAddress.status <> 16#FFFF THEN
								CASE WsPing.FB.GetHostByAddress.status OF
									ERR_OK:
										(* do nothing *)
									ERR_ASHOST_RESOLV_ADDR:
										WsPing.Data.szHostnameOrIpAddr := 'unable to resolve IP address';
									ELSE
										WsPing.Data.szHostnameOrIpAddr := '';
										brsitoa(WsPing.FB.GetHostByAddress.status, ADR(WsPing.Data.szHostnameOrIpAddr));
										brsstrcat(ADR(WsPing.Data.szHostnameOrIpAddr),ADR(' <- internal error from HostByAddress'));
								END_CASE
								WsPing.Control.eConfigStep := WsPingCFG_GOON;
							END_IF
						ELSE
							(* host is hostname *)
							WsPing.FB.GetHostByName(enable := TRUE, pName := ADR(WsPing.Data.szHost));
							IF WsPing.FB.GetHostByName.status <> 16#FFFF THEN
								CASE WsPing.FB.GetHostByName.status OF
									ERR_OK:
										ethInetNtoa(WsPing.FB.GetHostByName.address, ADR(WsPing.Data.szHostnameOrIpAddr));
									ERR_ASHOST_RESOLV_NAME:
										WsPing.Data.szHostnameOrIpAddr := 'unable to resolve host name';
									ELSE
										WsPing.Data.szHostnameOrIpAddr := '';
										brsitoa(WsPing.FB.GetHostByName.status, ADR(WsPing.Data.szHostnameOrIpAddr));
										brsstrcat(ADR(WsPing.Data.szHostnameOrIpAddr),ADR(' <- internal error from HostByName'));
								END_CASE
								WsPing.Control.eConfigStep := WsPingCFG_GOON;
							END_IF
						END_IF
					
					WsPingCFG_GOON:
						WsPing.Control.eStep := WsPingPREPARE_RESPONSE;
						WsPing.Control.eConfigStep := WsPingCFG_CHECK_HOSTNAME;
				
				END_CASE
			
				(* do ping, and prepare response data *)
			WsPingPREPARE_RESPONSE:
				WsPing.Data.szError := '';
			
				IF (WsPing.Data.szHost <> '') THEN
					WsPing.Data.uiTimeout := DINT_TO_UINT(brsatoi(ADR(WsPing.Data.szTimeout))) / 10;
			
					(* call ping FB *)
					WsPing.FB.Ping(enable := TRUE, pHost := ADR(WsPing.Data.szHost), timeout := WsPing.Data.uiTimeout);
					IF WsPing.FB.Ping.status <> 16#FFFF THEN
						WsPing.Control.eStep := WsPingSEND_RESPONSE;
						brsitoa(WsPing.FB.Ping.status, ADR(WsPing.Data.szError));
						CASE WsPing.FB.Ping.status OF 
							0:
								WsPing.Data.szErrDesc := 'SUCCESS';
							icmpERR_NO_RESPONSE:
								WsPing.Data.szErrDesc := 'response timeout';
							icmpERR_UNREACHABLE:
								WsPing.Data.szErrDesc := 'host unreachable';
							icmpERR_PARAMETER:
								WsPing.Data.szErrDesc := 'invalid parameters, ip address complete? dns activated and reachable?';
							icmpERR_SOCKET_CREATE:
								WsPing.Data.szErrDesc := 'create socket failed';
							icmpERR_SYSTEM:
								WsPing.Data.szErrDesc := 'internal system error';
							ELSE
								WsPing.Data.szErrDesc := 'unknown FB error, check AS help!';
						END_CASE						
						WsPing.Control.eStep := WsPingSEND_RESPONSE;
					ELSE
						// busy, wait....
					END_IF	
				ELSE
					WsPing.Data.szErrDesc := 'no host defined';
					WsPing.Data.szError := '1';
					WsPing.Control.eStep := WsPingSEND_RESPONSE;
				END_IF

				(* send the ping result response *)
			WsPingSEND_RESPONSE:			
				WsPing.Data.szResponse := '';
			
				IF WsPing.FB.Ping.status = 0 THEN
					WsPing.Data.szTemp32 := 'color: green;';
				ELSE
					WsPing.Data.szTemp32 := 'color: red;';
				END_IF
			
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('<span style="'));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('">'));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('Ping: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szErrDesc));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('</span>'));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(' (FB status: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szError));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(')'));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(', host: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szHost));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(', dns resolve: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szHostnameOrIpAddr));
			
				WsPing.Data.tResponseHeader.contentType := 'text/html';
				WsPing.FB.Webservice.responseDataLen := brsstrlen(ADR(WsPing.Data.szResponse));
				WsPing.FB.Webservice.send := TRUE; (* Send on positive edge*)
				WsPing.Control.eStep := WsPingIDLE;

		
			WsPingSEND_ETHSTATS:

				WsPing.Data.szResponse := '';
			
				IF WsPing.FB.GetEthStat.status = 0 THEN			
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					<br />
					<table>
					<tr>
					<td>Interface</td>
					<td>'));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szEthIf));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>MAC address</td>
					<td>'));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szMacAddr));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>baud rate setting</td>
					<td>'));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szBaudrate));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Received bytes</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.bytesrecv);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Sent bytes</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.bytessend);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Received packets</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.packetsrecv);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Sent packets</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.packetssend);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td> Received multicast packets</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.mcpacketsrecv);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Sent multicast packets</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.mcpacketssend);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Receive error</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.errorrecv);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Send error</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.errorsend);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Collisions</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.collisions);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>Dropped at input</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.drops);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					<tr>
					<td>No protocol</td>
					<td>'));
					WsPing.Data.szTemp32 := UDINT_TO_STRING(WsPing.Data.tEthStat.noproto);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					</td>
					</tr>
					</table>'));
				ELSE
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('no ethernet interface statistics available - fb status '));
					WsPing.Data.szTemp32 := UINT_TO_STRING(WsPing.FB.GetEthStat.status);
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szTemp32));
				END_IF
				WsPing.Data.tResponseHeader.contentType := 'text/html';
				WsPing.FB.Webservice.responseDataLen := brsstrlen(ADR(WsPing.Data.szResponse));
				WsPing.FB.Webservice.send := TRUE; (* Send on positive edge*)
				WsPing.Control.eStep := WsPingIDLE;
			
				(* send the initial data for diplaying web interface *)
			WsPingSEND_HTMLFORM:
				WsPing.Data.szResponse := '
				<html>
				<head>
				<script>

				var run = false;

				function GetPing(host, timeout, interval, resolve) {
				if (host.length > 0)
				{
				var url = "ping.cgi?host=" + host + "&timeout=" + timeout + "&resolve=" + resolve;
				var xmlhttp = new XMLHttpRequest();
				xmlhttp.onreadystatechange = function()
				{
				if (this.readyState == 4 && this.status == 200)
				{
				AddPing(this.responseText);
				if (run)
				{
				setTimeout(function(){GetPing(host, timeout, interval, "0");},interval);
				var state = document.getElementById("state");
				state.innerHTML = "running";
				}
				else
				{
				var state = document.getElementById("state");
				state.innerHTML = "stopped";
				}
				}
				};
				xmlhttp.open("GET", url, true);
				xmlhttp.send();
				}
				else
				{
				var state = document.getElementById("state");
				state.innerHTML = "error: no host";
				}
				}
	
				function ReadEthStats(ethif) {
				var url = "ping.cgi?ethstats=1&ethif=" + ethif;
				var xmlhttp2 = new XMLHttpRequest();
				xmlhttp2.onreadystatechange = function()
				{
				if (this.readyState == 4 && this.status == 200)
				{
				AddEthStats(this.responseText);
				}
				};
				xmlhttp2.open("GET", url, true);
				xmlhttp2.send();
				}

				function AddEthStats(text) {
				var ethstats = document.getElementById("ethstats");
				ethstats.innerHTML = text;
				}

				function AddPing(text) {
				var output = document.getElementById("output");
				var d = new Date();
				output.innerHTML = d.toLocaleTimeString() +": " + text + "<br>" + output.innerHTML;
				}

				function StopPing() {
				if (run == true)
				{
				run = false;
				var state = document.getElementById("state");
				state.innerHTML = "stopping...";
				}
				}

				function StartPing(host, timeout, interval) {
				if (run == false)
				{
				run = true;
				var output = document.getElementById("output");
				output.innerHTML = "";
				var state = document.getElementById("state");
				state.innerHTML = "starting...";
				GetPing(host, timeout, interval, "1");
				}
				}
			
				function GetEthStats(ifname)
				{
				var ethstats = document.getElementById("ethstats");
				ethstats.innerHTML = "";
				ReadEthStats(ifname);				
				}

				</script>

				<style>
				html { margin:0; padding:0; font-size:100%; font-family: verdana;}
				table { padding:10px; font-size:80%;}
				div { border-style: solid; border-width: 1px; }
				</style>
				
				</head>
				<body>
				<table>
				<tr>
				<td>PLC info</td><td><a href="/sdm">System Diagnostics Manager</a></td>
				</tr><tr>
				<td style="vertical-align: top;">DNS configuration</td>
				<td style="vertical-align: top;"><i>';
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szDnsMode));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('<br />DNS1: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szDNS1));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('<br />DNS2: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szDNS2));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('<br />DNS3: '));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szDNS3));
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('
				</i></td>
				</tr><tr>
				<td>Ping interface</td><td></td>
				</tr><tr>
				<td>target</td>
				<td><input type="text" name="host" id="host" maxlength="128" placeholder="set IP addr. or hostname..."></td>
				</tr><tr>
				<td>timeout (ms)</td>
				<td><input type="number" name="timeout" id="timeout" min="100" max="9999" value="1000"></td>
				</tr><tr>
				<td>interval (ms)</dr>
				<td><input type="number" name="interval" id="interval"  min="100" max="9999" value="1000"></td>
				</tr><tr>
				<td><button type="button" onclick="StartPing(host.value, timeout.value, interval.value)">start</button></td>
				<td></td>
				</tr><tr>
				<td><button type="button" onclick="StopPing()">stop</button></td>
				<td id="state">stopped</td>
				</tr>
				</table>
				<br />Ping Result:<br /><br />
				<div id="output" style="height: 200px; overflow-y: scroll;"></div>
				<br /><br />'));
				
				IF enableIfStats = TRUE THEN
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					<button type="button" onclick="GetEthStats(ethif.value)">Get Interface Info</button>
					<input type="text" name="ethif" id="ethif" maxlength="32" value="'));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR(WsPing.Data.szEthIf));
					brsstrcat(ADR(WsPing.Data.szResponse),ADR('
					">
					<br /><br />
					<div id="ethstats" style="height: 200px; overflow-y: scroll;"></div>'));
				END_IF
				
				brsstrcat(ADR(WsPing.Data.szResponse),ADR('
				</body>
				</html>'));

				WsPing.Data.tResponseHeader.contentType := 'text/html';
				WsPing.FB.Webservice.responseDataLen := brsstrlen(ADR(WsPing.Data.szResponse));

				WsPing.FB.Webservice.send := TRUE; (* Send on positive edge*)
				WsPing.Control.eStep := WsPingIDLE;
		
		END_CASE
	
		(* execute the webservice *)
		WsPing.FB.Webservice();

		
	END_IF
			
END_FUNCTION_BLOCK
