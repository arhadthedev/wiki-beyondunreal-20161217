﻿/**
 * SeqAct_CommitMapChange
 *
 * Kismet action commiting pending map change
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_CommitMapChange extends SequenceAction
	native(Sequence);

;

defaultproperties
{
	ObjName="Commit Map Change"

	ObjCategory="Level"
	VariableLinks.Empty
	InputLinks(0)=(LinkDesc="Commit")
}
