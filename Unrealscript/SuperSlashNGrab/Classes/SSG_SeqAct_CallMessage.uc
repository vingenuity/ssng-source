class SSG_SeqAct_CallMessage extends SequenceAction;

var() class<SSG_LocalMessage> MessageClass;

var() int MessageIndex;

var() bool bDisplayText;

var() bool bAudio;

event Activated()
{
	local SSG_PlayerController FirstPlayer;

	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', FirstPlayer)
	{
		if(LocalPlayer(FirstPlayer.Player).ControllerId == 0)
		{
			break;
		}
	}

	if(bAudio)
	{
		FirstPlayer.Announcer.PlayAnnouncement(MessageClass, MessageIndex);
	}
	if(bDisplayText)
	{
		FirstPlayer.ReceiveLocalizedMessage(MessageClass, MessageIndex);
	}
}

DefaultProperties
{
	ObjName="CallMessage"
	ObjCategory="SSG Actions"

	bDisplayText=true
	bAudio=true

	VariableLinks.Empty
}
