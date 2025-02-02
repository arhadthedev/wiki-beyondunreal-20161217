﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

/** Common columns to be read from the DM tables */
class UTLeaderboardReadVehiclesDM extends UTLeaderboardReadBase;

`include(UTStats.uci)

defaultproperties
{
	ViewId=STATS_VIEW_DM_VEHICLES_ALLTIME
	// UI meta data
	ViewName="VehiclesDM"
	SortColumnId=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_CICADA_CONTENT


ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_CICADA_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_DARKWALKER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_FURY_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_GOLIATH_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_HELLBENDER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_HOVERBOARD)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_LEVIATHAN_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_MANTA_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_NEMESIS)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_NIGHTSHADE_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_PALADIN)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_RAPTOR_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_SCAVENGER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_SCORPION_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_SPMA_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_STEALTHBENDER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_TURRET)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_VIPER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_CICADA_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_DARKWALKER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_FURY_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_GOLIATH_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_HELLBENDER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_HOVERBOARD)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_LEVIATHAN_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_MANTA_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_NEMESIS)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_NIGHTSHADE_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_PALADIN)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_RAPTOR_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_SCAVENGER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_SCORPION_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_SPMA_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_STEALTHBENDER_CONTENT)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_TURRET)
ColumnIds.Add(`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_VIPER_CONTENT)

ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_CICADA_CONTENT,Name="DRIVING_UTVEHICLE_CICADA_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_DARKWALKER_CONTENT,Name="DRIVING_UTVEHICLE_DARKWALKER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_FURY_CONTENT,Name="DRIVING_UTVEHICLE_FURY_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_GOLIATH_CONTENT,Name="DRIVING_UTVEHICLE_GOLIATH_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_HELLBENDER_CONTENT,Name="DRIVING_UTVEHICLE_HELLBENDER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_HOVERBOARD,Name="DRIVING_UTVEHICLE_HOVERBOARD"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_LEVIATHAN_CONTENT,Name="DRIVING_UTVEHICLE_LEVIATHAN_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_MANTA_CONTENT,Name="DRIVING_UTVEHICLE_MANTA_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_NEMESIS,Name="DRIVING_UTVEHICLE_NEMESIS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_NIGHTSHADE_CONTENT,Name="DRIVING_UTVEHICLE_NIGHTSHADE_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_PALADIN,Name="DRIVING_UTVEHICLE_PALADIN"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_RAPTOR_CONTENT,Name="DRIVING_UTVEHICLE_RAPTOR_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_SCAVENGER_CONTENT,Name="DRIVING_UTVEHICLE_SCAVENGER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_SCORPION_CONTENT,Name="DRIVING_UTVEHICLE_SCORPION_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_SPMA_CONTENT,Name="DRIVING_UTVEHICLE_SPMA_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_STEALTHBENDER_CONTENT,Name="DRIVING_UTVEHICLE_STEALTHBENDER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_TURRET,Name="DRIVING_UTVEHICLE_TURRET"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_DRIVING_UTVEHICLE_VIPER_CONTENT,Name="DRIVING_UTVEHICLE_VIPER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_CICADA_CONTENT,Name="VEHICLEKILL_UTVEHICLE_CICADA_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_DARKWALKER_CONTENT,Name="VEHICLEKILL_UTVEHICLE_DARKWALKER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_FURY_CONTENT,Name="VEHICLEKILL_UTVEHICLE_FURY_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_GOLIATH_CONTENT,Name="VEHICLEKILL_UTVEHICLE_GOLIATH_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_HELLBENDER_CONTENT,Name="VEHICLEKILL_UTVEHICLE_HELLBENDER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_HOVERBOARD,Name="VEHICLEKILL_UTVEHICLE_HOVERBOARD"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_LEVIATHAN_CONTENT,Name="VEHICLEKILL_UTVEHICLE_LEVIATHAN_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_MANTA_CONTENT,Name="VEHICLEKILL_UTVEHICLE_MANTA_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_NEMESIS,Name="VEHICLEKILL_UTVEHICLE_NEMESIS"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_NIGHTSHADE_CONTENT,Name="VEHICLEKILL_UTVEHICLE_NIGHTSHADE_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_PALADIN,Name="VEHICLEKILL_UTVEHICLE_PALADIN"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_RAPTOR_CONTENT,Name="VEHICLEKILL_UTVEHICLE_RAPTOR_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_SCAVENGER_CONTENT,Name="VEHICLEKILL_UTVEHICLE_SCAVENGER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_SCORPION_CONTENT,Name="VEHICLEKILL_UTVEHICLE_SCORPION_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_SPMA_CONTENT,Name="VEHICLEKILL_UTVEHICLE_SPMA_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_STEALTHBENDER_CONTENT,Name="VEHICLEKILL_UTVEHICLE_STEALTHBENDER_CONTENT"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_TURRET,Name="VEHICLEKILL_UTVEHICLE_TURRET"))
ColumnMappings.Add((Id=`STATS_COLUMN_DM_VEHICLES_ALLTIME_VEHICLEKILL_UTVEHICLE_VIPER_CONTENT,Name="VEHICLEKILL_UTVEHICLE_VIPER_CONTENT"))
}
