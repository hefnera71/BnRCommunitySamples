
TYPE
	PushMessageInterface_type : 	STRUCT 
		userKey : STRING[32]; (*the pushover api user or group key to send messages to*)
		applicationKey : STRING[32]; (*the pushover api application key, messages are send from*)
		device : STRING[63]; (*optional: name of pushover devices the message should be send to (if empty, all devices from the user or group are used)*)
		wsTitle : WSTRING[63]; (*message title*)
		wsContent : WSTRING[511]; (*message content*)
		priority : PushMessagePriority_type; (*message priority settings*)
		supplUrl : PushMessageSupplementaryUrl_type; (*message supplementary url*)
	END_STRUCT;
END_TYPE
