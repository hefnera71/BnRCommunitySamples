
TYPE
	xteaTestDatasetSmall_typ : 	STRUCT 
		tsDiff : DINT;
		in : ARRAY[0..63]OF USINT;
		out : ARRAY[0..63]OF USINT;
	END_STRUCT;
	xteaTestDatasetMid_typ : 	STRUCT 
		tsDiff : DINT;
		in : ARRAY[0..4095]OF USINT;
		out : ARRAY[0..4095]OF USINT;
	END_STRUCT;
	xteaTestDatasetLarge_typ : 	STRUCT 
		tsDiff : DINT;
		in : ARRAY[0..1048575]OF USINT;
		out : ARRAY[0..1048575]OF USINT;
	END_STRUCT;
	xteaTestData : 	STRUCT 
		data_64Byte : xteaTestDatasetSmall_typ;
		data_4kB : xteaTestDatasetMid_typ;
		data_1MB : xteaTestDatasetLarge_typ;
	END_STRUCT;
END_TYPE
