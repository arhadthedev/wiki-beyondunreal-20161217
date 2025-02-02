﻿/**
 * Extends the resource data provider to have a 'filter' accessor so we can decide whether or not to include the provider in a list of items.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved
 */
class UTUIResourceDataProvider extends UIResourceDataProvider
	native(UI)
	config(Game);



/** whether to search all .inis for valid resource provider instances instead of just the our specified config file
 * this is used for lists that need to support additions via extra files, i.e. mods
 */
var() bool bSearchAllInis;
/** the .ini file that this instance was created from, if not the class default .ini (for bSearchAllInis classes) */
var const string IniName;

/** Options to remove certain menu items on a per platform basis. */
var config bool bRemoveOn360;
var config bool bRemoveOnPC;
var config bool bRemoveOnPS3;

/** @return Returns whether or not this provider should be filtered, by default it checks the platform flags. */
function native virtual final bool IsFiltered();
