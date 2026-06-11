
{REDUND_ERROR} {REDUND_UNREPLICABLE} FUNCTION_BLOCK QRCodeWebservice (*a simple webservice for displaying a QR code (webservice is running in the context of the ARembedded webserver)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
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
END_FUNCTION_BLOCK
