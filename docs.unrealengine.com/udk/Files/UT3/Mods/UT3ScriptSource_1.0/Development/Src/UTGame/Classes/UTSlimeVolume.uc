﻿/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTSlimeVolume extends WaterVolume
	placeable;

defaultproperties
{
	bPainCausing=True
	DamagePerSec=7.0
	FluidFriction=5.0
	DamageType=class'UTDmgType_Slime'
	TerminalVelocity=+01500.000000
	EntrySound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepLandCue'
	ExitSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_WaterDeepCue'
}
