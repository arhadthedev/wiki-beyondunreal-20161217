﻿class UTSeqAct_PlayAnnouncement extends SequenceAction
	PerObjectLocalized;

var() ObjectiveAnnouncementInfo Announcement;

event Activated()
{
	local WorldInfo WI;

	WI = GetWorldInfo();
	WI.BroadcastLocalizedMessage(class'UTKismetAnnouncement', 0, None, None, self);
}

defaultproperties
{
	bCallHandler=false
	ObjName="Play Announcement"
	ObjCategory="Voice/Announcements"
	VariableLinks.Empty
}
