class SSG_DroppedPickup_Treasure extends DroppedPickup;

//----------------------------------------------------------------------------------------------------------
var float						SecondsBeforePickable;
var float						SecondsSinceSpawn;
var Vector                      HitVelocity;
var() ParticleSystemComponent   SparkleParticleSystem;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetPhysics( PHYS_Falling );
}

//----------------------------------------------------------------------------------------------------------
event EncroachedBy(Actor Other)
{
	//Do nothing
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	if( SecondsSinceSpawn < SecondsBeforePickable )
		SecondsSinceSpawn += DeltaTime;

	if( Velocity.X == 0.0 && Velocity.Y == 0.0 && Velocity.Z == 0.0 )
	{
		Velocity = HitVelocity;
		SetPhysics( PHYS_Falling );
	}
}


//----------------------------------------------------------------------------------------------------------
event Landed( Vector HitNormal, Actor FloorActor )
{
	HitWall( HitNormal, FloorActor, None );
}


//----------------------------------------------------------------------------------------------------------
event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	//Super.HitWall( HitNormal, Wall, WallComp );

	Velocity = 0.6 * ( ( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity );   // Reflect off Wall w/damping
	if( Velocity.Z > 400 )
	{
		Velocity.Z = 0.5 * (400 + Velocity.Z);
	}

	HitVelocity = Velocity;
}


//----------------------------------------------------------------------------------------------------------
function TakeDamage( int Damage, Controller InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

	if( InstigatedBy == None || InstigatedBy.Pawn == None )
		return;

	if( InstigatedBy.Pawn.Weapon.IsA( 'SSG_Weap_Bow' ) )
		return;

	GiveTo( InstigatedBy.Pawn );
}


//----------------------------------------------------------------------------------------------------------
function GiveTo( Pawn P )
{
	local float LootMultiplyer;
	local SSG_Pawn SSGP;
	local SSG_PlayerController ssgPC;
	local SSG_Inventory_Treasure ssgTreasure;

	if( SecondsSinceSpawn < SecondsBeforePickable )
		return;

	SSGP = SSG_Pawn( P );
	if( SSGP == None )
		return;

	ssgPC = SSG_PlayerController( SSGP.Controller );
	if( ssgPC == None )
		return;

	ssgTreasure = SSG_Inventory_Treasure( Inventory );
	if( ssgTreasure == None )
		return;

	LootMultiplyer = 1.0;
	if( SSGP.bDoubleLoot )
		LootMultiplyer = 2.0;

	ssgPC.MoneyEarned += ssgTreasure.MonetaryValue * LootMultiplyer;
	ssgPC.MoneyEarnedSinceLastUpdate += ssgTreasure.MonetaryValue * LootMultiplyer;
	PlaySound( ssgTreasure.PickupSound );
	Destroy();
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	LifeSpan=+99999.0

	SecondsBeforePickable=0.1
	SecondsSinceSpawn=0.0
	HitVelocity=(X=0.0,Y=0.0,Z=0.0)
	RotationRate=(Yaw=10000)

	Begin Object Class=ParticleSystemComponent Name=SparkleParticleSystem
		Template=ParticleSystem'SSG_Environment_Particles.Loot.SSG_Particles_LootSparkles_PS_01'
        bAutoActivate=true
	End Object
	SparkleParticleSystem=SparkleParticleSystem
	Components.Add(SparkleParticleSystem)

	bBlockActors = false
	bNoEncroachCheck = true
}
