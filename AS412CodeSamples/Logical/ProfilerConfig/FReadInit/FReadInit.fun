
FUNCTION_BLOCK ReadFile_INIT
	VAR_INPUT
		sDevice : STRING[80];
		sFile : STRING[80];
		pBuffer : UDINT;
		bufferSize : UDINT;
	END_VAR
	VAR_OUTPUT
		status : UINT;
	END_VAR
	VAR
		FileClose_0 : FileClose;
		FileInfo_0 : FileInfo;
		FileOpen_0 : FileOpen;
		FileRead_0 : FileRead;
		fInfo : fiFILE_INFO;
		uFileError : UINT;
	END_VAR
END_FUNCTION_BLOCK
