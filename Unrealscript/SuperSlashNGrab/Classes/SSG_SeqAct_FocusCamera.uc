class SSG_SeqAct_FocusCamera extends SequenceAction;

var() Actor FocalPoint;

event Activated()
{
	local WorldInfo TheWorld;
	local SSG_GameInfo TheGame;

	TheWorld = class'WorldInfo'.static.GetWorldInfo();
	TheGame = SSG_GameInfo(TheWorld.Game);
	if(TheGame != none)
	{
		TheGame.FocusCameraOnPosition(FocalPoint);
	}
}

DefaultProperties
{
	ObjName="Focus Camera"
	ObjCategory="SSG Actions"

	
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="Focus Object",PropertyName=FocalPoint)
}
