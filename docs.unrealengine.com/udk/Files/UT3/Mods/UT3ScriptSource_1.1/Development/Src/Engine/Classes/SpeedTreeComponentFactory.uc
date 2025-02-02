﻿/*=============================================================================
	Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
=============================================================================*/
 
class SpeedTreeComponentFactory extends PrimitiveComponentFactory
	native(SpeedTree)
	hidecategories(Object)
	collapsecategories
	editinlinenew;

var() SpeedTreeComponent SpeedTreeComponent;



defaultproperties
{
	Begin Object Class=SpeedTreeComponent Name=SpeedTreeComponent0
	End Object
	SpeedTreeComponent = SpeedTreeComponent0;
	
	CollideActors		= TRUE
	BlockActors			= TRUE
	BlockZeroExtent		= TRUE
	BlockNonZeroExtent	= TRUE
	BlockRigidBody		= TRUE
}