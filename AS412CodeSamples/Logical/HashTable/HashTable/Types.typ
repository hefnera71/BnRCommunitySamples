
TYPE
	_internalHashIdent_typ : 	STRUCT  (*INTERNAL - hash ident*)
		pHashTable : UDINT;
		hashModulo : UDINT;
		identMemPartCreate : UDINT;
	END_STRUCT;
	HashTableFieldEntry_typ : 	STRUCT  (*INTERNAL - hash field*)
		pString : UDINT; (*pointer to the string used as "assoc.  index"*)
		pNext : UDINT; (*pointer to the next entry (in case of collision inside the hash table)*)
		Data : HashTableDataSubfield_typ; (*datasets*)
		datasets : UINT; (*number of different datasets linked to this string*)
	END_STRUCT;
	HashTableDataSubfield_typ : 	STRUCT  (*INTERNAL - hash field associated data field*)
		pData : UDINT; (*pointer to the data associated with the string*)
		userTag : DINT; (*free to use for the user, e.g. for some data classification*)
		pNextData : UDINT; (*pointer to the next data set in case of non-unique strings*)
	END_STRUCT;
	HashTableBase_typ : 	STRUCT  (*INTERNAL -this array then is the hash table base type*)
		Field : HashTableFieldEntry_typ;
		collisions : UINT; (*number of collisions at this field*)
	END_STRUCT;
	HashTableInfo_typ : 	STRUCT  (*USER - use a variable of this typ together with GetHashTableInfo*)
		unusedTableFields : UINT; (*unused base elements of the hash table*)
		sumOfCollisions : UDINT; (*number of collisions in the hash table -- if everything ok, then: number of collisions + number of array elements in hash table = number of strings hashed*)
		highestNrOfCollisions : UINT; (*the highest number of collisions at a hash table element*)
		numBytesFree : UDINT; (*number of free bytes in the allocated memory partition*)
		maxBlockSizeFree : UDINT; (*biggest en-block size of free bytes in allocated memory partition*)
	END_STRUCT;
END_TYPE
