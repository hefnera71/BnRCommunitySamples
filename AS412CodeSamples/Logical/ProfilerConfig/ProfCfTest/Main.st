
PROGRAM _INIT
	// ------------------------------------------------------------------------------------------------------------------
	// Configuration of profiler
	// put this code into the _INIT program of the first task inside the first task class used
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// !!!! ONLY FOR USE INSIDE _INIT PROGRAM !!!! because of REPEAT...UNTIL
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// needs AsArProf, ArEventLog, SYS_lib, BRsystem, AsBrStr, CfgFParser, FReadInit


	// SET SOME PRESETS - if the profiler confuguration file exists, they will be overwritten by file entries!
	
	ProfilerConfig.logGroup := profLOGGRP_ALL;						// log every group (tasks, os tasks, interrupts, ...)
	ProfilerConfig.logMode := profLOGMOD_CONTINUOUS;				// 
	ProfilerConfig.archMode := profARCHMOD_OPT_ERROR;				// automatically create archive on pagefault
	ProfilerConfig.memTypeDef := profMEMTYPE_DRAM;					// profiling config memory 
	ProfilerConfig.memTypeDat := profMEMTYPE_DRAM;					// profiling data memory
	ProfilerConfig.backupLevel := profBKPLEVEL_EXCEPTION;			// backup to archive module after exception
	ProfilerConfig.bufferSize := 100000;							// 100 kByte of profiler buffer ...
	ProfilerConfig.addDataSize := 0;								// no additional data per entry, we don't need that for now
	ProfilerConfig.addOsTskCnt := 50;								// extra buffer for spawned system tasks
	ProfilerConfig.libFctCnt := 0;									// extra library profiling
	ProfilerConfig.pLibFunctions := 0;								// extra library profiling
	ProfilerConfig.pArchDevice := 0;								// File Device, the archive is saved to
	
	ProfilerConfig_INIT_0(sDevice := 'USER', sFile := 'profconf.setup', bExecuteIfFileNotFound := FALSE, ProfilerConfigStruct := ProfilerConfig);
	
	
	
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

