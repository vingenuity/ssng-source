class SSG_SeqAct_LockCamera extends SequenceAction;

var() bool bLockCamera;

event Activated()
{
	local WorldInfo TheWorld;
	local SSG_GameInfo TheGame;

	TheWorld = class'WorldInfo'.static.GetWorldInfo();
	TheGame = SSG_GameInfo(TheWorld.Game);
	if(TheGame != none)
	{
		if(bLockCamera)
		{
			TheGame.LockCameraOnPlayers();
		}
		else
		{
			TheGame.UnlockCameraFromPlayers();
		}
	}
}

DefaultProperties
{
	ObjName="Lock Camera"
	ObjCategory="SSG Actions"
	bLockCamera=true
}
