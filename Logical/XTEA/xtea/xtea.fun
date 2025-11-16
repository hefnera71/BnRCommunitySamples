
{REDUND_ERROR} FUNCTION xteaencdec : DINT (*encrypt / decrypt data, optionally also with encode / decode data to ascii-coded hex (for better usability when data has to be stored / loaded)*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		mode : USINT; (*mode, see xteaMODE_... constants*)
		pIn : UDINT; (*address of the variable holding the input data*)
		lenIn : UDINT; (*length of the input data*)
		pOut : UDINT; (*address of the variable where output data is copied to*)
		lenOut : UDINT; (*size of the output data - because of the algorithm is working blockwise, this length has always to be a multiple of 8 byte!!*)
		pKey : UDINT; (*address of a variable holding the cipher key*)
		lenKey : UDINT; (*length of the cipher key -- has always to be 16 byte!!*)
	END_VAR
END_FUNCTION
