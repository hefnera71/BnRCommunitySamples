
PROGRAM _INIT
	 
END_PROGRAM

PROGRAM _CYCLIC
	(*
		->.enable --> positive edge -> generator is initialized
		->.getNextUUID --> get a new UUID (generator initialization has to be finished already)
		->.ethIFName --> the hardware name of the ethernet interfce (needed to get some random data for initialization)
		<-.phase --> uuidgenPHASE_STOPPED (0) = disabled, uuidgenPHASE_INITIALIZING (1) = initializing, uuidgenPHASE_READY (2) = ready
		<-.UUID --> 32 hex character string with generated uuid
		<-.UUIDhypened --> same UUID, but 36 hex character string with hyphens like defined per RFC
	
		How to use:
		1.) enable the FB (positive edge needed)
		2.) wait until output .phase reaches uuidgenPHASE_READY (2)
		3.) use UUID 
		4.) use input .getNextUUID to get a fresh one (positive edge needed) -> no need to initialize again to get new UUIDs
	*)
	UUIDGenerator_0(enable := bEnable, getNextUUID := bNext, ethIfName := 'IF2');
	 
END_PROGRAM

PROGRAM _EXIT
	 
END_PROGRAM

