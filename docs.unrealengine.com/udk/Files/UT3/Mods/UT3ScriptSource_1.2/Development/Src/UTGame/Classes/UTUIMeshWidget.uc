﻿/**
 * UT Specialized version of UIMeshWidget, adds some lights and optionally rotates the model.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIMeshWidget extends UIMeshWidget
	native(UI)
	placeable;



/** Amount of degrees to rotate per second. */
var() vector	RotationRate;

/** Light for the mesh widget. */
var() SkeletalMeshComponent SkeletalMeshComp;

/** Light for the mesh widget. */
var() LightComponent DefaultLight;

/** Light direction. */
var() vector	LightDirection;

/** Light for the mesh widget. */
var() LightComponent DefaultLight2;

/** Light direction. */
var() vector	LightDirection2;

/** Base Height to use for scaling, all meshes are fit within this height. A value of < 0 means no auto scaling. */
var() float			BaseHeight;

defaultproperties
{
	bDebugShowBounds=false
	BaseHeight=-1.0f

	Begin Object Class=SkeletalMeshComponent Name=WidgetSKMesh
	End Object
	SkeletalMeshComp=WidgetSKMesh

	Begin Object Class=DirectionalLightComponent Name=WidgetLight
	End Object
	DefaultLight=WidgetLight
	LightDirection=(X=0.0f,Y=45.0f,Z=180.0f)

	Begin Object Class=DirectionalLightComponent Name=WidgetLight2
	End Object
	DefaultLight2=WidgetLight2
	LightDirection2=(X=0.0f,Y=-45.0f,Z=180.0f)
}