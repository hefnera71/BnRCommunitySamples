
{REDUND_UNREPLICABLE} FUNCTION_BLOCK tasmotapiSendRequest (*send a http request to a tasmota device*)
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enable the function block (internal http client will be enabled with first send command)*)
		sHost : {REDUND_UNREPLICABLE} STRING[128]; (*ip address or hostname of the device*)
		uPort : {REDUND_UNREPLICABLE} UINT; (*port of the device webserver, default 80*)
		sUser : {REDUND_UNREPLICABLE} STRING[32]; (*if authentication on the device is enabled: username*)
		sPassword : {REDUND_UNREPLICABLE} STRING[32]; (*if authentication on the device is enabled: password*)
		sCommand : {REDUND_UNREPLICABLE} STRING[32]; (*the tasmota command to send to the device ... // see here for Tasmota commands: https://tasmota.github.io/docs/Commands/*)
		pResponseBuffer : {REDUND_UNREPLICABLE} UDINT; (*the buffer where the response data should be stored, given as pointer*)
		uResponseBufferSize : {REDUND_UNREPLICABLE} UDINT; (*the size of the response data buffer in byte*)
		bSendCommand : {REDUND_UNREPLICABLE} BOOL; (*set TRUE to send the command*)
	END_VAR
	VAR_OUTPUT
		sendCommandBusy : {REDUND_UNREPLICABLE} BOOL; (*command execution is active, please wait*)
		sendCommandSuccess : {REDUND_UNREPLICABLE} BOOL; (*command execution was successful*)
		sendCommandError : {REDUND_UNREPLICABLE} BOOL; (*command execution failed*)
		status : {REDUND_UNREPLICABLE} UINT; (*the status of the internal instance of httpClient fb from ashttp library*)
		httpStatus : {REDUND_UNREPLICABLE} UINT; (*the http status of the internal instance of httpClient fb from ashttp library*)
		responseDataLen : {REDUND_UNREPLICABLE} UDINT; (*the length of data that was responded from the device*)
	END_VAR
	VAR
		tAPI : {REDUND_UNREPLICABLE} tTasmotaAPI_type;
		Client : {REDUND_UNREPLICABLE} httpClient;
		SetParam : {REDUND_UNREPLICABLE} httpSetParamUrl;
		stepSendRequest : {REDUND_UNREPLICABLE} UINT;
		requestBuffer : {REDUND_UNREPLICABLE} STRING[512];
		TONWaitForResponse : {REDUND_UNREPLICABLE} TON;
		zzEdge00000 : {REDUND_UNREPLICABLE} BOOL;
		zzEdge00001 : {REDUND_UNREPLICABLE} BOOL;
		zzEdge00002 : {REDUND_UNREPLICABLE} BOOL;
		zzEdge00003 : {REDUND_UNREPLICABLE} BOOL;
	END_VAR
END_FUNCTION_BLOCK
