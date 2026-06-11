
PROGRAM _INIT

	// test data
	sData := 'https://github.com/hefnera71/BnRCommunitySamples';
	sName := 'myQRCodeGenerator.cgi';
	bEnable := TRUE;

END_PROGRAM

PROGRAM _CYCLIC

	QRCodeWebservice_0(enable := bEnable, pDataString := ADR(sData), webserviceName := sName);
	 
END_PROGRAM

PROGRAM _EXIT

	QRCodeWebservice_0(enable := FALSE);
	 
END_PROGRAM

