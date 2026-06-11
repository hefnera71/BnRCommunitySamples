# Library WsQRLib

## About

This library implements webservice based possibility to display a QR code.

The're many possibilities to include QR codes in your visualizations in much more pretty and comfortable way then this library.
I implemented that one for some special use-case, where just a simple QRcode is needed but nothing more, and where I therefore don't want to setup a complete visualization or web project.

## How it works

The function block "QRCodeWebservice" inside this library uses AsHttps - httpsService, just for sending a JavaScript-based QRcode implementation as response to the browser.
As content for the QR code, a string is used.

He're the function block inputs and outputs with some short usage comments.
```
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enables the webservice*)
		pDataString : {REDUND_UNREPLICABLE} UDINT; (*pointer to the data to encode into qr code*)
		webserviceName : {REDUND_UNREPLICABLE} STRING[80]; (*name how the webservice is reachable (pattern: https://<IP Address of PLC>/<this name>)*)
	END_VAR
	VAR_OUTPUT
		status : {REDUND_UNREPLICABLE} UINT; (*FB status -> 65535 if running, 65534 if disabled, error if anything else*)
		wsPhase : {REDUND_UNREPLICABLE} UINT; (*webservice phase -> see AS help, FB httpsService*)
	END_VAR
	VAR
		wssService : {REDUND_UNREPLICABLE} httpsService; (*internal*)
		wsStep : {REDUND_UNREPLICABLE} UINT; (*internal*)
		last : {REDUND_UNREPLICABLE} BOOL; (*internal*)
	END_VAR
```

## Example
The task "TstWsQR" contains a simple example how to call the function block.
When FB is running e.g. on ArSim, just open your browser and enter as url "https://127.0.0.1/myQrCodeGenerator.cgi".

As result, you should see a QRcode with the content "https://github.com/hefnera71/BnRCommunitySamples".


```
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
```

### External references
The script generating the QR code uses: https://github.com/kazuhikoarase/qrcode-generator/tree/master/js

The original code was modified to pack it into a C string, so that it can be sent directly by code from httpsClient FB.
