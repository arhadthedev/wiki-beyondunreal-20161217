﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/** 
 * InterpData
 *
 * 
 * Actual interpolation data, containing keyframe tracks, event tracks etc.
 * This does not contain any Actor references or state, so can safely be stored in 
 * packages, shared between multiple Actors/SeqAct_Interps etc.
 */

class InterpData extends SequenceVariable
	native(Sequence);



/** Duration of interpolation sequence - in seconds. */
var float				InterpLength; 

/** Position in Interp to move things to for path-building in editor. */
var float				PathBuildTime;

/** Actual interpolation data. Groups of InterpTracks. */
var	export array<InterpGroup>	InterpGroups;

/** Used for curve editor to remember curve-editing setup. Only loaded in editor. */
var	export InterpCurveEdSetup	CurveEdSetup;

/** Used for filtering which tracks are currently visible. */
var editoronly array<InterpFilter>	InterpFilters;

/** The currently selected filter. */
var editoronly InterpFilter			SelectedFilter;

/** Array of default filters. */
var editoronly transient array<InterpFilter> DefaultFilters;

/** Used in editor for defining sections to loop, stretch etc. */
var	float				EdSectionStart;

/** Used in editor for defining sections to loop, stretch etc. */
var	float				EdSectionEnd;



defaultproperties
{
	InterpLength=5.0
	EdSectionStart=1.0
	EdSectionEnd=2.0
	PathBuildTime=0.0

	ObjName="Matinee Data"
	ObjColor=(R=255,G=128,B=0,A=255)

	Begin Object Class=InterpFilter Name=FilterAll
		Caption="All"
	End Object

	Begin Object Class=InterpFilter_Classes Name=FilterCameras
		Caption="Cameras"
		ClassToFilterBy=CameraActor
	End Object
	
	Begin Object Class=InterpFilter_Classes Name=FilterSkeletalMeshes
		Caption="Skeletal Meshes"
		ClassToFilterBy=SkeletalMeshActor
	End Object

	DefaultFilters=(FilterAll, FilterCameras, FilterSkeletalMeshes)
}
