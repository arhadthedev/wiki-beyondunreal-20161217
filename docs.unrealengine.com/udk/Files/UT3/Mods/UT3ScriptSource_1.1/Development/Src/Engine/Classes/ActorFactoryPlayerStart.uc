﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class ActorFactoryPlayerStart extends ActorFactory
	config(Editor)
	collapsecategories
	hidecategories(Object)
	native;

defaultproperties
{
	MenuName="Add PlayerStart"
	NewActorClass=class'Engine.PlayerStart'
}
