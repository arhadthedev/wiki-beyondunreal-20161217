﻿//=============================================================================
// A sticky note.  Level designers can place these in the level and then
// view them as a batch in the error/warnings window.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class Note extends Actor
	placeable
	native;

var() string Text;



defaultproperties
{
	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=150,G=200,B=255)
		ArrowSize=0.5
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Arrow)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EngineResources.S_Note'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)
	
	bStatic=true
	bHidden=true
	bNoDelete=true
	bMovable=false
}
