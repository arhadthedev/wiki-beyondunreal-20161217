﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class FogVolumeConeDensityInfo extends FogVolumeDensityInfo
	showcategories(Movement)
	native(FogVolume)
	abstract;



defaultproperties
{
	Begin Object Class=DrawLightConeComponent Name=DrawCone0
		ConeColor=(R=200,G=255,B=255)
	End Object
	Components.Add(DrawCone0)

	Begin Object Class=FogVolumeConeDensityComponent Name=FogVolumeComponent0
		PreviewCone=DrawCone0
	End Object
	DensityComponent=FogVolumeComponent0
	Components.Add(FogVolumeComponent0)
}
