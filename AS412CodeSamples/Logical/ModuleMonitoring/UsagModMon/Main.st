
PROGRAM _INIT
	
	ModuleMonitoring_0.enable := TRUE;
	ModuleMonitoring_0.logAllModules := TRUE;
	ModuleMonitoring_0.logNewModules := TRUE;
	 
END_PROGRAM

PROGRAM _CYCLIC

	ModuleMonitoring_0();
	
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

