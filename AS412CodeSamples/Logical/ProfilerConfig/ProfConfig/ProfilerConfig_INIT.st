(*
// Copyright (c) 2025 Alexander Hefner
// 
// Licensed under the MIT License - see LICENSE.txt file for details
*)

FUNCTION_BLOCK ProfilerConfig_INIT

	status := 16#FFFF;
	
	// ------------------------------------------------------------------------------------------------------------------
	// Configuration of profiler
	// put this code into the _INIT program of the first task inside the first task class used
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// !!!! ONLY FOR USE INSIDE _INIT PROGRAM !!!! because of REPEAT...UNTIL
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// needs AsMem, AsArProf, ArEventLog, SYS_lib, AsBrStr, NamValPars, FReadInit

	
	IF RTInit() = TRUE THEN
		
		// define some name if getting task name fails ...
		TaskName := 'usertask';
		// try to get the name of the calling task ...
		ST_name(0, ADR(TaskName), ADR(TaskGroup));
		
		// get the ident to the logger (here: user logger -> system loggers can't be used!)		
		ArEventLogGetIdent_0(Execute := TRUE, Name := '$$arlogusr');
		
		// allocate file memory of around 32kByte
		REPEAT
			AsMemPartCreate_0(enable := TRUE, len := 32768 + 256);
			UNTIL AsMemPartCreate_0.status <> 16#FFFF
		END_REPEAT
		
		IF AsMemPartCreate_0.status = 0 THEN
			AsMemPartAlloc_0(enable := TRUE, ident := AsMemPartCreate_0.ident, len := 32768);
			IF AsMemPartAlloc_0.status <> 0 THEN
				// if error set my fb status to this
				status := AsMemPartAlloc_0.status;
			END_IF
		ELSE
			// if error set my fb status to this
			status := AsMemPartCreate_0.status;
		END_IF
			
		IF AsMemPartCreate_0.status = 0 AND AsMemPartAlloc_0.status = 0 THEN
			// read the configuration file
			ReadFile_INIT_0(sDevice := sDevice, sFile := sFile, pBuffer := AsMemPartAlloc_0.mem, bufferSize := AsMemPartAlloc_0.len);
			// if error set my fb status to this
			status := ReadFile_INIT_0.status;
		END_IF
		
		// the whole following stuff is only done when file reading was okay....
		// ... or user has configured to go on with defaults from above, if file had problems
		IF status = 0 OR bExecuteIfFileNotFound = TRUE THEN
		
			IF status = 0 THEN
				// GET THE WANTED CONFIG - parse the file if mem was ok and the file was found 
				// parse the config file using CfgFParser --> awaiting a file format with <name>=<value> #comment ... no empty lines, no special chars, ...
				ParseForNameValueTuples_0(pContentToParse := ADR(uFileBuffer), contentLength := brsstrlen(ADR(uFileBuffer)));
				IF ParseForNameValueTuples_0.status = 0 THEN
					uParseUnkownParam := 0;
					// CONFIGURE THE PROFILER - check and set parameters
					// prepare for lib function profiling
					pNext := pStart := ADR(usLibFcs);
					// set the suitable profiler config struct element
					ProfilerConfigStruct.pLibFunctions := ADR(usLibFcs);
					// check parameters and set profiler config elements
					FOR uParamArray := 0 TO SIZEOF(ParseForNameValueTuples_0.sOutput)/SIZEOF(ParseForNameValueTuples_0.sOutput[0]) -1 DO
						IF ParseForNameValueTuples_0.sOutput[uParamArray].Name = '' THEN
							// first empty param means, nothing more is coming, because empty lines are not allowed!
							EXIT;
						ELSE
							IF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'logGroup' THEN
								ProfilerConfigStruct.logGroup := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'logMode' THEN
								ProfilerConfigStruct.logMode := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'archMode' THEN
								ProfilerConfigStruct.archMode := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'memTypeDef' THEN
								ProfilerConfigStruct.memTypeDef := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'memTypeDat' THEN
								ProfilerConfigStruct.memTypeDat := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'backupLevel' THEN
								ProfilerConfigStruct.backupLevel := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'bufferSize' THEN
								ProfilerConfigStruct.bufferSize := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'addDataSize' THEN
								ProfilerConfigStruct.addDataSize := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'addOsTskCnt' THEN
								ProfilerConfigStruct.addOsTskCnt := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'pArchDevice' THEN
								ProfilerConfigStruct.pArchDevice := ADR(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'libFctCnt' THEN
								// this setting could also be set automatically by counting 'libfc's, but I won't do this right now
								ProfilerConfigStruct.libFctCnt := STRING_TO_UDINT(ParseForNameValueTuples_0.sOutput[uParamArray].Value);
							ELSIF ParseForNameValueTuples_0.sOutput[uParamArray].Name = 'libfc' THEN
								IF ParseForNameValueTuples_0.sOutput[uParamArray].Value <> '' THEN
									IF (pNext + brsstrlen(ADR(ParseForNameValueTuples_0.sOutput[uParamArray].Value))) - pStart < SIZEOF(usLibFcs) THEN
										// move the functions names into the needed fc name buffer
										pNext := brsmemcpy(pNext,ADR(ParseForNameValueTuples_0.sOutput[uParamArray].Value), brsstrlen(ADR(ParseForNameValueTuples_0.sOutput[uParamArray].Value)));
										pNext := brsmemset(pNext,0, 1);
									ELSE
										// too much libraries, internal buffer too small!!
										status := profconfigERROR_LIBBUFFER;
									END_IF
								END_IF
							ELSE
								// unknown parameter, skip
								uParseUnkownParam := uParseUnkownParam + 1;
							END_IF
						END_IF
						
					END_FOR
				END_IF
				
			ELSE	
				// parsing cannot be performed because of some problem with configuration file, or because no file existing
				// but we can go on with manual configuration provided by the fb call
			END_IF

			
			// SETUP THE PROFILER
			// first: stop a possibly running (standard) profiler
			REPEAT
				LogStop_0(enable := TRUE);
				LogStop_0();
				UNTIL LogStop_0.status <> ERR_FUB_BUSY
			END_REPEAT
		
			// second: deinstall a possibly existing (standard) profiler configuration
			REPEAT
				LogDeInstall_0.enable := TRUE;
				LogDeInstall_0.option := 0;
				LogDeInstall_0();
				UNTIL LogDeInstall_0.status <> ERR_FUB_BUSY
			END_REPEAT
				
			// third: install the profiler with the configuration from above
			REPEAT
				LogInstall_0.enable := TRUE;
				LogInstall_0.pVersion := 0;
				LogInstall_0.pDefinition := ADR(ProfilerConfigStruct);
				LogInstall_0();
				UNTIL LogInstall_0.status <> ERR_FUB_BUSY
			END_REPEAT
		
			// forth: start the profiler
			REPEAT
				LogStart_0(enable := TRUE);
				LogStart_0();
				UNTIL LogStart_0.status <> ERR_FUB_BUSY
			END_REPEAT
				
			// fifth: read the profiler state
			REPEAT
				LogStateGet_0(enable := TRUE);
				LogStateGet_0();
				UNTIL LogStateGet_0.status <> ERR_FUB_BUSY
			END_REPEAT
		
						
			// and now, as hint that the profiler was (re-)configured via software, create a logger entry
	
			// create some additional information for logger entry
			AdditionalDataString := 'Profiler config was changed by task using AsArProf, LogStateGet.logstate=';
			brsitoa(LogStateGet_0.logstate, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' ... FB states are: LogStop='));
			brsitoa(LogStop_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' LogDeInstall='));
			brsitoa(LogDeInstall_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' LogInstall='));
			brsitoa(LogInstall_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' LogStart='));
			brsitoa(LogStart_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' LogStateGet='));
			brsitoa(LogStateGet_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			
			// create the logger entry for AsArProf run
			ArEventLogWrite_0.Execute := TRUE;
			ArEventLogWrite_0.Ident := ArEventLogGetIdent_0.Ident;
			ArEventLogWrite_0.EventID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_INFO, 15, LogStateGet_0.logstate);
			ArEventLogWrite_0.OriginRecordID := 0;
			ArEventLogWrite_0.AddDataSize := brsstrlen(ADR(AdditionalDataString)) + 1;
			ArEventLogWrite_0.AddDataFormat := arEVENTLOG_ADDFORMAT_TEXT;
			ArEventLogWrite_0.AddData := ADR(AdditionalDataString);
			ArEventLogWrite_0.ObjectID := TaskName;
			ArEventLogWrite_0.TimeStamp := 0;
			ArEventLogWrite_0();
			ArEventLogWrite_0(Execute := FALSE);
			
			// create the logger string for file based configuration
			AdditionalDataString := 'Profiler config setup from file reported file read status=';
			brsitoa(ReadFile_INIT_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' config parser status='));
			brsitoa(ParseForNameValueTuples_0.status, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' unexpected characters='));
			brsitoa(ParseForNameValueTuples_0.uParseUnwantedChar, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(' unknown parameters='));
			brsitoa(uParseUnkownParam, ADR(ProfilerStatus));
			brsstrcat(ADR(AdditionalDataString), ADR(ProfilerStatus));
		
			// create the logger entry for file and parse run
			ArEventLogWrite_0.Execute := TRUE;
			ArEventLogWrite_0.Ident := ArEventLogGetIdent_0.Ident;
			ArEventLogWrite_0.EventID := ArEventLogMakeEventID(arEVENTLOG_SEVERITY_INFO, 15, ReadFile_INIT_0.status);
			ArEventLogWrite_0.OriginRecordID := 0;
			ArEventLogWrite_0.AddDataSize := brsstrlen(ADR(AdditionalDataString)) + 1;
			ArEventLogWrite_0.AddDataFormat := arEVENTLOG_ADDFORMAT_TEXT;
			ArEventLogWrite_0.AddData := ADR(AdditionalDataString);
			ArEventLogWrite_0.ObjectID := TaskName;
			ArEventLogWrite_0.TimeStamp := 0;
			ArEventLogWrite_0();
			ArEventLogWrite_0(Execute := FALSE);
	
			ArEventLogGetIdent_0(Execute := FALSE);
			
		END_IF	
		
		IF AsMemPartCreate_0.status = 0 THEN
			AsMemPartDestroy_0(enable := TRUE, ident := AsMemPartCreate_0.ident);
		END_IF
		
	ELSE
		status := profconfigERROR_NOTININIT;		
	END_IF // if RTInit() ...
	
	

END_FUNCTION_BLOCK