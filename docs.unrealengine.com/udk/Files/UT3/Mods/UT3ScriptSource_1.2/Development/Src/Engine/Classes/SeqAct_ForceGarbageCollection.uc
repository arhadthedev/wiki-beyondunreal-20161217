﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_ForceGarbageCollection extends SeqAct_Latent
	native(Sequence);

;

defaultproperties
{
	ObjName="Force Garbage Collection"
	ObjCategory="Misc"

	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Finished")

	VariableLinks.Empty
}
