﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class MaterialExpressionTextureCoordinate extends MaterialExpression
	native(Material)
	collapsecategories
	hidecategories(Object);

/** Texture coordinate index */
var() int	CoordinateIndex;

/** Deprecated: This value has been made obsolete by the independent U/V tiling settings below.  This
  * should be removed for the next content resave (see VER_FONT_FORMAT_AND_UV_TILING_CHANGES) */
var deprecated float	Tiling;

/** Controls how much the texture tiles horizontally, by scaling the U component of the vertex UVs by the specified amount. */
var() float UTiling;

/** Controls how much the texture tiles vertically, by scaling the V component of the vertex UVs by the specified amount. */
var() float VTiling;



defaultproperties
{
	Tiling=1.0
	UTiling=1.0
	VTiling=1.0
}
