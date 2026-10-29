(* Internal state of the EDFileIOHelper function block.
	   Managed exclusively by the state machine inside EDFileIOHelper.c. *)

TYPE
	EDFileIOHelperInternalType : 	STRUCT 
		fileOffset : UDINT; (* current file offset *)
		lastEnable : BOOL;
		fileInfo : fiFILE_INFO; (* file info result (size, timestamps, ...) *)
		FileCreate_0 : FileCreate; (* FB instance: create file *)
		FileOpen_0 : FileOpen; (* FB instance: open file *)
		FileRead_0 : FileRead; (* FB instance: read from file *)
		FileWrite_0 : FileWrite; (* FB instance: write to file *)
		FileClose_0 : FileClose; (* FB instance: close file *)
		FileDelete_0 : FileDelete; (* FB instance: delete file *)
		FileInfo_0 : FileInfo; (* FB instance: get file info *)
	END_STRUCT;
END_TYPE
