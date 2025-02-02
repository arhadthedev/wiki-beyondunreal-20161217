﻿/**
 * This action allows designers to add additional fields to
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UIAction_AddDataField extends UIAction_DataStoreField
	native(inherit);



/**
 * Indicates whether the data field should be saved to the UIDynamicFieldProvider's persistent storage area.
 */
var()	bool						bPersistentField;

/**
 * Specifies the type of data field being added.
 */
var()	EUIDataProviderFieldType	FieldType;

DefaultProperties
{
	ObjName="Add Data Field"
	FieldType=DATATYPE_Property

	OutputLinks.Add((LinkDesc="Success"))
}
