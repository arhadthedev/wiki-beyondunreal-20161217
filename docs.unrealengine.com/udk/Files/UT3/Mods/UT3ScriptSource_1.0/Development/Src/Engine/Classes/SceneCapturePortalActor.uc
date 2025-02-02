﻿/**
 * SceneCapturePortalActor
 *
 * Place this actor in a level to capture the scene
 * to a texture target using a SceneCapturePortalComponent
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SceneCapturePortalActor extends SceneCaptureReflectActor
	native
	placeable;

// so we do not load this Mesh on the console (some how it is being loaded even tho the correct flags are set)
var notforconsole StaticMesh CameraMesh;
var StaticMeshComponent CameraComp;

// so we do not load this Mesh on the console (some how it is being loaded even tho the correct flags are set)
var notforconsole StaticMesh TexPropPlaneMesh;


event PreBeginPlay()
{
	Super.PreBeginPlay();

	CameraComp.SetStaticMesh( CameraMesh );
	StaticMesh.SetStaticMesh( TexPropPlaneMesh );
}




defaultproperties
{
	// actor's facing direction is the portal capture direction
	Rotation=(Pitch=0,Roll=0,Yaw=0)

	Components.Remove(SceneCaptureReflectComponent0)
	Components.Remove(Sprite)
	Components.Remove(StaticMeshComponent0)

	// uses portal scene capture component
	// this is needed to actually capture the scene to a texture
	Begin Object Class=SceneCapturePortalComponent Name=SceneCapturePortalComponent0
	End Object
	SceneCapture=SceneCapturePortalComponent0
	Components.Add(SceneCapturePortalComponent0)


	CameraMesh=StaticMesh'EditorMeshes.MatineeCam_SM'

	// used to visualize facing direction 
	// note that capture direction is opposite of actor facing direction (-x)
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		HiddenGame=true
		CastShadow=false
		CollideActors=false
		AlwaysLoadOnServer=FALSE
		AlwaysLoadOnClient=FALSE
		Scale3D=(X=-1,Y=1,Z=1)
		//StaticMesh=StaticMesh'EditorMeshes.MatineeCam_SM'
	End Object
	CameraComp=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)

	TexPropPlaneMesh=StaticMesh'EditorMeshes.TexPropPlane'

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent2
		HiddenGame=true
		CastShadow=false
		CollideActors=false
		AlwaysLoadOnServer=FALSE
		AlwaysLoadOnClient=FALSE
		Scale3D=(X=1.0,Y=1.0,Z=1.0)
		//StaticMesh=StaticMesh'EditorMeshes.TexPropPlane'
	End Object
	StaticMesh=StaticMeshComponent2
	Components.Add(StaticMeshComponent2)
}
