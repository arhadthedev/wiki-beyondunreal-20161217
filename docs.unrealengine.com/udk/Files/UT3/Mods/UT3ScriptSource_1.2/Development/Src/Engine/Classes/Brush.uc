﻿//=============================================================================
// The brush class.
// Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class Brush extends Actor
	hidecategories(Object)
	hidecategories(Movement)
	hidecategories(Display)
	native;

//-----------------------------------------------------------------------------
// Variables.

// CSG operation performed in editor.
var() enum ECsgOper
{
	CSG_Active,			// Active brush.
	CSG_Add,			// Add to world.
	CSG_Subtract,		// Subtract from world.
	CSG_Intersect,		// Form from intersection with world.
	CSG_Deintersect,	// Form from negative intersection with world.
} CsgOper;

// Information.
var() color BrushColor;
var	  int	PolyFlags;
var() bool  bColored;
var bool	bSolidWhenSelected;

var export const Model	Brush;
var editconst const BrushComponent BrushComponent;

// Selection information for geometry mode

struct native export GeomSelection
{
	var int		Type;			// EGeometrySelectionType_
	var int		Index;			// Index into the geometry data structures
	var int		SelectionIndex;	// The selection index of this item
	var float	SelStrength;	// The strength of the selection (used for soft selection)
};

/**
 * Stores selection information from geometry mode.  This is the only information that we can't
 * regenerate by looking at the source brushes following an undo operation.
 */
 
var array<GeomSelection>	SavedSelections;

//-----------------------------------------------------------------------------
// cpptext.



defaultproperties
{
	Begin Object Class=BrushComponent Name=BrushComponent0
	End Object
	BrushComponent=BrushComponent0
	CollisionComponent=BrushComponent0
	Components.Add(BrushComponent0)

	bStatic=True
	bHidden=True
	bNoDelete=True
	bEdShouldSnap=True
}
