class SSG_DroppedPickup_Objective extends DroppedPickup;

//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();
	SSG_GameInfo( WorldInfo.Game ).RegisterObjective( self );
}

//----------------------------------------------------------------------------------------------------------
function GiveTo( Pawn P )
{
	local SSG_Pawn ssgPawn;
	local SSG_Inventory_Objective Objective;

	ssgPawn = SSG_Pawn( P );
	if( ssgPawn == None )
		return;

	Objective = SSG_Inventory_Objective( Inventory );

	Inventory.AnnouncePickup(P);
	Objective.GiveObjectiveTo( ssgPawn );
	Inventory = None;

	PickedUpBy(P);
	SSG_GameInfo( WorldInfo.Game ).CurrentObjective = None;
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	LifeSpan=+99999.0
}
