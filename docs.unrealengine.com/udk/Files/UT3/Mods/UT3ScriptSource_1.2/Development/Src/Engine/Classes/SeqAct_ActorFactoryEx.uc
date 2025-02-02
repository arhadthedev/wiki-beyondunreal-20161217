﻿/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class SeqAct_ActorFactoryEx extends SeqAct_ActorFactory
	native(Sequence);



defaultproperties
{
	ObjName="Actor Factory Ex"

	OutputLinks(2)=(LinkDesc="Spawned 1")

	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawn Point",PropertyName=SpawnPoints)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Spawned 1",bWriteable=TRUE)
}
