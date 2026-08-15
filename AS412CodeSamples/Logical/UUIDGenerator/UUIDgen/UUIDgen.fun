
{REDUND_UNREPLICABLE} FUNCTION_BLOCK UUIDGenerator
	VAR_INPUT
		enable : {REDUND_UNREPLICABLE} BOOL; (*enable the function block -> with positive edge, the generator is initialized*)
		getNextUUID : {REDUND_UNREPLICABLE} BOOL; (*when generator is initialized, positive edge generates a new uuid*)
		ethIfName : {REDUND_UNREPLICABLE} STRING[32]; (*name of the ethernet interface, e.g. 'IF2'*)
	END_VAR
	VAR_OUTPUT
		phase : {REDUND_UNREPLICABLE} USINT; (*initialization phase, please see constants uuidgenPHASE_xxx for details*)
		UUID : {REDUND_UNREPLICABLE} STRING[32]; (*the (new) UUID*)
		UUIDhyphened : {REDUND_UNREPLICABLE} STRING[36]; (*the (new) UUID with hyphens as defined in RFC*)
	END_VAR
END_FUNCTION_BLOCK
