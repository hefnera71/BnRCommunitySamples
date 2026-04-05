
TYPE
	TinyJsonLibValues_typ : {REDUND_UNREPLICABLE} 	STRUCT  (*destination array where results are stored in*)
		type : {REDUND_UNREPLICABLE} TinyJsonPropertyType_enum; (*type of JSON element*)
		key : {REDUND_UNREPLICABLE} STRING[32]; (*name of JSON element ... if ~[x], it's not the name but the array element index*)
		value : {REDUND_UNREPLICABLE} STRING[128]; (*value of the JSON element ... if ~OBJ or ~ARRAY, it's a complex type*)
		path : {REDUND_UNREPLICABLE} STRING[256]; (*element path inside the JSON object ... only valid if the complete object is dumped*)
		order : {REDUND_UNREPLICABLE} UINT; (*order number inside the JSON object ... only valid if the complete object is dumped*)
	END_STRUCT;
	TinyJsonPropertyType_enum : 
		( (*type of the JSON element*)
		tjJSON_OBJ,
		tjJSON_ARRAY,
		tjJSON_TEXT,
		tjJSON_BOOLEAN,
		tjJSON_INTEGER,
		tjJSON_REAL,
		tjJSON_NULL
		);
END_TYPE
