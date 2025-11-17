
PROGRAM _INIT
	(* Insert code here *)
	WebPingInterface_0(enable := TRUE, enableIfStats := TRUE, ifStatsName := 'IF2');
	WebPingInterface_0();
	 
END_PROGRAM

PROGRAM _CYCLIC

	WebPingInterface_0();
	 
END_PROGRAM

PROGRAM _EXIT

	WebPingInterface_0(enable := FALSE);

END_PROGRAM

