
{REDUND_CONTEXT} FUNCTION_BLOCK ReadEvLogEntries (*this FB uses SYNCHRONOUS calls only!! Reads out data from logger EXCEPT OF the description text (because reading desc is asynchronous) ... can also be used for blockwise reading, block size depends on result array size... the user is responsible to clear the result storage before the FB restarts (if wanted / needed, to avoid having old data inside)!*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		loggerName : STRING[256]; (*name of logger module*)
		pResultData : UDINT; (*pointer to array of result data structure = array of ReadEvLog_Entry_type*)
		resultDataSize : UDINT; (*size of the result data structure - the FB internally calculates the array size*)
		recordIdStart : ArEventLogRecordIDType; (*0 = start reading with latest record id (normally that's what we want!), <> 0 start with specific record id*)
		useReadFilter : BOOL; (*if TRUE, the filter definition from readFilterSetup is used, only entries matching the filter are returned into the result array*)
		readFilterSetup : ReadEvLog_Filter_type; (*definition of the filter to use*)
		execute : BOOL; (*start reading*)
		next : BOOL; (*if more entries are in the logger, use this to read read the the next block -> execute has to stay true when using next !!!*)
	END_VAR
	VAR_OUTPUT
		busy : BOOL; (* FB is working*)
		more : BOOL; (* the're more entries inside the logger*)
		done : BOOL; (* all entries are read (if more = FALSE), or result data array is full*)
		error : BOOL; (*a error happened, FB stopped working*)
		statusID : DINT; (*the id in case of an error*)
		numberOfEntriesRead : UDINT; (*the WHOLE number of RESULT entries read (also keeps increasing when using "next")*)
		numberOfEntriesProcessed : UDINT; (*the WHOLE number of READ entries per FB call (also includes read logger entries, that were not copied because of filter settings)*)
		severityCounters : ReadEvLog_Counters_type; (*counts the severity types of all entries read*)
	END_VAR
	VAR
		Internal : ReadEvLog_Internal_type; (*internal*)
		refResultEntry : REFERENCE TO ReadEvLog_Entry_type; (*internal*)
		zzEdge00000 : BOOL; (*internal*)
		zzEdge00001 : BOOL; (*internal*)
		zzEdge00002 : BOOL; (*internal*)
	END_VAR
END_FUNCTION_BLOCK

{REDUND_CONTEXT} FUNCTION_BLOCK ReadEvLogEventDescription (*EXTENSION for ReadEvLogEntries, has to be user AFTER the call of ReadEvLogEntries .... Works ASYNCHRONOUS, can be used to get the event id description texts*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		loggerName : STRING[256]; (*name of the logger module, has to be the same then used with ReadEvLogEntries*)
		languageCode : ArEventLogLanguageCodeType; (*language code for the result texts, like 'de' for german texts*)
		pResultData : UDINT; (*pointer to array of result data structure = array of ReadEvLog_Entry_type*)
		resultDataSize : UDINT; (*the number of entries to compute in the result data array*)
		nrOfReadDescFBInsts : USINT; (*the number of instances of ArEventLogReadDescriptions instances to use internally ... could be used for faster processing, but also needs higher performance*)
		execute : BOOL; (*execute FB*)
	END_VAR
	VAR_OUTPUT
		busy : BOOL; (* FB is working*)
		done : BOOL; (* all entries are read (if more = FALSE), or result data array is full*)
		error : BOOL; (*a error happened, FB stopped working*)
		statusID : DINT; (*the id in case of an error*)
		numberOfDescriptionsRead : UDINT; (*the WHOLE number of entries read (also keeps increasing when using "next"*)
	END_VAR
	VAR
		Internal : ReadEvLog_InternalDesc_type; (*internal*)
		refResultEntry : REFERENCE TO ReadEvLog_Entry_type; (*internal*)
		refArEvLogReadDesc : REFERENCE TO ArEventLogReadDescription; (*internal*)
		zzEdge00000 : BOOL; (*internal*)
		zzEdge00001 : BOOL; (*internal*)
	END_VAR
END_FUNCTION_BLOCK
