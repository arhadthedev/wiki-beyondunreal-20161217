﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * This class handles the registration, creation, and destruction of browser
 * panes. All of the browser panes are registered in an INI file so that they
 * can be late bound into the editor.
 *
 * @see UBrowserManager.h for the native definitions
 */
class BrowserManager extends Object
	native
	config(Editor);

/**
 * Struct containing the information needed to register a browser window
 */
struct native BrowserPaneInfo
{
	/**
	 * This is the browser pane id used for associating instantiated windows
	 * with their events, etc.
	 */
	var int PaneID;
	/**
	 * The name of the wxWindow to create for the browser pane.
	 * NOTE: This must be a subclass of WxDockableWindow
	 */
	var String WxWindowClassName;
	/**
	 * This is the friendly name used to find browsers by name instead of
	 * by id
	 */
	var String FriendlyName;
	/**
	 * Used to indicate that this pane is a clone of a "canonical" pane. This
	 * is used to allow the removal of a clone, but hiding of a "canonical"
	 * pane. This prevents the user from permanently deleting a pane from
	 * their configuration.
	 */
	var const int CloneOfPaneID;
	/**
	 * Number for this clone so that the description can indicate it (Log-1)
	 */
	var const int CloneNumber;
	/**
	 * This is a pointer to the window that has been created
	 */
	var const transient pointer WxBrowserPtr;
};

/**
 * Holds the list of browser panes to create/support
 */
var config array<BrowserPaneInfo> BrowserPanes;

/**
 * Whether the browser panes have been created or not
 */
var bool bHasCreatedPanes;

/**
 * The last selected browser pane
 */
var config int LastSelectedPaneID;

/**
 * This is the docking container instance
 */
var const transient pointer DockingContainerPtr;

/**
 * Holds the list of floating windows not docked in the docking container
 */
var const transient pointer FloatingWindowsArrayPtr;

/**
 * Holds the pointer to the frame window's menus that are to be changed as
 * browsers are created and removed.
 */
var const transient pointer BrowserMenuPtr;

/**
 * The UI editor manager. Handles creating and managing UI scenes that are being edited.
 * Stored here instead of in the UIScene browser type because there should be only one of these guys around.
 */
var const transient UISceneManager	UISceneManager;

