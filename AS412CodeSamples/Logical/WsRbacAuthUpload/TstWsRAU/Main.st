
PROGRAM _INIT
	
	
	// internally, the RbacAuthUploadWebservice is configured for just very small files <= 10kByte
	// if you need to upload bigger files, you have to provide external memory by using the .externalBufferSetup structure
	// if 10kByte are enough per file, you can set the externalBufferSetup to 0 -> thenb the internal buffer is used
	
	// allocate memory
	AsMemPartCreate_0(enable := TRUE, len := 1024*1024 + 16); // allocating 1MB - as 2 buffers are required, the maximum file size possible is then 0.5 MByte
	IF AsMemPartCreate_0.status = 0 THEN
		AsMemPartAlloc_0(enable := TRUE, ident := AsMemPartCreate_0.ident, len := 1024 * 512); // reserve 0.5 MB block
		AsMemPartAlloc_1(enable := TRUE, ident := AsMemPartCreate_0.ident, len := 1024 * 512); // reserve 0.5 MB block
	END_IF
	// configure buffers using ".externalBufferSetup"
	IF AsMemPartAlloc_0.status = 0 AND AsMemPartAlloc_1.status = 0 THEN
		tBufferConfig.multipartBufferSize := tBufferConfig.requestBufferSize := 1024 * 512;
		tBufferConfig.pMultipartBuffer := AsMemPartAlloc_0.mem;
		tBufferConfig.pRequestBuffer := AsMemPartAlloc_1.mem;
	ELSE
		brsmemset(ADR(tBufferConfig),0, SIZEOF(tBufferConfig));
	END_IF
	
	// configure the function block   		
	RbacAuthUploadWebservice_0.targetDeviceName := 'USER';				// file device where uploads are stored
	RbacAuthUploadWebservice_0.targetDirectoryName := 'upload';			// directory where uploads are stored -> security info: don't use a directory that is reachable for the webserver!!
	RbacAuthUploadWebservice_0.authServiceName := 'authenticate.cgi';	// the name of authentication webservice  -> security info: define and use an own one!!
	RbacAuthUploadWebservice_0.uploadServiceName := 'uploader.cgi';		// name of the upload webservice -> security info: define and use an own one!!
	RbacAuthUploadWebservice_0.rbacRoleName := 'WEB_Uploader';			// RBAC role the user has to have -> security info: define and use an own one!!
	RbacAuthUploadWebservice_0.loggerName := '$$arlogusr';				// logger module where webserive actions should logged to -> security info: ensure that logging works, it's crucial to what happens on the webservice!!
	RbacAuthUploadWebservice_0.ethIfName := 'IF2';						// active ethernet interface name - needed for token generation -> 
	RbacAuthUploadWebservice_0.uploadServiceTimer := T#30s;				// time how long the upload servce should be active -> security info: keep it as short as possible open!!
	RbacAuthUploadWebservice_0.enableHtmlMode := FALSE;					// enables the usage of html mode -> security info: activate it only if you really need it!!
	RbacAuthUploadWebservice_0.externalBufferSetup := tBufferConfig;	// use external buffer (if allocation was ok)
	
	// enable the function block
	RbacAuthUploadWebservice_0.enable := TRUE;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// call the function block
	RbacAuthUploadWebservice_0();
	 
END_PROGRAM

PROGRAM _EXIT
	
	// disable the function block
	RbacAuthUploadWebservice_0(enable := FALSE);
	// free allocated memory
	AsMemPartDestroy_0(enable := TRUE, ident := AsMemPartCreate_0.ident);

END_PROGRAM

