class SeqAct_SSGAttractGuard extends SequenceAction;

var() Object AttractorTarget;

event Activated()
{
	local SSG_Bot BotController;
	local WorldInfo TheRealWorld;
	local Actor theRealTarget;
	local Vector TargetLocation;

	TheRealWorld = class'WorldInfo'.static.GetWorldInfo();
	theRealTarget = Actor(AttractorTarget);

	if(AttractorTarget != none)
	{
		TargetLocation = theRealTarget.Location;
		foreach TheRealWorld.AllActors(class'SSG_Bot', BotController)
		{
			BotController.DoAlertGuard(TargetLocation);
		}
	}
	else
	{
		`log("SSG KISMET ERROR: Attract Guard"@self@"has no valid target");
	}
}

DefaultProperties
{

	ObjName="Attract Guard"
	ObjCategory="SSG Actions"

	bCallHandler = false

	VariableLinks.Empty
	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="Location",PropertyName=AttractorTarget)
}
