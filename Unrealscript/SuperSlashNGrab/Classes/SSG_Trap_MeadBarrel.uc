class SSG_Trap_MeadBarrel extends SSG_Trap_Base
	placeable;

//----------------------------------------------------------------------------------------------------------
//var Vector                      SpawnOffset;
var ParticleSystem              BreakParticle;
var(SSG_Trap_Base) float        FresnelGlowMinDistance;
var(SSG_Trap_Base) float        FresnelGlowMaxDistance;
var(SSG_Trap_Base) float		SecondsToReachMaxPuddle;
var(SSG_Trap_Base) float		PlayerDrunkLengthSeconds;
var(Sounds) SoundCue            BreakSoundCue;


//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	//local float RotationYawUnrRot;
	//local Vector AngleAdjustedSpawnOffset;

	TrapMeshMIC = StaticMesh.CreateAndSetMaterialInstanceConstant(0);
	Super.PostBeginPlay();

	//RotationYawUnrRot = Rotation.Yaw * UnrRotToRad;
	//AngleAdjustedSpawnOffset.X = SpawnOffset.X * cos( RotationYawUnrRot ) - SpawnOffset.Y * sin( RotationYawUnrRot );
	//AngleAdjustedSpawnOffset.Y = SpawnOffset.Y * cos( RotationYawUnrRot ) + SpawnOffset.X * sin( RotationYawUnrRot );
	//AngleAdjustedSpawnOffset.Z = SpawnOffset.Z;
	//SpawnOffset = AngleAdjustedSpawnOffset;
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
	//SetFresnelGlow();
}


//----------------------------------------------------------------------------------------------------------
function SetFresnelGlow()
{
	local float FresnelLevel;
	local float CheckFresnelLevel;
	local float DistanceBetweenPoints;
	local SSG_PlayerController PC;
	local LinearColor FresnelColor;

	FresnelLevel = 0.0;

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
    {
		if( PC.Pawn == None )
			continue;

		DistanceBetweenPoints = VSize( PC.Pawn.Location - self.Location );
		CheckFresnelLevel = 1.0 - ( ( DistanceBetweenPoints - FresnelGlowMinDistance ) / ( FresnelGlowMaxDistance - FresnelGlowMinDistance ) );
		CheckFresnelLevel = FClamp( CheckFresnelLevel, 0.0, 1.0 );
		if( CheckFresnelLevel > FresnelLevel )
			FresnelLevel = CheckFresnelLevel;
    }

	FresnelColor.R = FresnelLevel;
	FresnelColor.G = FresnelLevel;
	FresnelColor.B = FresnelLevel;

	TrapMeshMIC.SetVectorParameterValue( 'Fresnel_Color', FresnelColor );
}


//----------------------------------------------------------------------------------------------------------
event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local SSG_Trap_MeadPuddle Puddle;

	PlaySound( BreakSoundCue );
	Puddle = Spawn( class'SSG_Trap_MeadPuddle', Self, , ( Location /*+ SpawnOffset*/ ) );

	if( Puddle != None )
	{
		Puddle.SecondsToReachMaxSize = SecondsToReachMaxPuddle;
		Puddle.SecondsOfActivation = Self.SecondsOfActivation;
		Puddle.PlayerControllerRandomControlSeconds = PlayerDrunkLengthSeconds;
	}

	WorldInfo.MyEmitterPool.SpawnEmitter(BreakParticle, ( Location /*+ SpawnOffset*/ ), rotator(/*HitNormal*/Momentum), self);
	
	Destroy();
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	TickGroup=TG_PreAsyncWork
	FresnelGlowMinDistance=250
	FresnelGlowMaxDistance=350
	SecondsToReachMaxPuddle=1.0
	PlayerDrunkLengthSeconds=6.0
	SecondsOfActivation=30.0

	//SpawnOffset=(X=-63.0,Y=-76.0,Z=2.0)

	BreakSoundCue=SoundCue'SSG_TrapSounds.MeadTrap.MeadBreakCue'
	BreakParticle=ParticleSystem'SSG_Trap_Particles.Mead.SSG_Particles_Mead_Spray_PS_01'

	Begin Object Name=TrapStaticMeshComponent
		StaticMesh=StaticMesh'SSG_Traps.Mead.SSG_Trap_Mead_01'
	End Object
}
