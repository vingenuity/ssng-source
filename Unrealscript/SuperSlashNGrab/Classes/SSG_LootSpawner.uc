class SSG_LootSpawner extends Actor;

//----------------------------------------------------------------------------------------------------------
var int		NumSmallTreasureToDrop;
var int		NumMediumTreasureToDrop;
var int		NumLargeTreasureToDrop;
var float	ThrowForce;
var float   TreasureThrowAngle; // [0, 180] where 0 is straight forward and 180 is any XY direction
var float   SecondsBetweenThrows;
var float   SecondsSinceLastThrow;


//----------------------------------------------------------------------------------------------------------
function Vector CalculateRandom2DVector( float vectorLength )
{
    local Vector randomVector, rotVector;
	local float angleDeg, adjustedAngleDeg;

	rotVector = Vector( self.Rotation );
    randomVector = VRand();
    randomVector.Z = 0.25 * abs( randomVector.Z );

	angleDeg = RadToDeg * acos( Normal( Vector( self.Rotation ) ) dot Normal( randomVector ) );
	adjustedAngleDeg = ( RadToDeg * atan2( rotVector.Y, rotVector.X ) ) + ( 1.0 - ( 2.0 * Rand(2) ) ) * angleDeg * ( TreasureThrowAngle / 180.0 );
	randomVector.X = cos( DegToRad * adjustedAngleDeg );
	randomVector.Y = sin( DegToRad * adjustedAngleDeg );
	randomVector = Normal( randomVector ) * vectorLength;

    return randomVector;
}


//----------------------------------------------------------------------------------------------------------
function TossInventory(Inventory Inv, optional vector ForceVelocity)
{
	local vector	POVLoc, TossVel;
	local rotator	POVRot;
	local Vector	X,Y,Z;

	if ( ForceVelocity != vect(0,0,0) )
	{
		TossVel = ForceVelocity;
	}
	else
	{
		GetActorEyesViewPoint(POVLoc, POVRot);
		TossVel = Vector(POVRot);
		TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);
	}

	GetAxes(Rotation, X, Y, Z);
	Inv.DropFrom( Location, TossVel );
}


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();
	SecondsSinceLastThrow = SecondsBetweenThrows;
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	SecondsSinceLastThrow += DeltaTime;
	ThrowTreasure();
}


//----------------------------------------------------------------------------------------------------------
function ThrowTreasure()
{
	local int TreasureType;
	local bool ThrownTreasure;
	local Inventory tossedTreasure;

	if( SecondsSinceLastThrow < SecondsBetweenThrows )
		return;

	if( NumSmallTreasureToDrop == 0 && NumMediumTreasureToDrop == 0 && NumLargeTreasureToDrop == 0 )
	{
		Destroy();
		return;
	}

	ThrownTreasure = false;
	while( !ThrownTreasure )
	{
		TreasureType = Rand(3);
		if( TreasureType == 0 && NumSmallTreasureToDrop > 0 )
		{
			tossedTreasure = Spawn( class'SSG_Inventory_Treasure_Small' );
			TossInventory( tossedTreasure, CalculateRandom2DVector( ThrowForce ) );
			--NumSmallTreasureToDrop;
			ThrownTreasure = true;
		}
		else if( TreasureType == 1 && NumMediumTreasureToDrop > 0 )
		{
			tossedTreasure = Spawn( class'SSG_Inventory_Treasure_Medium' );
			TossInventory( tossedTreasure, CalculateRandom2DVector( ThrowForce ) );
			--NumMediumTreasureToDrop;
			ThrownTreasure = true;
		}
		else if( TreasureType == 2 && NumLargeTreasureToDrop > 0 )
		{
			tossedTreasure = Spawn( class'SSG_Inventory_Treasure_Large' );
			TossInventory( tossedTreasure, CalculateRandom2DVector( ThrowForce ) );
			--NumLargeTreasureToDrop;
			ThrownTreasure = true;
		}
	}

	SecondsSinceLastThrow = 0.0;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	bCollideActors=false
	bBlockActors=false

	NumSmallTreasureToDrop=0
	NumMediumTreasureToDrop=0
	NumLargeTreasureToDrop=0
	ThrowForce=500.0
	TreasureThrowAngle=180.0
	SecondsBetweenThrows=0.05
	SecondsSinceLastThrow=0.0
}
