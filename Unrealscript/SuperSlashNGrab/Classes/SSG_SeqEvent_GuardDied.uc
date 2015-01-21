class SSG_SeqEvent_GuardDied extends SequenceEvent;


var() int SectionNumber;

var() Vector GuardroomLocation;

var() Actor SpawnLocation;

//TODO this will eventually be changed to grab the centroid of spawn locations for a room or somesuch
function vector GetGuardroomLocation()
{
	local SeqVar_ObjectList spawnsAsList;
	local SeqVar_Object currentSpawn;
	local Object temp;
	local Vector bestFitLocation;
	local Vector currentLocation;
	local float nextWeight;
	local int i;

	spawnsAsList = SeqVar_ObjectList(VariableLinks[0].LinkedVariables[0]);
	

	if(spawnsAsList != none)
	{
		nextWeight = 0;
		for(i = 0; i < spawnsAsList.ObjList.Length; i++)
		{
			temp = spawnsAsList.ObjList[i];
			currentLocation = GetLocationFromSeqVarObject(temp);
			if(nextWeight == 0)
			{
				bestFitLocation = currentLocation;
			}
			nextWeight += 1;
			bestFitLocation = (bestFitLocation * (nextWeight/(nextWeight+1))) + (currentLocation * (1/(nextWeight+1)));
		}
	}
	else
	{
		currentSpawn = SeqVar_Object(VariableLinks[0].LinkedVariables[0]);
		temp = currentSpawn.GetObjectValue();
		bestFitLocation = GetLocationFromSeqVarObject(temp);
	}
	GuardroomLocation = bestFitLocation;
	return bestFitLocation;
}

function Vector GetLocationFromSeqVarObject(Object in)
{
		local Actor spawnAsActor;
		local Vector spawnLoc;

		spawnAsActor = Actor(in);
		if (spawnAsActor != none)
		{
			spawnLoc = spawnAsActor.Location;
		}

		return spawnLoc;
}

DefaultProperties
{

	ObjName="Guard Dies"
	ObjCategory="Super Slash N Grab"

	VariableLinks(1)=(ExpectedType=class'SeqVar_Object',LinkDesc="SpawnLocation",bWriteable=TRUE)
}
