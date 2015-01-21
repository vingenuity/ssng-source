class SSG_Camera_SharedMulti extends Camera;

//General Camera Settings
var int CameraRotationAboutZUnrealUnits;
var int CameraVerticalAngleUnrealUnits;

//Camera Section Following
var int CurrentSectionID;
var ViewTargetTransitionParams SectionTransitionParams;

//Player Following
var bool bCenterOnPlayers;
var Vector LastFocusLocation;
var Vector LocationToSeek;

//Camera Zoom Settings
var bool bAutoZoomEnabled;
var float CurrentZoomDistanceUnrealUnits;
var float MinZoomDistanceUnrealUnits;
var float MaxZoomDistanceUnrealUnits;
var float ZoomSpeedUnrealUnitsPerFrame;
var Vector2d NormalizedZoomInThresholdSouthWest;
var Vector2d NormalizedZoomInThresholdNorthEast;
var Vector2d NormalizedZoomOutThresholdSouthWest;
var Vector2d NormalizedZoomOutThresholdNorthEast;

//Attached Objects
var array<PlayerController> AttachedControllers;
const MAXIMUM_FOCUS_POINTS = 20;
var SSG_POI_CameraFocusPoint RegisteredFocusPoints[ MAXIMUM_FOCUS_POINTS ];



//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	super.PostBeginPlay();
}

//----------------------------------------------------------------------------------------------------------
function InitializeFor(PlayerController PC)
{
	CameraCache.POV.FOV = DefaultFOV;
	PCOwner				= PC;

	SetCameraFocusPoint( 0 );

	// set the level default scale
	SetDesiredColorScale(WorldInfo.DefaultColorScale, 5.f);

	// Force camera update so it doesn't sit at (0,0,0) for a full tick.
	// This can have side effects with streaming.
	UpdateCamera( 0.f );
}

//----------------------------------------------------------------------------------------------------------
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	OutVT.POV.Location = OutVT.Target.Location;

	if( bAutoZoomEnabled )
	{
		ZoomCameraToFitAttachedPlayersOnScreen( CurrentZoomDistanceUnrealUnits );
	}

	OutVT.POV.Location.Z = 0;
    OutVT.POV.Location.X -= ( -Sin( CameraRotationAboutZUnrealUnits * UnrRotToRad ) + Cos( CameraVerticalAngleUnrealUnits * UnrRotToRad ) ) * CurrentZoomDistanceUnrealUnits;
   	OutVT.POV.Location.Y -= Sin( CameraRotationAboutZUnrealUnits * UnrRotToRad ) * CurrentZoomDistanceUnrealUnits;
    OutVT.POV.Location.Z += Sin( CameraVerticalAngleUnrealUnits * UnrRotToRad ) * CurrentZoomDistanceUnrealUnits;
    OutVT.POV.Rotation.Pitch = -1 * CameraVerticalAngleUnrealUnits;   
    OutVT.POV.Rotation.Yaw = CameraRotationAboutZUnrealUnits;
    OutVT.POV.Rotation.Roll = 0;
}

//----------------------------------------------------------------------------------------------------------
function Vector CalculateCentroidOfAttachedPlayers()
{
	local PlayerController AttachedController;
	local Vector CentroidOfPawns;
	local SSG_POI_PlayerStart CheckpointStart;
	local int NumberOfLivingPlayers;

	NumberOfLivingPlayers = 0;
	foreach AttachedControllers( AttachedController )
	{
		if( AttachedController.Pawn != None )
		{
			CentroidOfPawns += AttachedController.Pawn.Location;
			++NumberOfLivingPlayers;
		}
	}

	if( NumberOfLivingPlayers == 0 )
	{
		CheckpointStart = SSG_GameInfo( WorldInfo.Game ).LastCheckpointStart;
		if( CheckpointStart != None )
		{
			return CheckpointStart.Location;
		}
		else
		{
			return Vect( 0.0, 0.0, 0.0 );
		}
	}

	CentroidOfPawns /= NumberOfLivingPlayers;
	return CentroidOfPawns;
}

//----------------------------------------------------------------------------------------------------------
function ZoomCameraToFitAttachedPlayersOnScreen( out float CurrentZoomLevel )
{
	local PlayerController AttachedController;
	local Vector2d PlayerScreenLocation;

	local float MinPlayerScreenX;
	local float MaxPlayerScreenX;
	local float MinPlayerScreenY;
	local float MaxPlayerScreenY;

	MinPlayerScreenX = 9000.0; //9000 should be greater than any reasonable screen res.
	MaxPlayerScreenX = 0.0;
	MinPlayerScreenY = 9000.0;
	MaxPlayerScreenY = 0.0;

	foreach AttachedControllers( attachedController )
	{
		if( attachedController.Pawn == None )
			continue;
			
		PlayerScreenLocation = LocalPlayer( attachedController.Player ).FastProject( attachedController.Pawn.Location );

		if( PlayerScreenLocation.X < MinPlayerScreenX )
			MinPlayerScreenX = PlayerScreenLocation.X;

		if( PlayerScreenLocation.X > MaxPlayerScreenX )
			MaxPlayerScreenX = PlayerScreenLocation.X;

		if( PlayerScreenLocation.Y < MinPlayerScreenY )
			MinPlayerScreenY = PlayerScreenLocation.Y;

		if( PlayerScreenLocation.Y > MaxPlayerScreenY )
			MaxPlayerScreenY = PlayerScreenLocation.Y;
	}

	if( MaxPlayerScreenY > NormalizedZoomOutThresholdNorthEast.Y || MinPlayerScreenY < NormalizedZoomOutThresholdSouthWest.Y || 
		MaxPlayerScreenX > NormalizedZoomOutThresholdNorthEast.X || MinPlayerScreenX < NormalizedZoomOutThresholdSouthWest.X )
	{
		CurrentZoomLevel += ZoomSpeedUnrealUnitsPerFrame;

		if( CurrentZoomLevel > MaxZoomDistanceUnrealUnits )
			CurrentZoomLevel = MaxZoomDistanceUnrealUnits;
	}
	else if( MaxPlayerScreenY > NormalizedZoomInThresholdNorthEast.Y || MinPlayerScreenY > NormalizedZoomInThresholdSouthWest.Y || 
			 MaxPlayerScreenX < NormalizedZoomInThresholdNorthEast.X || MinPlayerScreenX > NormalizedZoomInThresholdSouthWest.X )
	{
		CurrentZoomLevel -= ZoomSpeedUnrealUnitsPerFrame;

		if( CurrentZoomLevel < MinZoomDistanceUnrealUnits )
			CurrentZoomLevel = MinZoomDistanceUnrealUnits;
	}
}



//++++++++++++++++++++++++++++++++++++++++++ Object Registration +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function AttachController( PlayerController playerControl )
{
	AttachedControllers.AddItem( playerControl );
	//`log( "Attached Controller. Length:" @ AttachedControllers.Length );
}

//----------------------------------------------------------------------------------------------------------
function RegisterFocusPoint( SSG_POI_CameraFocusPoint FocusPoint )
{
	RegisteredFocusPoints[ FocusPoint.LevelSectionID ] = FocusPoint;
}



//++++++++++++++++++++++++++++++++++++++++++++ Exec Functions ++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function SetCameraAutoZoom( bool ShouldAutoZoom )
{
	bAutoZoomEnabled = ShouldAutoZoom;
}

//----------------------------------------------------------------------------------------------------------
function SetCameraFocusPoint( int FocusPointSectionID )
{
	CurrentSectionID = FocusPointSectionID;

	if( RegisteredFocusPoints[ CurrentSectionID ] == None )
		`warn( "No focus point registered for section ID" @ FocusPointSectionID $ "!" );
	SetViewTarget( RegisteredFocusPoints[ CurrentSectionID ], SectionTransitionParams );
}

//----------------------------------------------------------------------------------------------------------
function SetCameraRotationAboutZDegrees( float AngleDegrees )
{
	//CameraRotationAboutZUnrealUnits = DegToUnrRot * AngleDegrees;
}

//----------------------------------------------------------------------------------------------------------
function SetCameraVerticalAngleDegrees( float AngleDegrees )
{
	CameraVerticalAngleUnrealUnits = DegToUnrRot * AngleDegrees;
}

//----------------------------------------------------------------------------------------------------------
function SetCameraZoomUnrealUnits( int DistanceToPlayerUnrealUnits )
{
	CurrentZoomDistanceUnrealUnits = DistanceToPlayerUnrealUnits;
}

function SetTransitionTimeSeconds( int TransitionTimeSeconds )
{
	SectionTransitionParams.BlendTime=TransitionTimeSeconds;
}



//++++++++++++++++++++++++++++++++++++++++++ Default Properties ++++++++++++++++++++++++++++++++++++++++++//
DefaultProperties
{
	CameraStyle=Fixed
	DefaultFOV=90.0
	DefaultAspectRatio=AspectRatio16x9
	CameraVerticalAngleUnrealUnits=15474 //85 degrees
	CameraRotationAboutZUnrealUnits=0

	CurrentSectionID=0
	SectionTransitionParams=( BlendTime=1.5, BlendFunction=VTBlend_Cubic, BlendExp=2.0, bLockOutgoing=FALSE )

	bCenterOnPlayers=true
	bAutoZoomEnabled=false
	CurrentZoomDistanceUnrealUnits=1500.0
	MinZoomDistanceUnrealUnits=800.0
	MaxZoomDistanceUnrealUnits=2000.0
	ZoomSpeedUnrealUnitsPerFrame=4.0
	NormalizedZoomInThresholdSouthWest =(X=0.4,Y=0.4)
	NormalizedZoomInThresholdNorthEast =(X=0.6,Y=0.6)
	NormalizedZoomOutThresholdSouthWest=(X=0.1,Y=0.25)
	NormalizedZoomOutThresholdNorthEast=(X=0.9,Y=0.9)
}