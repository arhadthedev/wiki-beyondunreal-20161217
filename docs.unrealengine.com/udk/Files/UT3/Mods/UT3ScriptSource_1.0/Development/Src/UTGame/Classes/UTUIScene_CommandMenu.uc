﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class UTUIScene_CommandMenu extends UTUIScene_Hud;

event PostInitialize()
{
	Super.PostInitialize();
	bDisplayCursor = false;
	OnPreRenderCallback = PreRenderCallback;
}

function PreRenderCallback()
{
	bDisplayCursor = false;
}


defaultproperties
{
	SceneInputMode=INPUTMODE_MatchingOnly
	SceneRenderMode=SPLITRENDER_PlayerOwner
	bDisplayCursor=true
	bRenderParentScenes=false
	bAlwaysRenderScene=true
	bCloseOnLevelChange=true

	Begin Object Name=SceneEventComponent
		DisabledEventAliases.Add(Clicked)
	End Object


}
