﻿/**
 * SeqAct_LevelStreamingBase
 *
 * Base Kismet action exposing loading and unloading of levels.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_LevelStreamingBase extends SeqAct_Latent
	abstract
	native(Sequence);

/** Whether to make the level immediately visible after it finishes loading	*/
var() bool							bMakeVisibleAfterLoad;

/** Whether we want to force a blocking load								*/
var() bool							bShouldBlockOnLoad;

;

defaultproperties
{
	bMakeVisibleAfterLoad=TRUE

	ObjCategory="Level"
	VariableLinks.Empty
	OutputLinks.Empty
	InputLinks(0)=(LinkDesc="Load")
	InputLinks(1)=(LinkDesc="Unload")
	OutputLinks(0)=(LinkDesc="Finished")
}
