
TYPE
	PushHTTPMessage_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		uri : {REDUND_UNREPLICABLE} STRING[255];
		header : {REDUND_UNREPLICABLE} PushHTTPHeader_type;
		content : {REDUND_UNREPLICABLE} STRING[1023];
	END_STRUCT;
	PushHTTPHeader_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		url : {REDUND_UNREPLICABLE} STRING[255];
		userAgent : {REDUND_UNREPLICABLE} STRING[127];
		host : {REDUND_UNREPLICABLE} STRING[127];
		accept : {REDUND_UNREPLICABLE} STRING[127];
		contentType : {REDUND_UNREPLICABLE} STRING[127];
		contentLength : {REDUND_UNREPLICABLE} STRING[127];
		endOfHeader : {REDUND_UNREPLICABLE} STRING[4];
	END_STRUCT;
	PushLibInstance_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		interface : {REDUND_UNREPLICABLE} PushLibInterface_type;
		http : {REDUND_UNREPLICABLE} PushHTTPMessage_type;
		fub : {REDUND_UNREPLICABLE} PushLibInstanceFUB_type;
		control : {REDUND_UNREPLICABLE} PushLibControl_type;
		buffer : {REDUND_UNREPLICABLE} PushLibBuffers_type;
	END_STRUCT;
	PushLibInterface_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		message : {REDUND_UNREPLICABLE} PushMessageInterface_type;
		send : {REDUND_UNREPLICABLE} BOOL;
		busy : {REDUND_UNREPLICABLE} BOOL;
		success : {REDUND_UNREPLICABLE} BOOL;
		error : {REDUND_UNREPLICABLE} BOOL;
		status : {REDUND_UNREPLICABLE} DINT;
		timeout : {REDUND_UNREPLICABLE} BOOL;
		msg_error : {REDUND_UNREPLICABLE} BOOL;
		msg_status : {REDUND_UNREPLICABLE} STRING[10];
	END_STRUCT;
	PushMessagePriority_type : {REDUND_UNREPLICABLE} 	STRUCT  (*message priority settings*)
		flag : {REDUND_UNREPLICABLE} SINT; (*priority flag, see constants pushprioXXX and pushover api documentation*)
		retryMinutes : {REDUND_UNREPLICABLE} USINT; (*if priority flag is set to EMERGENCY, this parameter is mandatory: every x minutes the message is pushed again until acknowledge*)
		expireMinutes : {REDUND_UNREPLICABLE} USINT; (*if priority flag is set to EMERGENCY, this parameter is mandatory: after x minutes the message send retry is stopped, and the message is marked as expired*)
	END_STRUCT;
	PushMessageSupplementaryUrl_type : {REDUND_UNREPLICABLE} 	STRUCT  (*message supplementary url settings*)
		url : {REDUND_UNREPLICABLE} STRING[127]; (*url to point to*)
		title : {REDUND_UNREPLICABLE} STRING[63]; (*url title shown inside the message*)
	END_STRUCT;
	PushLibInstanceFUB_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		TCPOpenSSL : {REDUND_UNREPLICABLE} TcpOpenSsl;
		TCPClient : {REDUND_UNREPLICABLE} TcpClient;
		TCPSend : {REDUND_UNREPLICABLE} TcpSend;
		TCPRecv : {REDUND_UNREPLICABLE} TcpRecv;
		TCPClose : {REDUND_UNREPLICABLE} TcpClose;
		HTTPSetParamUrl : {REDUND_UNREPLICABLE} httpSetParamUrl;
		HTTPWStringToUTF8 : {REDUND_UNREPLICABLE} httpWStringToUtf8;
		TON_RecvTimeout : {REDUND_UNREPLICABLE} TON;
	END_STRUCT;
	PushLibControl_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		mainStep : {REDUND_UNREPLICABLE} UINT;
		endReceive : {REDUND_UNREPLICABLE} BOOL;
		debug : {REDUND_UNREPLICABLE} BOOL;
		wrongParameter : {REDUND_UNREPLICABLE} BOOL;
	END_STRUCT;
	PushLibBuffers_type : {REDUND_UNREPLICABLE} 	STRUCT  (*INTERNAL*)
		sendBuffer : {REDUND_UNREPLICABLE} STRING[2047];
		tempString : {REDUND_UNREPLICABLE} STRING[2047];
		recvBuffer : {REDUND_UNREPLICABLE} ARRAY[0..25]OF STRING[70];
		tempWString : {REDUND_UNREPLICABLE} WSTRING[2047];
	END_STRUCT;
END_TYPE
