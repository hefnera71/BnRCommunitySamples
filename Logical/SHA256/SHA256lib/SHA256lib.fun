
{REDUND_ERROR} FUNCTION GetSha256Hash : DINT (*Get the 32 byte SHA256 hash / checksum for the data to be hashed / checked*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		pData : UDINT; (*address of the data to check*)
		lenData : UDINT; (*length of data to check*)
	END_VAR
	VAR_IN_OUT
		hash : STRING[64]; (*ascii coded hex string with SHA256 hash as result*)
	END_VAR
END_FUNCTION
