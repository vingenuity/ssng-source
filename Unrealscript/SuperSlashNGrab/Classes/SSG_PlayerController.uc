/**
 * Copyright 1998-2014 Epic Games, Inc. All Rights Reserved.
 */
class SSG_PlayerController extends GamePlayerController
	config(Game) dependson(SSG_DamageType);

//----------------------------------------------------------------------------------------------------------
var string ThiefName;

var byte ControlType; // used for mead trap dizzy movement
var Vector X, Y;

var int CurrentOrientationUnrRot;
var int DesiredOrientationUnrRot;
var bool bRightStickOrientation;
var bool bInstantRotation;

var ForceFeedbackWaveform HitRumble;
var ForceFeedbackWaveform DeathRumble;
var ForceFeedbackWaveform RespawnRumble;

var float WalkSpeed;
var float RunSpeed;

var int MoneyEarned;
var int RawMoneyEarned;

var bool bIsDrunk;
var bool bCanControlPlayer;
var int NumMeadPuddlesTouching;
var float DrunkOrientationOffsetUnrRot;
var float RandomControlsLengthSeconds; // for mead trap
var float SecondsSinceRandomControls; // how long since not touching mead puddle

var bool bShowPlayerHUD;
var LinearColor PlayerColors[4];
var int NumTimesBetrayedPlayer[4];
var int LivesLived;
var int IDOfCurrentWeapon;
var int NumKills;
var int NumMeleeKills;
var int NumRangedKills;

// HUD Popup Variables
var int IDOfWeaponPickedUpLastUpdate;
var int MoneyEarnedSinceLastUpdate;
var bool TakenDamageSinceLastUpdate;

var bool bSpawningForFirstTime;
var bool bIsOffscreen;
const MAX_SECONDS_OFFSCREEN_BEFORE_KILLED = 5;
var byte SecondsLeftBeforeKilled;

var array<Vector> ControlInputBuffer;

var int ExitedInPosition;
var int InSectionTransitionNumber; //-1 means in no transition

var array<string> DefaultNames;
var int HackedPlayerNum;

var bool bShiftedPlayerRespawnSelect;

var Vector NextSpawnSpot;
var int NextSpawnPlayerNum;
var bool WaitingOnRespawn;

var bool bIsLost;
var Vector ToNextRoom;


var array<ParticleSystem> SpawnEffect;
var SSG_Respawn_Mesh RespawnSelectionEffect;

var SSG_Announcer Announcer;

var array<string> Superlatives;

var int Highscores[4];

var int LifetimeGold;

var config float MusicGroupVolume;
var config float SoundGroupVolume;
var config float VoiceGroupVolume;
var globalconfig int GraphicsLevelIndex;
var globalconfig bool RumbleOn;

var int TimesDiedToType[DeathCauses.EnumCount];

//----------------------------------------------------------------------------------------------------------
const MAX_TURN_SPEED_DEGREES_PER_SECOND = 720;
const WALK_RUN_DIST_FROM_CENTER_THRESHOLD = 800.0;
const RESPAWN_CHANGE_THRESHOLD = 1000.0;
const ROTATION_DEGREES_DIFFERENCE_BEFORE_SCALING = 45.0;
const MIN_PERLIN_VALUE = 0.75;
const SECONDS_BEFORE_AUTO_RESPAWN = 5.0;
const CONTROLLER_LENGTH_FULL = 1400.0;
const CONTROL_BUFFER_LENGTH = 5;


//----------------------------------------------------------------------------------------------------------
simulated event PostBeginPlay()
{
	local SSG_PlayerController CurrentController;

	super.PostBeginPlay();

	//Volume is 0-100, but the actual value is 0-1.
	SetAudioGroupVolume( 'Music', MusicGroupVolume * 0.01 );
	SetAudioGroupVolume( 'SFX', SoundGroupVolume * 0.01 );
	SetAudioGroupVolume( 'Voice', VoiceGroupVolume * 0.01 );

	//pick a random name
	ThiefName =  DefaultNames[ Rand( DefaultNames.Length ) ];

	if( ForceFeedbackManager != None )
        ForceFeedbackManager.bAllowsForceFeedback = true;

	HackedPlayerNum = 0;
	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentController)
	{
		HackedPlayerNum++;
	}
	NextSpawnPlayerNum = HackedPlayerNum;

	WaitingOnRespawn = false;
	Announcer = Spawn(class'SSG_Announcer', self);
}


//----------------------------------------------------------------------------------------------------------
function float Noise1D( int n )
{
	n = ( n<<13 )^n;
	return ( 1.f - float( ( n * ( n * n * 15731 + 789221 ) + 1376312589 ) & 0x7fffffff ) / 1073741824.f );
}


//----------------------------------------------------------------------------------------------------------
function float SmoothNoise1D( float n )
{
	local int intN;

	intN = int(n);
	return ( Noise1D( intN ) / 2 )  +  ( Noise1D( intN - 1 ) / 4 )  +  ( Noise1D( intN + 1 ) / 4 );
}


//----------------------------------------------------------------------------------------------------------
function float CosineInterpolation( float a, float b, float n )
{
	local float f, ft;

	ft = n * Pi;
	f = 0.5 * ( 1 - cos( ft ) );
	return ( a * ( 1 - f ) ) + ( b * f );
}


//----------------------------------------------------------------------------------------------------------
function float InterpolatedNoise1D( float n )
{
	local float fractionalN, v1, v2;

	fractionalN = n - float( FFloor( n ) );
	n = float( FFloor( n ) );

	v1 = SmoothNoise1D( n );
	v2 = SmoothNoise1D( n + 1 );

	return CosineInterpolation( v1, v2, fractionalN );
}


//----------------------------------------------------------------------------------------------------------
function float PerlinNoise1D( float n, int numOctaves, float persistance )
{
	local int i;
	local float total, frequency, amplitude;

	total = 0.0;
	for( i = 0; i < ( numOctaves - 1 ); ++i )
	{
		frequency = 2 ** i;
		amplitude = persistance ** i;

		total += InterpolatedNoise1D( n * frequency ) * amplitude;
	}

	return total;
}

//----------------------------------------------------------------------------------------------------------
unreliable client event ClientHearSound(SoundCue ASound, Actor SourceActor, vector SourceLocation, bool bStopWhenOwnerDestroyed, optional bool bIsOccluded )
{
	// if( LocalPlayer( Player ).ControllerID != 0 )
	// {
	// 	//`log( "Sound blocked due to player number." );
	// 	return;
	// }

	super.ClientHearSound( ASound, SourceActor, SourceLocation, bStopWhenOwnerDestroyed, bIsOccluded );
}

//----------------------------------------------------------------------------------------------------------
reliable client function ClientSetHUD(class<HUD> newHUDType)
{
	if( LocalPlayer( Player ).ControllerID != 0 )
		return;

	Super.ClientSetHUD( newHUDType );
}

//----------------------------------------------------------------------------------------------------------
function PlayerTick( float DeltaTime )
{
	local SSG_Pawn DrunkPawn;

	Super.PlayerTick( DeltaTime );

	if( NumMeadPuddlesTouching > 0 )
	{
		SecondsSinceRandomControls = 0.0;
	}
	else if( bIsDrunk )
	{
		if( SecondsSinceRandomControls >= RandomControlsLengthSeconds )
		{
			SecondsSinceRandomControls = 0.0;
			bIsDrunk = false;
			DrunkPawn = SSG_Pawn(Pawn);
			DrunkPawn.StopConfusionEffect();
		}
		else
		{
			SecondsSinceRandomControls += DeltaTime;
		}
	}
	if(bIsLost)
	{
		UpdateGuideArrow();
	}

	CheckForRespawnLocationChange();
}

//----------------------------------------------------------------------------------------------------------
function CheckForRespawnLocationChange()
{
	if( Pawn != None )
		return;

	if( PlayerInput.aStrafe < -RESPAWN_CHANGE_THRESHOLD )
	{
		if( !bShiftedPlayerRespawnSelect && !WaitingOnRespawn )
		{
			DecrementPlayerToSpawn();
			bShiftedPlayerRespawnSelect = true;
		}
	}
	else if( PlayerInput.aStrafe > RESPAWN_CHANGE_THRESHOLD )
	{
		if( !bShiftedPlayerRespawnSelect && !WaitingOnRespawn )
		{
			IncrementPlayerToSpawn();
			bShiftedPlayerRespawnSelect = true;
		}
	}
	else
	{
		bShiftedPlayerRespawnSelect = false;
	}
}

//----------------------------------------------------------------------------------------------------------
exec function ShowHUD()
{
	bShowPlayerHUD = true;
}


//----------------------------------------------------------------------------------------------------------
exec function HideHUD()
{
	bShowPlayerHUD = false;
}


//----------------------------------------------------------------------------------------------------------
simulated function byte GetTeamNum()
{
	return 0;
}


//----------------------------------------------------------------------------------------------------------
function KilledPlayer( int VictimControllerID )
{
	local int AnnouncementID;
	local int KillerControllerID;
	local SSG_PlayerController FirstPlayer;

	KillerControllerID = LocalPlayer( Player ).ControllerId;
	AnnouncementID = ( KillerControllerID * 4 ) + VictimControllerID;

	NumTimesBetrayedPlayer[ VictimControllerID ] += 1;

	foreach WorldInfo.AllControllers(class'SSG_PlayerController', FirstPlayer)
	{
		if(LocalPlayer(FirstPlayer.Player).ControllerId == 0)
		{
			break;
		}
	}
	FirstPlayer.Announcer.PlayAnnouncement(class'SSG_Message_KilledPlayer', AnnouncementID);
	FirstPlayer.ReceiveLocalizedMessage(class'SSG_Message_KilledPlayer', AnnouncementID);
}


//----------------------------------------------------------------------------------------------------------
function UpdateGuideArrow()
{
	local Vector Goal;
	local SSG_POI_TeamExit singularTeamExit;
	//local SSG_Pawn PawnAsSSGPawn;
	local Vector ClampedToGoal;

	if(Pawn != none) //no arrow when they're dead
	{
		//PawnAsSSGPawn = SSG_Pawn(Pawn);

		foreach WorldInfo.AllNavigationPoints(class'SSG_POI_TeamExit', singularTeamExit)
		{
			Goal = singularTeamExit.Location;
		}

		NavigationHandle.ClearConstraints();
		NavigationHandle.PathGoalList = none;
		NavigationHandle.SetFinalDestination(Goal);
		class'NavmeshPath_Toward'.static.TowardPoint(NavigationHandle,Goal);
		class'NavMeshGoal_At'.static.AtLocation(NavigationHandle, Goal);
		if(NavigationHandle.PointReachable(Goal))
		{
			ClampedToGoal = ClampLength(Goal - Pawn.Location, 128.0);
			//WorldInfo.MyEmitterPool.SpawnEmitter(PawnAsSSGPawn.DirectionalArrow, Pawn.Location + ClampedToGoal,  , Pawn);
			ToNextRoom = ClampedToGoal;
		}
		else
		{
			NavigationHandle.FindPath();
			NavigationHandle.GetNextMoveLocation( Goal, 56);
			ClampedToGoal = ClampLength(Goal - Pawn.Location, 128.0);
			//WorldInfo.MyEmitterPool.SpawnEmitter(PawnAsSSGPawn.DirectionalArrow, Pawn.Location + ClampedToGoal,  , Pawn);
			ToNextRoom = ClampedToGoal;
		}
	}
	else
	{
		ToNextRoom = vect(0,0,0);
	}
}


//----------------------------------------------------------------------------------------------------------
event OnLost(SSG_SeqAct_Lost Action)
{
	UpdateGuideArrow();
	bIsLost = true;
}

//----------------------------------------------------------------------------------------------------------
event OnNotLost(SSG_SeqAct_NotLost Action)
{
	bIsLost = false;
}


//+++++++++++++++++++++++++++++++++++++++++ Controller Interaction +++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
exec simulated function SetControlType( byte NewControlType )
{
	if( NewControlType == 0 )
	{
		bIsDrunk = false;
	}
	else
	{
		bIsDrunk = true;
	}

	return;

	ControlType = NewControlType;

	switch( ControlType )
	{
		case 0:
			X.X = 1.0;
			X.Y = 0.0;
			Y.X = 0.0;
			Y.Y = 1.0;
			break;

		case 1:
			X.X = -1.0;
			X.Y = 0.0;
			Y.X = 0.0;
			Y.Y = 1.0;
			break;

		case 2:
			X.X = 1.0;
			X.Y = 0.0;
			Y.X = 0.0;
			Y.Y = -1.0;
			break;

		case 3:
			X.X = -1.0;
			X.Y = 0.0;
			Y.X = 0.0;
			Y.Y = -1.0;
			break;

		case 4:
			X.X = 0.0;
			X.Y = 1.0;
			Y.X = 1.0;
			Y.Y = 0.0;
			break;

		case 5:
			X.X = 0.0;
			X.Y = -1.0;
			Y.X = 1.0;
			Y.Y = 0.0;
			break;

		case 6:
			X.X = 0.0;
			X.Y = 1.0;
			Y.X = -1.0;
			Y.Y = 0.0;
			break;

		case 7:
			X.X = 0.0;
			X.Y = -1.0;
			Y.X = -1.0;
			Y.Y = 0.0;
			break;
	}
}

//----------------------------------------------------------------------------------------------------------
simulated function SetRandomControlType()
{
	SetControlType( Rand(7) + 1 );
}

exec function RumbleNow()
{
	StartNewControllerRumble( HitRumble );
}

//----------------------------------------------------------------------------------------------------------
function StartNewControllerRumble( ForceFeedbackWaveform RumbleWaveform )
{
    if( RumbleOn && ForceFeedbackManager != None )
    {
        ForceFeedbackManager.PlayForceFeedbackWaveform( None, None );
        ForceFeedbackManager.PlayForceFeedbackWaveform( RumbleWaveform, None );
    }
}

//----------------------------------------------------------------------------------------------------------
function StopControllerRumble()
{
    //ClientStopForceFeedbackWaveform( RumbleWaveform );
    ForceFeedbackManager.PlayForceFeedbackWaveform( None, None );
    `log( "Stop Rumble" );
}

//----------------------------------------------------------------------------------------------------------
event SpawnPlayerCamera()
{
	local class<SSG_Camera_SharedMulti> GameCameraClass;
	local SSG_GameInfo gameInfo;

	if ( CameraClass == None )
	{
		// not having a CameraClass is fine.  Another class will handing the "camera" type duties
		// usually PlayerController
	}

	GameCameraClass = class<SSG_Camera_SharedMulti>( CameraClass );
	if( GameCameraClass == None )
	{
		`warn( "No multiplayer camera found. Spawning a single player camera." );
		super.SpawnPlayerCamera(); //If we aren't the 4 player specialty camera, let the old code handle it
	}

	gameInfo = SSG_GameInfo( WorldInfo.Game );
	if( gameInfo != None )
	{
		PlayerCamera = gameInfo.GameCamera;
		gameInfo.GameCamera.AttachController( self );
		PlayerCamera.InitializeFor( self );
	}
}

//----------------------------------------------------------------------------------------------------------
function PawnDied(Pawn P)
{
	//IDOfCurrentWeapon = 1; you now keep you weapon when you die
	
	Super.PawnDied( P );
	IncrementPlayerToSpawn(); //Done to guarantee that the player will try to find another pawn at the time of their death
}

//----------------------------------------------------------------------------------------------------------
//This is an exact copy of PlayerController's Restart, with one important change.
function Restart(bool bVehicleTransition)
{
	Super(Controller).Restart(bVehicleTransition);
	ServerTimeStamp = 0;
	ResetTimeMargin();
	EnterStartState();
	ClientRestart(Pawn);
	//SetViewTarget(Pawn); //This screws with our camera
	ResetCameraMode();

	++LivesLived;
	if( myHUD != None )
		SSG_HUD_Base( myHUD ).InGameHUD.SetPlayerName( LocalPlayer( Player ).ControllerID, ThiefName, LivesLived );
}

//----------------------------------------------------------------------------------------------------------
function DelayedSpawn()
{
	local SSG_GameInfo RealGameInfo;
	local int pNum;

	WaitingOnRespawn = false;
	pNum = LocalPlayer(Player).ControllerId;
	WorldInfo.MyEmitterPool.SpawnEmitter(SpawnEffect[pNum], NextSpawnSpot);
	Pawn = Spawn( class'SSG_Pawn',,,NextSpawnSpot, rot( 0, 0, 0 ),, true );//HACK should reference default type
	RealGameInfo = SSG_GameInfo(WorldInfo.Game);
	RealGameInfo.PostRespawn(self);
	StartNewControllerRumble( RespawnRumble );
	
	if( RespawnSelectionEffect != None )
		RespawnSelectionEffect.SetHidden( true );
}

//----------------------------------------------------------------------------------------------------------
exec function SelectPlayerToSpawn(int PlayerSelectionNum)
{
	local SSG_PlayerController CurrentController;
	local SSG_POI_PlayerStart InitPlayerStart;
	local LocalPlayer CurrentPlayer;

	if( LivesLived <= 0 )
	{
		foreach WorldInfo.AllActors( class'SSG_POI_PlayerStart', InitPlayerStart )
		{
			if( InitPlayerStart.PlayerNum == PlayerSelectionNum )
			{
				NextSpawnSpot = InitPlayerStart.Location;
			}
		}
	}
	else
	{
		foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentController)
		{
			CurrentPlayer = LocalPlayer(CurrentController.Player);
			if(CurrentPlayer.ControllerId == PlayerSelectionNum)
			{
				if(CurrentController.Pawn != none)
				{
					NextSpawnSpot = CurrentController.Pawn.Location;
				}
				else
				{
					NextSpawnSpot = vect(0,0,0);
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
exec function IncrementPlayerToSpawn()
{

	local SSG_PlayerController CurrentController;
	local SSG_POI_PlayerStart CheckpointStart;
	local LocalPlayer CurrentPlayer;
	local bool AllPlayersDead;
	local bool FoundPlayer;
	local bool Looped;

	if( LivesLived <= 0 )
	{
		IncrementInitLocationToSpawn();
		return;
	}

	AllPlayersDead = true;
	FoundPlayer = false;
	Looped = false;

	while(!FoundPlayer)
	{
		NextSpawnPlayerNum++;
		if(NextSpawnPlayerNum == LocalPlayer(Player).ControllerId)
		{
			NextSpawnPlayerNum++;
		}

		if(NextSpawnPlayerNum >= 4)
		{
			if(Looped)
			{
				NextSpawnPlayerNum = LocalPlayer(Player).ControllerId;
				FoundPlayer = true; //failsafe
				if(RespawnSelectionEffect != none)
				{
					RespawnSelectionEffect.SetHidden(true);
				}
			}
			NextSpawnPlayerNum = 0;
			Looped = true;
		}

		foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentController)
		{
			CurrentPlayer = LocalPlayer(CurrentController.Player);
			if(CurrentPlayer.ControllerId == NextSpawnPlayerNum && CurrentController != self)
			{
				if(CurrentController.Pawn != none)
				{
					AllPlayersDead = false;
					FoundPlayer = true;
					if( IsInState('Dead') || IsInState('PlayerWaiting') )
					{
						//TODO change this out once final art exists
						if(RespawnSelectionEffect == none)
						{
							RespawnSelectionEffect = Spawn(class'SSG_Respawn_Mesh');
							RespawnSelectionEffect.SelectorMesh.SetStaticMesh(RespawnSelectionEffect.StaticMeshArray[LocalPlayer(Player).ControllerId]);
							RespawnSelectionEffect.SelectorMesh.SetMaterial(0, RespawnSelectionEffect.MaterialArray[LocalPlayer(Player).ControllerId]);
							RespawnSelectionEffect.SetOwner(self);
						}
						RespawnSelectionEffect.SetHidden(false);
						RespawnSelectionEffect.SetLocation(CurrentController.Pawn.Location);
						RespawnSelectionEffect.SetRotation(rot(0,0,0));
						RespawnSelectionEffect.SetBase(CurrentController.Pawn);
						//WorldInfo.MyEmitterPool.SpawnEmitter(SSG_Pawn(CurrentController.Pawn).DirectionalArrow, CurrentController.Pawn.Location, , CurrentController.Pawn);
					}
				}
			}
		}
	}

	if( AllPlayersDead && ( IsInState('Dead') || IsInState('PlayerWaiting') ) )
	{
		CheckpointStart = SSG_GameInfo( WorldInfo.Game ).LastCheckpointStart;
		if( CheckpointStart != None )
		{
			if( RespawnSelectionEffect == None )
			{
				RespawnSelectionEffect = Spawn( class'SSG_Respawn_Mesh' );
				RespawnSelectionEffect.SelectorMesh.SetStaticMesh( RespawnSelectionEffect.StaticMeshArray[LocalPlayer(Player).ControllerId] );
				RespawnSelectionEffect.SelectorMesh.SetMaterial( 0, RespawnSelectionEffect.MaterialArray[LocalPlayer(Player).ControllerId] );
				RespawnSelectionEffect.SetOwner( self );
			}
			RespawnSelectionEffect.SetHidden(false);
			RespawnSelectionEffect.SetLocation( CheckpointStart.Location );
			RespawnSelectionEffect.SetRotation( rot(0,0,0) );
			RespawnSelectionEffect.SetBase( CheckpointStart );
		}
	}
}

//----------------------------------------------------------------------------------------------------------
exec function DecrementPlayerToSpawn()
{
	local SSG_PlayerController CurrentController;
	local SSG_POI_PlayerStart CheckpointStart;
	local LocalPlayer CurrentPlayer;
	local bool AllPlayersDead;
	local bool FoundPlayer;
	local bool Looped;

	if( LivesLived <= 0 )
	{
		DecrementInitLocationToSpawn();
		return;
	}

	AllPlayersDead = true;
	FoundPlayer = false;
	Looped = false;

	while(!FoundPlayer)
	{
		NextSpawnPlayerNum--;
		if(NextSpawnPlayerNum == LocalPlayer(Player).ControllerId)
		{
			NextSpawnPlayerNum--;
		}

		if(NextSpawnPlayerNum < 0)
		{
			if(Looped)
			{
				NextSpawnPlayerNum = LocalPlayer(Player).ControllerId;
				FoundPlayer = true; //failsafe
				if(RespawnSelectionEffect != none)
				{
					RespawnSelectionEffect.SetHidden(true);
				}
			}
			NextSpawnPlayerNum = 3;
			Looped = true;
		}

		foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentController)
		{
			CurrentPlayer = LocalPlayer(CurrentController.Player);
			if(CurrentPlayer.ControllerId == NextSpawnPlayerNum && CurrentController != self)
			{
				if(CurrentController.Pawn != none)
				{
					AllPlayersDead = false;
					FoundPlayer = true;
					if( IsInState('Dead') || IsInState('PlayerWaiting') )
					{
						//TODO change this out once final art exists
						if(RespawnSelectionEffect == none)
						{
							RespawnSelectionEffect = Spawn(class'SSG_Respawn_Mesh');
							RespawnSelectionEffect.SelectorMesh.SetStaticMesh(RespawnSelectionEffect.StaticMeshArray[LocalPlayer(Player).ControllerId]);
							RespawnSelectionEffect.SelectorMesh.SetMaterial(0, RespawnSelectionEffect.MaterialArray[LocalPlayer(Player).ControllerId]);
							RespawnSelectionEffect.SetOwner(self);
						}
						RespawnSelectionEffect.SetHidden(false);
						RespawnSelectionEffect.SetLocation(CurrentController.Pawn.Location);
						RespawnSelectionEffect.SetRotation(rot(0,0,0));
						RespawnSelectionEffect.SetBase(CurrentController.Pawn);
						//WorldInfo.MyEmitterPool.SpawnEmitter(SSG_Pawn(CurrentController.Pawn).DirectionalArrow, CurrentController.Pawn.Location, , CurrentController.Pawn);
					}
				}
			}
		}
	}

	if( AllPlayersDead && ( IsInState('Dead') || IsInState('PlayerWaiting') ) )
	{
		CheckpointStart = SSG_GameInfo( WorldInfo.Game ).LastCheckpointStart;
		if( CheckpointStart != None )
		{
			if( RespawnSelectionEffect == None )
			{
				RespawnSelectionEffect = Spawn( class'SSG_Respawn_Mesh' );
				RespawnSelectionEffect.SelectorMesh.SetStaticMesh( RespawnSelectionEffect.StaticMeshArray[LocalPlayer(Player).ControllerId] );
				RespawnSelectionEffect.SelectorMesh.SetMaterial( 0, RespawnSelectionEffect.MaterialArray[LocalPlayer(Player).ControllerId] );
				RespawnSelectionEffect.SetOwner( self );
			}
			RespawnSelectionEffect.SetHidden(false);
			RespawnSelectionEffect.SetLocation( CheckpointStart.Location );
			RespawnSelectionEffect.SetRotation( rot(0,0,0) );
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function IncrementInitLocationToSpawn()
{
	local SSG_POI_PlayerStart   InitStart;
	local int                   PlayerID;
	local bool					FoundLocation;
	local bool					Looped;

	FoundLocation = false;
	Looped = false;

	while( !FoundLocation )
	{
		++NextSpawnPlayerNum;
		if( NextSpawnPlayerNum >= 4 )
		{
			if( Looped )
			{
				NextSpawnPlayerNum = LocalPlayer(Player).ControllerId;
				FoundLocation = true;
				if( RespawnSelectionEffect != None )
				{
					RespawnSelectionEffect.SetHidden(true);
				}
			}
			NextSpawnPlayerNum = 0;
			Looped = true;
		}

		foreach WorldInfo.AllActors( class'SSG_POI_PlayerStart', InitStart )
		{
			if( InitStart.Target != None && InitStart.PlayerNum == NextSpawnPlayerNum )
			{
				FoundLocation = true;
				if( IsInState('Dead') || IsInState('PlayerWaiting') )
				{
					//TODO change this out once final art exists
					if( RespawnSelectionEffect == None )
					{
						RespawnSelectionEffect = Spawn( class'SSG_Respawn_Mesh' );
						RespawnSelectionEffect.SelectorMesh.SetStaticMesh( RespawnSelectionEffect.StaticMeshArray[LocalPlayer(Player).ControllerId] );
						RespawnSelectionEffect.SelectorMesh.SetMaterial( 0, RespawnSelectionEffect.MaterialArray[LocalPlayer(Player).ControllerId] );
						RespawnSelectionEffect.SetOwner( self );
					}
					RespawnSelectionEffect.SetHidden( false );
					RespawnSelectionEffect.SetLocation( InitStart.Location );
					RespawnSelectionEffect.SetRotation( Rot(0,0,0) );
					RespawnSelectionEffect.SetBase( InitStart );
				}
			}

			PlayerID = LocalPlayer( Player ).ControllerId;
			if( InitStart.Target != None && InitStart.PlayerNum == PlayerID )
			{
				if( NextSpawnPlayerNum == PlayerID )
				{
					InitStart.Target.SetLight( true );
				}
				else
				{
					InitStart.Target.SetLight( false );
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function DecrementInitLocationToSpawn()
{
	local SSG_POI_PlayerStart   InitStart;
	local int                   PlayerID;
	local bool					FoundLocation;
	local bool					Looped;

	FoundLocation = false;
	Looped = false;

	while( !FoundLocation )
	{
		--NextSpawnPlayerNum;
		if( NextSpawnPlayerNum < 0 )
		{
			if( Looped )
			{
				NextSpawnPlayerNum = LocalPlayer(Player).ControllerId;
				FoundLocation = true;
				if( RespawnSelectionEffect != None )
				{
					RespawnSelectionEffect.SetHidden(true);
				}
			}
			NextSpawnPlayerNum = 3;
			Looped = true;
		}

		foreach WorldInfo.AllActors( class'SSG_POI_PlayerStart', InitStart )
		{
			if( InitStart.Target != None && InitStart.PlayerNum == NextSpawnPlayerNum )
			{
				FoundLocation = true;
				if( IsInState('Dead') || IsInState('PlayerWaiting') )
				{
					//TODO change this out once final art exists
					if( RespawnSelectionEffect == None )
					{
						RespawnSelectionEffect = Spawn( class'SSG_Respawn_Mesh' );
						RespawnSelectionEffect.SelectorMesh.SetStaticMesh( RespawnSelectionEffect.StaticMeshArray[LocalPlayer(Player).ControllerId] );
						RespawnSelectionEffect.SelectorMesh.SetMaterial( 0, RespawnSelectionEffect.MaterialArray[LocalPlayer(Player).ControllerId] );
						RespawnSelectionEffect.SetOwner( self );
					}
					RespawnSelectionEffect.SetHidden( false );
					RespawnSelectionEffect.SetLocation( InitStart.Location );
					RespawnSelectionEffect.SetRotation( Rot(0,0,0) );
					RespawnSelectionEffect.SetBase( InitStart );
				}
			}

			PlayerID = LocalPlayer( Player ).ControllerId;
			if( InitStart.Target != None && InitStart.PlayerNum == PlayerID )
			{
				if( NextSpawnPlayerNum == PlayerID )
				{
					InitStart.Target.SetLight( true );
				}
				else
				{
					InitStart.Target.SetLight( false );
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function CreateSpawnEffects()
{
	local SSG_Proj_Barrel BarrelInTheSky;

	BarrelInTheSky = WorldInfo.Spawn(class'SSG_Proj_Barrel', , , NextSpawnSpot+vect(0,0,800));
	BarrelInTheSky.PrepareForPlayer(LocalPlayer(Player).ControllerId);

	if( RespawnSelectionEffect != None )
		RespawnSelectionEffect.SetBase(none);
}

//----------------------------------------------------------------------------------------------------------
state RoundEnded
{
	event BeginState(Name PreviousStateName)
	{
		Super.BeginState( PreviousStateName );
	}
}

//----------------------------------------------------------------------------------------------------------
reliable client function ClientGameEnded( Actor EndGameFocus, bool bIsWinner )
{
	if( SSG_HUD_Base( myHUD ) != None )
	{
		SSG_HUD_Base( myHUD ).ShowGameOverMessage( bIsWinner );
	}

	Super.ClientGameEnded( EndGameFocus, bIsWinner );
}

//----------------------------------------------------------------------------------------------------------
function TurnOffPlayerControl( float SecondsBeforeTurnOn )
{
	bCanControlPlayer = false;
	SetTimer( SecondsBeforeTurnOn, false, 'TurnOnPlayerControl', self );
}

//----------------------------------------------------------------------------------------------------------
function TurnOnPlayerControl()
{
	bCanControlPlayer = true;
}

//----------------------------------------------------------------------------------------------------------
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;


	//----------------------------------------------------------------------------------------------------------
	function PlayerMove( float DeltaTime )
	{
		local vector			LocalX, LocalY, NewAccel;
		local eDoubleClickDir	DoubleClickMove;
		local rotator			OldRotation;
		local bool				bSaveJump, bStopForFiring;
		local float             DrunkOffsetPercent, CurrentDesiredDifferenceDegrees, SpeedScaleFromRotation/*, LeftStickDistanceFromCenter*/;
		//local SSG_Pawn          SSGP;

		if( Pawn == None )
		{
			GotoState('Dead');
		}
		else
		{
			bStopForFiring = false;
			//SSGP = SSG_Pawn( Pawn );
			//if( SSGP != none && SSGP.bIsFiringWeapon && SSGP.Weapon.IsA( 'SSG_Weap_Bow' ) )
			//{
			//	bStopForFiring = true;
			//}

			//GetAxes(Pawn.Rotation,X,Y,Z);

			LocalX = X;
			LocalY = Y;
			DrunkOrientationOffsetUnrRot = 0;

			if( bIsDrunk )
			{
				DrunkOffsetPercent = sin( 5.0 * SecondsSinceRandomControls );
				DrunkOffsetPercent *= MIN_PERLIN_VALUE + ( ( 1.0 - MIN_PERLIN_VALUE ) * ( ( PerlinNoise1D( SecondsSinceRandomControls, 4, 0.5 ) - 1.0 ) * 0.5 ) );
				LocalX = Normal( X + DrunkOffsetPercent * ( Y ) );
				LocalY = Normal( Y + DrunkOffsetPercent * ( -X ) );

				DrunkOrientationOffsetUnrRot = RadToUnrRot * acos( X dot LocalX );
				if( DrunkOffsetPercent < 0 )
					DrunkOrientationOffsetUnrRot *= -1.0;
			}

			// Update acceleration.
			NewAccel = ( PlayerInput.aForward * LocalX ) + ( PlayerInput.aStrafe * LocalY );
			if( bStopForFiring || !bCanControlPlayer )
			{
				NewAccel.X = 0;
				NewAccel.Y = 0;
			}

			NewAccel.Z	= 0;
			NewAccel = Pawn.AccelRate * Normal(NewAccel);

			if (IsLocalPlayerController())
			{
				AdjustPlayerWalkingMoveAccel(NewAccel);
			}

			DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

			// Update rotation.
			OldRotation = Rotation;
			if( !bStopForFiring )
				UpdateRotation( DeltaTime );

			if( bInstantRotation )
			{
				SpeedScaleFromRotation = 1.0;
			}
			else
			{
				CurrentDesiredDifferenceDegrees = UnrRotToDeg * abs( DesiredOrientationUnrRot - CurrentOrientationUnrRot );
				SpeedScaleFromRotation = 1.0 - ( CurrentDesiredDifferenceDegrees - ROTATION_DEGREES_DIFFERENCE_BEFORE_SCALING ) / ( 180.0 - 2.0 * ROTATION_DEGREES_DIFFERENCE_BEFORE_SCALING );
				SpeedScaleFromRotation = FClamp( SpeedScaleFromRotation, 0.0, 1.0 );
			}

			// This was for when players could walk or run based on stick position
			/*LeftStickDistanceFromCenter = sqrt( ( PlayerInput.aForward * PlayerInput.aForward ) + ( PlayerInput.aStrafe * PlayerInput.aStrafe ) );
			if( LeftStickDistanceFromCenter < WALK_RUN_DIST_FROM_CENTER_THRESHOLD )
			{
				Pawn.GroundSpeed = WalkSpeed * SpeedScaleFromRotation;
			}
			else
			{
				Pawn.GroundSpeed = RunSpeed * SpeedScaleFromRotation;
			}*/

			// This was for when pawns could use shields
			/*SSGP = SSG_Pawn( Pawn );
			if( SSGP != None && SSGP.bIsShielding )
			{
				Pawn.GroundSpeed = WalkSpeed;
			}*/

			bDoubleJump = false;

			if( bPressedJump && Pawn.CannotJumpNow() )
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
			{
				bSaveJump = false;
			}

			if( Role < ROLE_Authority ) // then save this move and replicate it
			{
				ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			else
			{
				ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
			}
			bPressedJump = bSaveJump;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
state Dead
{
	ignores SeePlayer, HearNoise, KilledBy, NextWeapon, PrevWeapon;

	//----------------------------------------------------------------------------------------------------------
	event BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
		SetTimer( SECONDS_BEFORE_AUTO_RESPAWN, false, 'ServerReStartPlayer', self );
	}


	//----------------------------------------------------------------------------------------------------------
	reliable server function ServerReStartPlayer()
	{
		ClearTimer( 'ServerReStartPlayer', self );
		Super.ServerReStartPlayer();
	}


	//----------------------------------------------------------------------------------------------------------
	exec function RespawnPlayer()
	{
		ServerReStartPlayer();
	}
}


//----------------------------------------------------------------------------------------------------------
function bool IsRotationCurrentlyAllowed()
{
	if( Pawn == None ) //if they don't have a pawn, let them spin all they want
	{
		return true;
	}

	if( Pawn.Weapon == None )
	{
		return true;
	}

	if( Pawn.Weapon.IsA( 'SSG_Weap_Bow' ) )
	{
		return false;
	}

	return true;
}


//----------------------------------------------------------------------------------------------------------
function ProcessViewRotation( float DeltaTime, out Rotator out_ViewRotation, Rotator DeltaRot )
{
	if( PlayerCamera != None )
	{
		PlayerCamera.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
	}

	if ( Pawn != None )
	{	// Give the Pawn a chance to modify DeltaRot (limit view for ex.)
		Pawn.ProcessViewRotation( DeltaTime, out_ViewRotation, DeltaRot );
	}
	else
	{
		// If Pawn doesn't exist, limit view

		// Add Delta Rotation
		out_ViewRotation	+= DeltaRot;
		out_ViewRotation	 = LimitViewRotation(out_ViewRotation, -16384, 16383 );
	}
}


//----------------------------------------------------------------------------------------------------------
function InterpolateTowardDesiredOrientation( float DeltaTime )
{
	local int angularDisplacement;

	if( !IsRotationCurrentlyAllowed() )
		return;

	if( bInstantRotation )
	{
		CurrentOrientationUnrRot = DesiredOrientationUnrRot;
		return;
	}

	angularDisplacement = DesiredOrientationUnrRot - CurrentOrientationUnrRot;
	while( angularDisplacement > ( 180 * DegToUnrRot ) )
	{
		angularDisplacement -= ( 360 * DegToUnrRot );
	}

	while( angularDisplacement < ( -180 * DegToUnrRot ) )
	{
		angularDisplacement += ( 360 * DegToUnrRot );
	}

	if( abs( angularDisplacement ) < MAX_TURN_SPEED_DEGREES_PER_SECOND * DegToUnrRot * DeltaTime )
	{
		CurrentOrientationUnrRot = DesiredOrientationUnrRot;
	}
	else
	{
		if( angularDisplacement > 0 )
		{
			CurrentOrientationUnrRot += MAX_TURN_SPEED_DEGREES_PER_SECOND * DegToUnrRot * DeltaTime;
		}
		else
		{
			CurrentOrientationUnrRot -= MAX_TURN_SPEED_DEGREES_PER_SECOND * DegToUnrRot * DeltaTime;
		}
	}
}


//----------------------------------------------------------------------------------------------------------
function UpdateRotation( float DeltaTime )
{
	local Rotator   /*DeltaRot,*/ newRotation, ViewRotation;
	local Vector    currentRightStickPos, normalPos, SumVector, ArrayVector;
	local float     angleRad, StickLength;
	
	ViewRotation = Rotation;
	if (Pawn!=none)
	{
		Pawn.SetDesiredRotation(ViewRotation);
	}

	if( bRightStickOrientation )
	{
		currentRightStickPos = PlayerInput.aLookUp*X + PlayerInput.aTurn*Y;
	}
	else
	{
		currentRightStickPos = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
	}

	currentRightStickPos.Z = 0;

	StickLength = VSize( currentRightStickPos );
	if( StickLength != 0.0 )
	{
		StickLength = FClamp( CONTROLLER_LENGTH_FULL / StickLength, 0.0, 1.0 );
	}
	
	if( currentRightStickPos.X == 0 && currentRightStickPos.Y == 0 )
	{
		ControlInputBuffer.Remove( 0, ControlInputBuffer.Length );
	}
	else
	{
		if( ControlInputBuffer.Length >= CONTROL_BUFFER_LENGTH )
		{
			ControlInputBuffer.Remove( 0, 1 );
		}
	}
	
	ControlInputBuffer.AddItem( currentRightStickPos * StickLength );

	foreach ControlInputBuffer( ArrayVector )
	{
		SumVector += ArrayVector;
	}

	normalPos = Normal( SumVector );
	angleRad = atan2( normalPos.Y, normalPos.X );

	if( normalPos.X == 0 && normalPos.Y == 0 )
	{
		DesiredOrientationUnrRot = CurrentOrientationUnrRot;
	}
	else
	{
		DesiredOrientationUnrRot = angleRad * RadToUnrRot;
		DesiredOrientationUnrRot += DrunkOrientationOffsetUnrRot;
	}

	InterpolateTowardDesiredOrientation( DeltaTime );
	
	// Calculate Delta to be applied on ViewRotation
	//DeltaRot.Yaw     = PlayerInput.aTurn;
	//DeltaRot.Pitch   = 0;
	
	//ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
	//SetRotation(ViewRotation);
	
	//NewRotation = ViewRotation;
	//NewRotation.Roll = Rotation.Roll;

	NewRotation.Yaw = CurrentOrientationUnrRot;
	
	if ( Pawn != None )
		Pawn.FaceRotation(NewRotation, deltatime);
}

//+++++++++++++++++++++++++++++++++++++++++ Sound Group Settings +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
static final function SetMusicGroupVolume( float MusicVolume )
{
	default.MusicGroupVolume = MusicVolume;
	StaticSaveConfig();
}

//----------------------------------------------------------------------------------------------------------
static final function SetSoundGroupVolume( float SoundVolume )
{
	default.SoundGroupVolume = SoundVolume;
	StaticSaveConfig();
}

//----------------------------------------------------------------------------------------------------------
static final function SetVoiceGroupVolume( float VoiceVolume )
{
	default.VoiceGroupVolume = VoiceVolume;
	StaticSaveConfig();
}

//----------------------------------------------------------------------------------------------------------
static final function SetGraphicsLevel( int GraphicsLevel )
{
	default.GraphicsLevelIndex = GraphicsLevel;
	StaticSaveConfig();
}

//----------------------------------------------------------------------------------------------------------
static final function SetRumble( bool isRumbleOn )
{
	default.RumbleOn = isRumbleOn;
	StaticSaveConfig();
}


//++++++++++++++++++++++++++++++++++++++++++++ Exec Functions ++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
exec function RightStickOrientation( bool useRightStick )
{
	bRightStickOrientation = useRightStick;
}

//----------------------------------------------------------------------------------------------------------
exec function InstantOrientation( bool isInstant )
{
	bInstantRotation = isInstant;
}

//----------------------------------------------------------------------------------------------------------
exec function SetCameraFocusPoint( int FocusPointSectionID )
{
	SSG_Camera_SharedMulti( PlayerCamera ).SetCameraFocusPoint( FocusPointSectionID );
}

//----------------------------------------------------------------------------------------------------------
exec function SetCameraAutoZoom( bool ShouldAutoZoom )
{
	SSG_Camera_SharedMulti( PlayerCamera ).SetCameraAutoZoom( ShouldAutoZoom );
}

//----------------------------------------------------------------------------------------------------------
exec function SetCameraRotationAboutZDegrees( float AngleDegrees )
{
  	SSG_Camera_SharedMulti( PlayerCamera ).SetCameraRotationAboutZDegrees( AngleDegrees );
}

//----------------------------------------------------------------------------------------------------------
exec function SetCameraVerticalAngleDegrees( float AngleDegrees )
{
  	SSG_Camera_SharedMulti( PlayerCamera ).SetCameraVerticalAngleDegrees( AngleDegrees );
}

//----------------------------------------------------------------------------------------------------------
exec function SetCameraZoomUnrealUnits( int DistanceToPlayerUnrealUnits )
{
	SSG_Camera_SharedMulti( PlayerCamera ).SetCameraZoomUnrealUnits( DistanceToPlayerUnrealUnits );
}

//----------------------------------------------------------------------------------------------------------
exec function ShowMenu()
{
	local SSG_PlayerController PC;
	local int PlayerID;

	PlayerID = LocalPlayer( Player ).ControllerID;
	if( PlayerID == 0 )
	{
		SSG_HUD_Base( myHUD ).TogglePauseMenu( PlayerID );
	}
	else
	{
		ForEach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
		{
			if( LocalPlayer( PC.Player ).ControllerID == 0 )
			{
				SSG_HUD_Base( PC.myHUD ).TogglePauseMenu( PlayerID );
				return;
			}
		}
	}
}



//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	CameraClass=class'SuperSlashNGrab.SSG_Camera_SharedMulti'
	CheatClass=class'SuperSlashNGrab.SSG_CheatManager'
	InputClass=class'SuperSlashNGrab.SSG_PlayerInput'

	LivesLived=0 //Counter -- do not change
	IDOfCurrentWeapon=3 //Sword and bow
	IDOfWeaponPickedUpLastUpdate=0
	MoneyEarnedSinceLastUpdate=0 //Counter -- do not change
	TakenDamageSinceLastUpdate=false
	SecondsLeftBeforeKilled=MAX_SECONDS_OFFSCREEN_BEFORE_KILLED;
	bIsOffscreen=false

	ControlType=0
	X=(X=1.0,Y=0.0,Z=0.0)
	Y=(X=0.0,Y=1.0,Z=0.0)

	Begin Object Class=ForceFeedbackWaveform Name=HitRumbleWaveform
        Samples(0)=( LeftAmplitude=30, RightAmplitude=30, LeftFunction=WF_Constant, RightFunction=WF_Constant, Duration=0.5 )
        bIsLooping = false;
    End Object
    HitRumble=HitRumbleWaveform
	
	Begin Object Class=ForceFeedbackWaveform Name=DeathRumbleWaveform
        Samples(0)=( LeftAmplitude=80, RightAmplitude=80, LeftFunction=WF_LinearIncreasing, RightFunction=WF_LinearIncreasing, Duration=1.0 )
        bIsLooping = false;
    End Object
    DeathRumble=DeathRumbleWaveform

	Begin Object Class=ForceFeedbackWaveform Name=RespawnRumbleWaveform
        Samples(0)=( LeftAmplitude=20, RightAmplitude=20, LeftFunction=WF_Constant, RightFunction=WF_Constant, Duration=0.3 )
        bIsLooping = false;
    End Object
    RespawnRumble=RespawnRumbleWaveform

	CurrentOrientationUnrRot=0
	DesiredOrientationUnrRot=0
	DrunkOrientationOffsetUnrRot=0
	bRightStickOrientation=false
	bInstantRotation=true
	bShiftedPlayerRespawnSelect=false

	WalkSpeed=300.0
	RunSpeed=750.0

	MoneyEarned=0 //Counter -- do not change!

	bIsDrunk=false
	bCanControlPlayer=true
	NumMeadPuddlesTouching=0
	RandomControlsLengthSeconds=3.0
	SecondsSinceRandomControls=0.0

	bSpawningForFirstTime=true //Needed for initial spawn code
	bShowPlayerHUD=false
	//Old Colors 1
	//PlayerColors(0)=( R=0.0470, G=0.1333, B=0.4784 ) //( 12, 34,122) or 0x0C227A
	//PlayerColors(1)=( R=0.9450, G=0.8235, B=0.0666 ) //(241,210, 17) or 0xF1D211
	//PlayerColors(2)=( R=0.9098, G=0.3176, B=0.8941 ) //(232, 81,228) or 0xE851E4
	//PlayerColors(3)=( R=0.2117, G=0.8431, B=0.5450 ) //( 54,215,139) or 0x36D78B

	//Old Colors 2
	//PlayerColors(0)=( R=0.2823, G=0.2823, B=1.0000 ) //( 72, 72,255) or 0x
	//PlayerColors(1)=( R=0.7058, G=0.0000, B=0.4901 ) //(180, 0, 125) or 0x
	//PlayerColors(2)=( R=0.1803, G=1.0000, B=0.7411 ) //(46, 255,189) or 0x
	//PlayerColors(3)=( R=0.5411, G=1.0000, B=0.0000 ) //(138, 255, 0) or 0x

	//New Colors
	PlayerColors(0)=( R=0.0118, G=0.4235, B=0.8353 ) //(  3, 108, 213) or 0x036cd5
	PlayerColors(1)=( R=0.8431, G=0.1725, B=0.7411 ) //(250,   0, 212) or 0xfa00d4
	PlayerColors(2)=( R=0.8431, G=0.4352, B=0.0000 ) //(215, 111,   0) or 0xd76f00
	PlayerColors(3)=( R=0.0588, G=0.5373, B=0.0078 ) //( 15, 137,   2) or 0x0f8902

	ExitedInPosition = 0
	InSectionTransitionNumber = -1

	DefaultNames(0)= "Bonnie"
	DefaultNames(1)= "Clyde"
	DefaultNames(2)= "Jesse"
	DefaultNames(3)= "Butch"
	DefaultNames(4)= "Sundance"
	DefaultNames(5)= "Robin"
	DefaultNames(6)= "Floyd"
	DefaultNames(7)= "Babyface"
	DefaultNames(8)= "Ma"

	NumKills = 0
	NumMeleeKills = 0
	NumRangedKills = 0

	bIsLost = false

	NextSpawnPlayerNum =0
	WaitingOnRespawn = false
	SpawnEffect(0)=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Explosion_PS_01'
	SpawnEffect(1)=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Explosion_PS_02'
	SpawnEffect(2)=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Explosion_PS_03'
	SpawnEffect(3)=ParticleSystem'SSG_Character_Particles.RespawnBarrels.SSG_Particles_RespawnBarrels_Explosion_PS_04'

	Superlatives(0)="Cheater"

	Highscores[0]=0
	Highscores[1]=0
	Highscores[2]=0
	Highscores[3]=0
}
