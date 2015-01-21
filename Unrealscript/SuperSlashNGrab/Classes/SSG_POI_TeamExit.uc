class SSG_POI_TeamExit extends UDKGameObjective
	ClassGroup( Common, PlayerExit )
	placeable;

var() bool DrawExitRadius;
var() float ExitRadiusUnrealUnits;

//----------------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	local vector TopOfCylinder, BottomOfCylinder;
	TopOfCylinder = self.location;
	TopOfCylinder.z += 60.0;
	BottomOfCylinder = self.location;
	BottomOfCylinder.z -= 60.0;

	super.PostBeginPlay();
	
	if( DrawExitRadius )
		DrawDebugCylinder( BottomOfCylinder, TopOfCylinder, ExitRadiusUnrealUnits, 40, 255, 255, 255, true );

	if ( Role < ROLE_Authority )
		return;

	SSG_GameInfo( WorldInfo.Game ).RegisterTeamExit( self );
}

function bool PawnIsInRadius( Pawn ChosenPawn )
{
	local Vector VectorToChosenPawn;

	VectorToChosenPawn = ChosenPawn.Location - Location;
	if( VSize( VectorToChosenPawn ) < ExitRadiusUnrealUnits )
		return true;

	return false;
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	DrawExitRadius=false
	ExitRadiusUnrealUnits=70

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorSprites.ExitSignSprite'
		Scale=0.25
	End Object
}
