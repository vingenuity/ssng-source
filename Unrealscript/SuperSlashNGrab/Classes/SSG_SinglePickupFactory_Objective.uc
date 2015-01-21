class SSG_SinglePickupFactory_Objective extends SSG_SinglePickupFactory
	ClassGroup( Pickups, Treasure )
	placeable;

var() class<SSG_Inventory_Objective> ObjectivePickupClass;

//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();
	SSG_GameInfo( WorldInfo.Game ).RegisterObjective( self );
}

//----------------------------------------------------------------------------------------------------------
function bool CheckForErrors()
{
	if ( Super.CheckForErrors() )
		return true;

	if ( ObjectivePickupClass == None )
	{
		`log(self$" no objective pickup class");
		return true;
	}

	return false;
}

//----------------------------------------------------------------------------------------------------------
simulated function InitializePickup()
{
	InventoryType = ObjectivePickupClass;
	if ( InventoryType == None )
	{
		GotoState('Disabled');
		return;
	}

	Super.InitializePickup();
}

//----------------------------------------------------------------------------------------------------------
function SpawnCopyFor( Pawn Recipient )
{
	local SSG_Pawn GamePawn;
	local class<SSG_Inventory_Objective> ObjectiveType;
	local SSG_Inventory_Objective Objective;

	GamePawn = SSG_Pawn( Recipient );
	ObjectiveType = class<SSG_Inventory_Objective>( InventoryType );
	if( GamePawn != None && ObjectiveType != None )
	{
		Objective = Spawn( ObjectiveType );
		Objective.GiveObjectiveTo( GamePawn );
	}

	SSG_GameInfo( WorldInfo.Game ).CurrentObjective = None;
	//Recipient.MakeNoise(0.1);
}

DefaultProperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EditorSprites.CrownSprite'
		Scale=0.25
	End Object
}
