
PROGRAM _INIT

	
	// result variable has to be of type "AstroSunRisetCalcResult_type"
	tResult;
	
	// if using a specific date, use a variable of type DTSructure
	tDateToCalculate;
	
	// geolocation: longitude latitude
	rLat := 53.54970;
	rLong := 9.96267; 
	
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)

	// example 1: use actual date from PLC
	IF bTest1 = TRUE THEN	
		AstroSunRiset_0(enable := TRUE, longitude := rLong, latitude := rLat, type := astroTYPE_DIRECT, pCalcDT := 0, gmtResult := FALSE, pResult := ADR(tResult));
		// async fub -> call until status != BUSY
		IF AstroSunRiset_0.status <> 16#FFFF THEN
			bTest1 := FALSE;
		END_IF
	END_IF

	// example 2: use a preset date, deliver result as GMT date time
	IF bTest2 = TRUE THEN

		// what to expect from this call, if paramaeters aren't changed:
		//    because of gmtResult = TRUE, and geolocation = HAMBURG, DE, result should be: 02:55 o'clock sunrise, and 19:52 o'clock sunset
		//    Hamburg has timezone GMT + 1, in July also daylight saving time is +1 hour

		tDateToCalculate.year := 2025;
		tDateToCalculate.month := 7;
		tDateToCalculate.day := 1;

		AstroSunRiset_1.enable := TRUE;
		AstroSunRiset_1.longitude := 9.96267;
		AstroSunRiset_1.latitude := 53.54970;
		AstroSunRiset_1.type := astroTYPE_DIRECT;
		AstroSunRiset_1.pCalcDT := ADR(tDateToCalculate);
		AstroSunRiset_1.gmtResult := TRUE;
		AstroSunRiset_1.pResult := ADR(tResult2);
		
		AstroSunRiset_1();
		
		// async fub -> call until status != BUSY
		IF AstroSunRiset_1.status <> 16#FFFF THEN
			bTest2 := FALSE;
		END_IF
		
	END_IF
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM

