
{REDUND_UNREPLICABLE} FUNCTION_BLOCK PushoverSendMessage (*send a push message via httsp://pushover.net*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		MessageParameters : {REDUND_UNREPLICABLE} PushMessageInterface_type; (*all message parameters like headline, text, priority a.s.o.*)
		send : {REDUND_UNREPLICABLE} BOOL; (*true = send message to api server*)
	END_VAR
	VAR_OUTPUT
		busy : {REDUND_UNREPLICABLE} BOOL; (*if true, internal state machine is working*)
		success : {REDUND_UNREPLICABLE} BOOL; (*if true, message sending successful*)
		error : {REDUND_UNREPLICABLE} BOOL; (*if true, error happened while sending message*)
		status : {REDUND_UNREPLICABLE} DINT; (*internal state machine error (using new AR state format)*)
		timeout : {REDUND_UNREPLICABLE} BOOL; (*if true, communication timeout with server happened*)
		msg_error : {REDUND_UNREPLICABLE} BOOL; (*if true, error was responded from message server*)
		msg_status : {REDUND_UNREPLICABLE} STRING[10]; (*message server error (http state code, see pushover.net api documentation)*)
	END_VAR
	VAR
		internal : {REDUND_UNREPLICABLE} PushLibInstance_type; (*internal instance variables*)
	END_VAR
END_FUNCTION_BLOCK
