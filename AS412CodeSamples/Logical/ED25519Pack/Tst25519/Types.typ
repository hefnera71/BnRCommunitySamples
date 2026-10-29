
TYPE
	signedMessageType : 	STRUCT 
		sign : ARRAY[0..63]OF USINT;
		message : ARRAY[0..19]OF STRING[80];
	END_STRUCT;
END_TYPE
