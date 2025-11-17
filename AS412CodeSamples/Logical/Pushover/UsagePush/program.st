PROGRAM _INIT

	// startup timer
	TON_StartupWait.IN := TRUE;
	TON_StartupWait.PT := T#30s;
	
	
	// YOUR PERSONAL PUSHOVER USER OR GROUP KEY - a xxx digit string that can contain lower + upper case chars and numbers
	// this key can be retreived after creating a pushover account and logging in into pushover.net
	// the value used here is just an example and isn't working
	tPushoverInterface.userKey := 'aAbBcCdDeEfFgGhHiIjJkKlLmMnNoO';

	// YOUR PERSONAL PUSHOVER APPLICATION KEY - a xxx digit string that can contain lower + upper case chars and numbers
	// this key can be retreived after creating a pushover account and logging in into pushover.net
	// the value used here is just an example and isn't working
	tPushoverInterface.applicationKey := 'aAbBcCdDeEfFgGhHiIjJkKlLmMnNoO';
	
	// the name of the pushover device, if you want to deliver a message just to one device but not to all devices sharing the account
	tPushoverInterface.device := '';

	// the message content
	tPushoverInterface.wsContent := "Versand einer Test PushMessage von SPS über ARSim";
	// the message title
	tPushoverInterface.wsTitle := "TESTnachricht von SPS";
	
	// some message settings like priority a.s.o
	tPushoverInterface.priority.flag := pushprioNORMAL;
	tPushoverInterface.priority.retryMinutes := 0;
	tPushoverInterface.priority.expireMinutes := 0;

	// the supplementary URL of the message, if wanted / needed
	tPushoverInterface.supplUrl.title := 'B&R Webseite';
	tPushoverInterface.supplUrl.url := 'http://www.br-automation.com';
	

END_PROGRAM


PROGRAM _CYCLIC
	
	// after startup, wait some seconds for system services to get ready
	// until now, I haven't found out why, but if the function block call is very fast (10ms), at least on ARSim this leads to TCPopen.status = 32608
	TON_StartupWait();
	
	IF TON_StartupWait.Q = TRUE THEN
		
		// set the parameters for the function block call
		PushMessage.MessageParameters := tPushoverInterface;
		// trigger "send" by setting "bSend" to true
		PushMessage.send := bSend;
		// fb call
		PushMessage();
		// reset "bSend" after success or error
		IF EDGENEG(PushMessage.busy) = TRUE THEN
			bSend := FALSE;
		END_IF
	
	END_IF
	
END_PROGRAM
