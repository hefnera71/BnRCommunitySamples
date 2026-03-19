
PROGRAM _INIT
	
	// use http
	// WebPingInterface_0(enable := TRUE, https := FALSE, enableIfStats := TRUE, ifStatsName := 'IF2');
	
	// use https -> please setup the webserver and SSL configuration accordingly
	WebPingInterface_0(enable := TRUE, https := TRUE, enableIfStats := TRUE, ifStatsName := 'IF2');
	WebPingInterface_0();
	 
END_PROGRAM

PROGRAM _CYCLIC

	WebPingInterface_0();
	 
END_PROGRAM

PROGRAM _EXIT

	WebPingInterface_0(enable := FALSE);

END_PROGRAM

