class SSG_SeqAct_ShowTimer extends SequenceAction;

var() bool MakeVisible;

event Activated()
{
	local WorldInfo TheWorld;
	local SSG_PlayerController CurrentController;
	local SSG_HUD_Base HUDasSSGHUD;

	TheWorld = class'WorldInfo'.static.GetWorldInfo();
	foreach TheWorld.AllControllers(class'SSG_PlayerController', CurrentController)
	{
		HUDasSSGHUD = SSG_HUD_Base(CurrentController.myHUD);
		if(HUDasSSGHUD != none)
		{
			HUDasSSGHUD.InGameHUD.EnrageTimer.SetVisible(MakeVisible);
		}
	}
}

DefaultProperties
{
	ObjName="Show Timer"
	ObjCategory="SSG Actions"
	MakeVisible=true
}
