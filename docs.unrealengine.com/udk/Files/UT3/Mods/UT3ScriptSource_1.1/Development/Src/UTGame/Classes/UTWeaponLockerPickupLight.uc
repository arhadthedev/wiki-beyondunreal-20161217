﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UTWeaponLockerPickupLight extends UTPickupLight
	native
	placeable;

defaultproperties
{
	Begin Object Class=PointLightComponent Name=PointLightComponent0
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=FALSE
		bForceDynamicLight=FALSE
		UseDirectLightMap=TRUE
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=FALSE,bInitialized=TRUE)
		Brightness=4
		LightColor=(R=216,G=245,B=205)
		Radius=192
	End Object
	LightComponent=PointLightComponent0
	Components.Add(PointLightComponent0)
}
