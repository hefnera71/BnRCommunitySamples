
TYPE
	shaTestDatasetSmall_typ : 	STRUCT 
		tsDiff : DINT;
		in : ARRAY[0..63]OF USINT;
		hash : STRING[64];
	END_STRUCT;
	shaTestDatasetMid_typ : 	STRUCT 
		tsDiff : DINT;
		in : ARRAY[0..4095]OF USINT;
		hash : STRING[64];
	END_STRUCT;
	shaTestDatasetLarge_typ : 	STRUCT 
		tsDiff : DINT;
		in : ARRAY[0..1048575]OF USINT;
		hash : STRING[64];
	END_STRUCT;
	shaTestData : 	STRUCT 
		data_64Byte : shaTestDatasetSmall_typ;
		data_4kB : shaTestDatasetMid_typ;
		data_1MB : shaTestDatasetLarge_typ;
	END_STRUCT;
END_TYPE
