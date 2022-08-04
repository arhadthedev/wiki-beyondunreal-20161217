﻿/**
 * Event which is activated by gameplay code when a projectile lands.
 * Originator: the Pawn that owns this event.
 * Instigator: a projectile actor which was fired by the Pawn that owns this event
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqEvent_ProjectileLanded extends SequenceEvent
	native(Sequence);

;

var() float MaxDistance;

defaultproperties
{
	ObjName="Projectile Landed"
	ObjCategory="Physics"
	bPlayerOnly=false

	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Projectile",bWriteable=true)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Shooter",bWriteable=true)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Object',LinkDesc="Witness",bWriteable=true)
}