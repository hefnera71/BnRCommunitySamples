
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK WebPingInterface (*Webservice "ping.cgi" to provide a web based interface for using PING on the PLC*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enables the whole webservice functionality*)
		enableIfStats : {REDUND_UNREPLICABLE} BOOL; (*enables the functionality of reading out and displaying ETH interface statistics*)
		ifStatsName : {REDUND_UNREPLICABLE} STRING[32]; (*default name of the ETH interface (can be changed inside the web interface)*)
	END_VAR
	VAR
		WsPing : {REDUND_UNREPLICABLE} WsPing_type; (*INTERNAL *)
		zzEdge00000 : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL *)
		zzEdge00001 : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL *)
		bExit : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL *)
		bInit : {REDUND_UNREPLICABLE} BOOL; (*INTERNAL *)
	END_VAR
END_FUNCTION_BLOCK
