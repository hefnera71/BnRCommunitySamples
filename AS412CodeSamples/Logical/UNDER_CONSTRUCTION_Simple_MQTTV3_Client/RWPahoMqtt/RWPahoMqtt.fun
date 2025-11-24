
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK RW_MQTT_ClientPub (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		I_xEnable : {REDUND_UNREPLICABLE} BOOL;
		I_xPublish : {REDUND_UNREPLICABLE} BOOL;
		I_typParameter : {REDUND_UNREPLICABLE} typRW_MQTT_Param;
		I_typPublish : {REDUND_UNREPLICABLE} typRW_MQTT_Publish;
	END_VAR
	VAR_OUTPUT
		Q_xConnected : {REDUND_UNREPLICABLE} BOOL;
		Q_uiState : {REDUND_UNREPLICABLE} UINT;
		Q_iPahoFcCallResult : {REDUND_UNREPLICABLE} INT;
	END_VAR
	VAR
		TcpOpen_0 : {REDUND_UNREPLICABLE} TcpOpen;
		TcpClient_0 : {REDUND_UNREPLICABLE} TcpClient;
		TcpRecv_0 : {REDUND_UNREPLICABLE} TcpRecv;
		TcpSend_0 : {REDUND_UNREPLICABLE} TcpSend;
		TcpClose_0 : {REDUND_UNREPLICABLE} TcpClose;
		uiState : {REDUND_UNREPLICABLE} UINT;
		buffer : {REDUND_UNREPLICABLE} ARRAY[0..16383] OF USINT;
		Internal : {REDUND_UNREPLICABLE} typRW_MQTT_Internal;
		TON_10ms_0 : {REDUND_UNREPLICABLE} TON_10ms;
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK RW_MQTT_ClientSub (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		I_xEnable : {REDUND_UNREPLICABLE} BOOL; (*1 = create connection to broker, 0 = end connection to broker*)
		I_xSubscribe : {REDUND_UNREPLICABLE} BOOL; (*1 = subcribe choosen topics, 0 = unsubscribe choosen topics*)
		I_typParameter : {REDUND_UNREPLICABLE} typRW_MQTT_Param; (*connection parameters*)
		I_typSubscribe : {REDUND_UNREPLICABLE} typRW_MQTT_Subscribe; (*subscription topics + parameters*)
	END_VAR
	VAR_OUTPUT
		Q_xConnected : {REDUND_UNREPLICABLE} BOOL; (*1 = connection established*)
		Q_uiState : {REDUND_UNREPLICABLE} UINT; (*internal state machine*)
		Q_iPahoFcCallResult : {REDUND_UNREPLICABLE} INT; (*internal state*)
	END_VAR
	VAR
		TcpOpen_0 : {REDUND_UNREPLICABLE} TcpOpen;
		TcpClient_0 : {REDUND_UNREPLICABLE} TcpClient;
		TcpRecv_0 : {REDUND_UNREPLICABLE} TcpRecv;
		TcpSend_0 : {REDUND_UNREPLICABLE} TcpSend;
		TcpClose_0 : {REDUND_UNREPLICABLE} TcpClose;
		uiState : {REDUND_UNREPLICABLE} UINT;
		buffer : {REDUND_UNREPLICABLE} ARRAY[0..16383] OF USINT;
		TON_10ms_0 : {REDUND_UNREPLICABLE} TON_10ms;
		uiStateNext : {REDUND_UNREPLICABLE} UINT;
		Internal : {REDUND_UNREPLICABLE} typRW_MQTT_Internal;
	END_VAR
END_FUNCTION_BLOCK
