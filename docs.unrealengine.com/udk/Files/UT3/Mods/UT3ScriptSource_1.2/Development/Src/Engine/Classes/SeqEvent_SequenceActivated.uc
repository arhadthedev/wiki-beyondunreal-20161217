﻿/**
 * Activated once a sequence is activated by another operation.
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_SequenceActivated extends SequenceEvent
	native(Sequence);



/** Text label to use on the sequence input link */
var() string InputLabel;

defaultproperties
{
	ObjName="Sequence Activated"
	InputLabel="Default Input"
	bPlayerOnly=false
	MaxTriggerCount=0
}
