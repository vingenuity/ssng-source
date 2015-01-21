class SSG_Trap_MeadPuddle extends SSG_Trap_Base;

//----------------------------------------------------------------------------------------------------------
var Vector                      Scale3D;
var float						PlayerControllerRandomControlSeconds;
var float						SecondsToReachMaxSize;
var float						SecondsToFadeOut;
//var Array< SSG_Pawn >           CollidingPawns;
var ParticleSystem              SplashParticle;

//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	local Rotator randomRotation;

	TrapMeshMIC = StaticMesh.CreateAndSetMaterialInstanceConstant(0);
	Super.PostBeginPlay();

	randomRotation.Yaw = FRand() * 360.0 * DegToUnrRot;
	SetRotation( randomRotation );
}


//----------------------------------------------------------------------------------------------------------
function Tick( float DeltaTime )
{
	SetPuddleOpacity();

	if( SecondsSinceActive >= SecondsOfActivation )
	{
		//UntouchCollidingPawns();
		Destroy();
		return;
	}

	Super.Tick( DeltaTime );

	SetPuddleSize();
}


//----------------------------------------------------------------------------------------------------------
function SetPuddleOpacity()
{
	local float PuddleAlpha;

	PuddleAlpha = ( SecondsOfActivation - SecondsSinceActive ) / SecondsToFadeOut;
	PuddleAlpha = FClamp( PuddleAlpha, 0.0, 1.0 );
	TrapMeshMIC.SetScalarParameterValue( 'PuddleAlpha', PuddleAlpha );
}


//----------------------------------------------------------------------------------------------------------
function SetPuddleSize()
{
	if( Scale3D.X >= 1.0 || Scale3D.Y >= 1.0 )
		return;

	Scale3D.X = ( SecondsSinceActive / SecondsToReachMaxSize );
	Scale3D.Y = ( SecondsSinceActive / SecondsToReachMaxSize );

	if( Scale3D.X > 1.0 )
		Scale3D.X = 1.0;
	if( Scale3D.Y > 1.0 )
		Scale3D.Y = 1.0;

	SetDrawScale3D( Scale3D );
}


//----------------------------------------------------------------------------------------------------------
//event Touch( Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal )
//{
//	local SSG_Pawn SSGP;
//	local SSG_PlayerController PC;
//	local SSG_Bot BotController;

//	if( !bTrapActive )
//		return;

//	SSGP = SSG_Pawn( Other );
//	if( SSGP != None )
//	{
//		CollidingPawns.AddItem( SSGP );
//		WorldInfo.MyEmitterPool.SpawnEmitter(SplashParticle, HitLocation, rotator(HitNormal), Other);

//		PC = SSG_PlayerController( SSGP.Controller );
//		if( PC != None && PC.ControlType == 0 )
//		{
//			PC.RandomControlsLengthSeconds = PlayerControllerRandomControlSeconds;
//			PC.SetRandomControlType();
//			PC.NumMeadPuddlesTouching += 1;
//			SSGP.SpawnConfusionEffect();
//		}
//		else
//		{
//			BotController = SSG_Bot(SSGP.Controller);
//			if(BotController != none)
//			{
//				BotController.DoMead();
//			}
//		}
//	}
//}


//----------------------------------------------------------------------------------------------------------
//event UnTouch( Actor Other )
//{
//	local SSG_Pawn SSGP;
//	local SSG_PlayerController PC;

//	SSGP = SSG_Pawn( Other );
//	if( SSGP != None )
//	{
//		CollidingPawns.RemoveItem( SSGP );

//		PC = SSG_PlayerController( SSGP.Controller );
//		if( PC != None )
//		{
//			PC.NumMeadPuddlesTouching = Clamp( PC.NumMeadPuddlesTouching - 1, 0, MaxInt );
//		}
//	}
//}


//----------------------------------------------------------------------------------------------------------
//simulated function UntouchCollidingPawns()
//{
//	local SSG_Pawn SSGP;
//	local SSG_PlayerController PC;

//	foreach CollidingPawns( SSGP )
//	{
//		PC = SSG_PlayerController( SSGP.Controller );
//		if( PC != None )
//		{
//			PC.NumMeadPuddlesTouching = Clamp( PC.NumMeadPuddlesTouching - 1, 0, MaxInt );
//		}
//	}
//}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	TickGroup=TG_PreAsyncWork
	bBlockActors=false
	bTrapActive=true
	bActiveAtStart=true

	Scale3D=(X=0.0,Y=0.0,Z=1.0)
	PlayerControllerRandomControlSeconds=3.0
	SecondsToReachMaxSize=5.0
	SecondsToFadeOut=1.5
	SecondsOfActivation=30.0

	Begin Object Name=TrapStaticMeshComponent
		StaticMesh=StaticMesh'SSG_Traps.Mead.SSG_Trap_MeadPuddle_01'
		Materials(0)=DecalMaterial'SSG_Traps.Mead.SSG_Trap_MeadPuddle_DecalMAT_01'
	End Object

	SplashParticle=ParticleSystem'SSG_Trap_Particles.Mead.SSG_Particles_Mead_Spray_PS_01'
	
}
