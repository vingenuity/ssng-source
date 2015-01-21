class SSG_SeqAct_SpawnLimiter extends SequenceCondition;

event Activated()
{
	local bool preventSpawn;

	preventSpawn = class'WorldInfo'.static.GetWorldInfo().bDropDetail;
	if(preventSpawn)
	{
		OutputLinks[1].bHasImpulse = true;
		OutputLinks[0].bHasImpulse = false;
	}
	else
	{
		OutputLinks[0].bHasImpulse = true;
		OutputLinks[1].bHasImpulse = false;
	}
}

DefaultProperties
{
	ObjName="LimitSpawns"
	ObjCategory="SSG Actions"

	OutputLinks.Empty
	OutputLinks(0)=(LinkDesc="Spawn", bHasImpulse=false)
	OutputLinks(1)=(LinkDesc="No Spawn", bHasImpulse=false)

	VariableLinks.Empty
}
