﻿/*=============================================================================
	Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
=============================================================================*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Class Declaration

class SpeedTreeComponent extends PrimitiveComponent 
	native(SpeedTree)
	AutoExpandCategories(Collision,Rendering,Lighting)
	hidecategories(Object)
	editinlinenew;
	
/** USpeedTree resource.																				*/
var(SpeedTree)	const	SpeedTree				SpeedTree;

// Flags
/** Whether to draw leaves or not.																		*/
var(SpeedTree) 			bool 					bUseLeaves;
/** Whether to draw branches or not.																	*/
var(SpeedTree) 			bool 					bUseBranches;
/** Whether to draw fronds or not.																		*/
var(SpeedTree) 			bool 					bUseFronds;
/** Whether billboards are drawn at the lowest LOD or not.												*/
var(SpeedTree)			bool					bUseBillboards;				

// LOD 
/** The distance for the most detailed tree.															*/
var(SpeedTree)			float					LodNearDistance;
/** The distance for the lowest detail tree.															*/
var(SpeedTree)			float					LodFarDistance;
/** the tree will use this LOD level (0.0 - 1.0). If -1.0, the tree will calculate its LOD normally.	*/
var(SpeedTree)			float					LodLevelOverride;

// Material overrides

/** Branch material. */
var(SpeedTree) MaterialInterface		BranchMaterial;

/** Frond material. */
var(SpeedTree) MaterialInterface		FrondMaterial;

/** Leaf material. */
var(SpeedTree) MaterialInterface		LeafMaterial;

/** Billboard material. */
var(SpeedTree) MaterialInterface		BillboardMaterial;

// Internal
/** Icon texture. */
var	editoronly private Texture2D				SpeedTreeIcon;

/** The static lighting for a single light's affect on the component. */
struct native SpeedTreeStaticLight
{
	var private const Guid Guid;
	var private const ShadowMap1D BranchAndFrondShadowMap;
	var private const ShadowMap1D LeafMeshShadowMap;
	var private const ShadowMap1D LeafCardShadowMap;
	var private const ShadowMap1D BillboardShadowMap;
};

/** Static lights array. */
var private const array<SpeedTreeStaticLight> StaticLights;

struct LightMapRef
{
	var native private const pointer Reference;
};

/** The component's branch and frond light-map. */
var native private const LightMapRef BranchAndFrondLightMap;

/** The component's leaf mesh light-map. */
var native private const LightMapRef LeafMeshLightMap;

/** The component's leaf card light-map. */
var native private const LightMapRef LeafCardLightMap;

/** The component's billboard light-map. */
var native private const LightMapRef BillboardLightMap;

/** The component's rotation matrix (for arbitrary rotations with wind) */
var native private const Matrix RotationOnlyMatrix;

/** The component's random wind matrix offset */
var native private const float WindMatrixOffset;



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Default Properties

defaultproperties
{
	bUseLeaves			= TRUE
	bUseBranches		= TRUE
	bUseFronds			= TRUE
	bUseBillboards		= TRUE
	
	LodNearDistance		= 500.0f
	LodFarDistance		= 3000.0f
	LodLevelOverride	= 1.0f
	
	SpeedTreeIcon		= Texture2D'EditorResources.SpeedTreeLogo'

	CollideActors		= TRUE
	BlockActors			= TRUE
	BlockRigidBody		= TRUE
	BlockZeroExtent		= TRUE
	BlockNonZeroExtent	= TRUE

	bUseAsOccluder		= TRUE
	CastShadow			= TRUE
	bAcceptsLights		= TRUE
	bUsePrecomputedShadows = TRUE
}
