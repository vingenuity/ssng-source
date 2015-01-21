class SSG_ActorFactory_Guard extends ActorFactoryAI;

var() string PathNameToGive;
var() Actor StationaryTargetToGive;
var() int SectionNumber;
var() bool bSpawnsCuriousBots;

var class<AIController> NextController;

struct SpawnProbability
{
	var() class<SSG_Pawn_Bot> SpawnClass;
	var() int SpawnPercent;
};

var() array<SpawnProbability> SpawnChance; 



simulated event PostCreateActor(Actor NewActor, optional const SeqAct_ActorFactory ActorFactoryData)
{
	local SSG_Bot botController;
	local SSG_Pawn_Bot newActorAsPawn;

	newActorAsPawn = SSG_Pawn_Bot(NewActor);
	//newActorAsPawn.Controller = newActorAsPawn.Spawn( newActorAsPawn.default.ControllerClass, newActorAsPawn);
	if(newActorAsPawn != none)
	{
		newActorAsPawn.PatrolName = PathNameToGive;
		newActorAsPawn.SectionNumber = SectionNumber;
		botController = SSG_Bot(newActorAsPawn.Controller);
		if(botController != none)
		{
			botController.PathName = PathNameToGive;
			botController.StationaryOrientationTarget = StationaryTargetToGive;
			botController.bIsCurious = bSpawnsCuriousBots;
		}
	}
	SelectNextSpawnType();
}

function SelectNextSpawnType()
{
	local class<SSG_Pawn_Bot> NextSpawn;
	local int SpawnSelection;
	local SpawnProbability ProbabilityIndex;
	local int TotalSpawnChance;
	local int CurrentAggregateSpawnChance;
	local bool FoundCorrectSpawnType;

	ControllerClass = NextController;
	if(SpawnChance.Length > 0)
	{
		TotalSpawnChance = 0;
		foreach SpawnChance(ProbabilityIndex)
		{
			TotalSpawnChance += ProbabilityIndex.SpawnPercent;
		}

		SpawnSelection = Rand(TotalSpawnChance);
		CurrentAggregateSpawnChance = 0;
		FoundCorrectSpawnType = false;

		foreach SpawnChance(ProbabilityIndex)
		{
			CurrentAggregateSpawnChance += ProbabilityIndex.SpawnPercent;
			if(!FoundCorrectSpawnType && CurrentAggregateSpawnChance > SpawnSelection)
			{
				FoundCorrectSpawnType = true;
				NextSpawn = ProbabilityIndex.SpawnClass;
			}
		}

		PawnClass = NextSpawn;
		NextController = PawnClass.default.ControllerClass; //TODO BUG: shield bots DO NOT SPAWN WITH SHIELD AI
	}
}

DefaultProperties
{
	ControllerClass=class'SSG_Bot'
	PawnClass=class'SSG_Pawn_Bot'
	NextController=class'SSG_Bot'
	SectionNumber=-1
	bSpawnsCuriousBots=false
}
