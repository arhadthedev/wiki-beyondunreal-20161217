﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionSceneTexture extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** 
 * MaterialExpressionSceneTexture: 
 * samples the current scene texture (lighting,etc)
 * for use in a material
 */

/** texture coordinate inputt expression for this node */
var ExpressionInput	Coordinates;

var() enum ESceneTextureType
{
	// 16bit component lighting target
	SceneTex_Lighting
} SceneTextureType;

/** Matches [0,1] UVs to the view within the back buffer. */
var() bool ScreenAlign;



defaultproperties
{
	SceneTextureType=SceneTex_Lighting
}
