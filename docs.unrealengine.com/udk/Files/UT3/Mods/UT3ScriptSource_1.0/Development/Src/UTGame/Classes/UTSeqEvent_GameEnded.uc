﻿class UTSeqEvent_GameEnded extends SequenceEvent;

/** The winner of the game. In Deathmatch, the player with the final kill; in other gametypes, the home base of the winning team */
var Actor Winner;
/** the "real" winner of the game - the actual player that won in FFA games or the TeamInfo of the team that won in a team game
 * yes, this variable name is bad - that's what happens when you have to fix up bad design afterwards ;)
 */
var Actor ActualWinner;

event Activated()
{
	local UTGame Game;

	Game = UTGame(GetWorldInfo().Game);
	if (Game != None)
	{
		Winner = Game.EndGameFocus;
		ActualWinner = Game.GameReplicationInfo.Winner;
		if (PlayerReplicationInfo(ActualWinner) != None)
		{
			// controllers are better for Kismet handling
			ActualWinner = Controller(ActualWinner.Owner);
		}
	}
}

defaultproperties
{
	ObjClassVersion=2
	ObjName="Game Ended"
	bPlayerOnly=false
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Focus Actor",bWriteable=true,PropertyName=Winner)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Winning Player/Team",bWriteable=true,PropertyName=ActualWinner)
}
