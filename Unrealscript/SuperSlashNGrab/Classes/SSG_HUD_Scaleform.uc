class SSG_HUD_Scaleform extends GfxMoviePlayer
	dependson( Text_Formatting )
	dependson( SSG_Weap_Base );

var SSG_GameInfo ActiveGameInfo;
var GFxObject rootOfHUD;
var Vector2D HudDimensions;
var Vector2D WindowDimensions;

const TIME_LEFT_CRITICAL = 5;
const TIME_LEFT_WARNING = 30;
var SSG_HUD_Timer EnrageTimer;
var bool SirenStarted;

var SSG_HUD_Nav_Arrow NavigationArrow;
var SSG_HUD_Arrow ObjectiveArrow;
var SSG_HUD_Compass ObjectiveCompass;

const MAX_NUMBER_OF_PLAYERS = 4;
var SSG_HUD_Arrow PlayerArrows[ MAX_NUMBER_OF_PLAYERS ];
var SSG_HUD_Corner CornerHUD[ MAX_NUMBER_OF_PLAYERS ];
var SSG_HUD_Edge EdgeHUD[ MAX_NUMBER_OF_PLAYERS ];
var SSG_HUD_Ring PlayerHUD[ MAX_NUMBER_OF_PLAYERS ];

var Vector2D RespawnArrowPositionOffset[ MAX_NUMBER_OF_PLAYERS ];
var float RespawnArrowRotationOffset[ MAX_NUMBER_OF_PLAYERS ];

var string ScaleformArrowNames[ MAX_NUMBER_OF_PLAYERS ];
var string ScaleformCornerNames[ MAX_NUMBER_OF_PLAYERS ];
var string ScaleformEdgeNames[ MAX_NUMBER_OF_PLAYERS ];
var string ScaleformRingNames[ MAX_NUMBER_OF_PLAYERS ];

var int WasInFirst[ MAX_NUMBER_OF_PLAYERS ]; //treated as a bool, but UDK won't allow bool arrays
var int GoldLeadThreshold;

var bool bShowCornerHUD;
var bool bShowEdgeHUD;
var bool bShowRingHUD;

//EScreenState is an enum configured by adding the values of north/south/east/west (there are some bad sums, which are marked)
enum EScreenState
{
	STATE_OnScreen,
	STATE_OffNorthEdge,
	STATE_OffSouthEdge,
	STATE_Bad1, //North/South
	STATE_OffWestEdge,
	STATE_OffNorthWest,
	STATE_OffSouthWest,
	STATE_Bad2, //West/North/South
	STATE_OffEastEdge,
	STATE_OffNorthEast,
	STATE_OffSouthEast
};

const URotToDegree = 0.005493;



//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool Start( optional bool StartPaused = false )
{
	super.Start();
	return true;
}

//----------------------------------------------------------------------------------------------------------
function Init( optional LocalPlayer playerController )
{
	local int i;
	local LinearColor PlayerBaseColor;

	Start();
	Advance(0.f);

	SetViewScaleMode(SM_ExactFit);
	SetAlignment(Align_TopLeft);

	ActiveGameInfo = SSG_GameInfo( GetPC().WorldInfo.Game );
	rootOfHUD = GetVariableObject("_root");

	HudDimensions.X = GetVariableInt( "loaderInfo.width" );
	HudDimensions.Y = GetVariableInt( "loaderInfo.height" );

	EnrageTimer = SSG_HUD_Timer( GetVariableObject( "_root.mc_game_timer", class'SSG_HUD_Timer' ) );

	NavigationArrow = SSG_HUD_Nav_Arrow( GetVariableObject( "root.mc_directional_arrow", class'SSG_HUD_Nav_Arrow' ) );
	ObjectiveArrow = SSG_HUD_Arrow( GetVariableObject( "_root.mc_objective_arrow", class'SSG_HUD_Arrow' ) );
	ObjectiveCompass = SSG_HUD_Compass( GetVariableObject( "_root.mc_objective_compass", class'SSG_HUD_Compass' ) );

	for( i = 0; i < MAX_NUMBER_OF_PLAYERS; ++i )
	{
		PlayerArrows[ i ] = SSG_HUD_Arrow( GetVariableObject( ScaleformArrowNames[ i ], class'SSG_HUD_Arrow' ) );
		CornerHUD[ i ] = SSG_HUD_Corner( GetVariableObject( ScaleformCornerNames[ i ], class'SSG_HUD_Corner' ) );
		EdgeHUD[ i ] = SSG_HUD_Edge( GetVariableObject( ScaleformEdgeNames[ i ], class'SSG_HUD_Edge' ) );
		PlayerHUD[ i ] = SSG_HUD_Ring( GetVariableObject( ScaleformRingNames[ i ], class'SSG_HUD_Ring' ) );
		PlayerHUD[ i ].SetTreasure( "0" );
		PlayerHUD[ i ].HideHealth();
		PlayerHUD[ i ].HideFacingArrow();

		EnrageTimer.SetVisible( false );
		//PlayerHUD[ i ].Hide();
		ObjectiveCompass.SetVisible( false );
		CornerHUD[ i ].SetVisible( false );
		EdgeHUD[ i ].SetVisible( false );

		PlayerBaseColor = SSG_PlayerController( GetPC() ).PlayerColors[ i ];

		if( i == 0 ) //Adjust first player's HUD color up, because it's too dark.
		{
			CornerHUD[ i ].SetColorsFromLinearColor( PlayerBaseColor );
			EdgeHUD[ i ].SetColorsFromLinearColor( PlayerBaseColor );
			PlayerHUD[ i ].SetColorsFromLinearColor( PlayerBaseColor, 0.1 );
			PlayerArrows[ i ].SetColorsFromLinearColor( PlayerBaseColor );
		}
		else
		{
			CornerHUD[ i ].SetColorsFromLinearColor( PlayerBaseColor );
			EdgeHUD[ i ].SetColorsFromLinearColor( PlayerBaseColor );
			PlayerHUD[ i ].SetColorsFromLinearColor( PlayerBaseColor );
			PlayerArrows[ i ].SetColorsFromLinearColor( PlayerBaseColor );
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function TickHUD()
{
	local int i, j;
	local int PlaceInGoldStandings;
	local SSG_PlayerController SSG_PC, FirstPlayer;
	local array< SSG_PlayerController > PlayerRanks;
	local int PlayerID;

	GetGameViewportClient().GetViewportSize( WindowDimensions );

	//UpdateTimer( ActiveGameInfo.SecondsLeftUntilSuddenDeath );

	//UpdateObjectiveIndicator();
	//UpdateObjectiveCompass();

	foreach GetPC().WorldInfo.AllControllers( class'SSG_PlayerController', SSG_PC )
	{
		UpdatePlayerIndicator( SSG_PC );
		SetPlayerName( LocalPlayer( SSG_PC.Player ).ControllerID, SSG_PC.ThiefName, SSG_PC.LivesLived );
		SetTreasureAmount( LocalPlayer( SSG_PC.Player ).ControllerID, SSG_PC.MoneyEarned );
		if(LocalPlayer( SSG_PC.Player ).ControllerID == 0)
		{
			FirstPlayer = SSG_PC;
		}

		for( i = 0; i <= PlayerRanks.Length; ++i )
		{
			if( i == PlayerRanks.Length )
			{
				PlayerRanks.AddItem( SSG_PC );
				break;
			}

			if( PlayerRanks[ i ].MoneyEarned < SSG_PC.MoneyEarned )
			{
				PlayerRanks.InsertItem( i, SSG_PC );
				break;
			}
		}
	}

	PlaceInGoldStandings = 1;
	for( i = 0; i < PlayerRanks.Length; ++i )
	{
		PlayerID = LocalPlayer( PlayerRanks[ i ].Player ).ControllerID;

		if( i != 0 && PlayerRanks[ i - 1 ].MoneyEarned > PlayerRanks[ i ].MoneyEarned )
			++PlaceInGoldStandings;

		if(PlayerRanks.Length > 1)
		{
			if( PlaceInGoldStandings == 1 && WasInFirst[ PlayerID ] == 0 && PlayerRanks[1].MoneyEarned + GoldLeadThreshold < PlayerRanks[0].MoneyEarned)
			{
				PlayerHUD[ PlayerID ].ReleaseMedalPopup();
				FirstPlayer.Announcer.PlayAnnouncement(class'SSG_Message_TakenLead', PlayerID);
				FirstPlayer.ReceiveLocalizedMessage(class'SSG_Message_TakenLead', PlayerID);
				for(j = 0; j < 4; j++)
				{
					WasInFirst[j] = 0;
				}
				WasInFirst[PlayerID] = 1;
			}
		}

		//Set the corner HUD for this player to the place (which is indexed at 1.)
		CornerHUD[ PlayerID ].SetPlace( PlaceInGoldStandings );
		EdgeHUD[ PlayerID ].SetPlace( PlaceInGoldStandings );
	}
}

//----------------------------------------------------------------------------------------------------------
function PopupTimeChange( int TimeChangeSeconds )
{
	local String TimeString;
	if( TimeChangeSeconds >= 0 )
	{
		TimeString = "+" $ class'Text_Formatting'.static.FormatTimeIntoString( TimeChangeSeconds );
		EnrageTimer.ReleaseTimePopup( TimeString, 0, 255, 0 );
	}
	else
	{
		TimeString = "-" $ class'Text_Formatting'.static.FormatTimeIntoString( TimeChangeSeconds );
		EnrageTimer.ReleaseTimePopup( TimeString, 255, 0, 0 );
	}
}

//----------------------------------------------------------------------------------------------------------
function SetObjectScaledScreenPosition( GFxObject Obj, float X, float Y )
{
	local Vector2D PositionAsScreenPercentage;

	PositionAsScreenPercentage.X = X / WindowDimensions.X;
	PositionAsScreenPercentage.Y = Y / WindowDimensions.Y;

	Obj.SetPosition( HudDimensions.X * PositionAsScreenPercentage.X, HudDimensions.Y * PositionAsScreenPercentage.Y );
}

//----------------------------------------------------------------------------------------------------------
function SetPlayerName( int PlayerID, string PlayerName, int NumberOfLives )
{
	CornerHUD[ PlayerID ].SetName( PlayerName );
	EdgeHUD[ PlayerID ].SetName( PlayerName );
	PlayerHUD[ PlayerID ].SetName( PlayerName );
}

//----------------------------------------------------------------------------------------------------------
function SetTreasureAmount( int PlayerID, int TreasureAmount )
{
	CornerHUD[ PlayerID ].SetTreasure( string( TreasureAmount ) );
	EdgeHUD[ PlayerID ].SetTreasure( string( TreasureAmount ) );
	PlayerHUD[ PlayerID ].SetTreasure( string( TreasureAmount ) );
}



//++++++++++++++++++++++++++++++++++++++++++++ Update Helpers ++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function UpdateHUDCorner( int PlayerID, SSG_PlayerController SSG_PC )
{
	local SSG_HUD_Corner HUDCorner;

	HUDCorner = CornerHUD[ PlayerID ];

	HUDCorner.SetVisible( true );

	if( SSG_PC.Pawn == None )
	{
		HUDCorner.SetIconToAButton();
		HUDCorner.SetHealthLevel( 0 );
		//HUDCorner.SetBackgroundColor( 128, 128, 128 );
		HUDCorner.SetNameTextColor( 255, 0, 0 );
	}
	else
	{
		HUDCorner.SetHealthLevel( SSG_PC.Pawn.Health );
		//HUDCorner.SetColorsFromLinearColor( SSG_PC.PlayerColors[ PlayerID ] );
		HUDCorner.SetNameTextColor( 255, 255, 255 );

		HUDCorner.SetIconToNone();
	}
}

//----------------------------------------------------------------------------------------------------------
function UpdateHUDEdge( int PlayerID, SSG_PlayerController SSG_PC )
{
	local SSG_HUD_Edge HUDEdge;

	HUDEdge = EdgeHUD[ PlayerID ];

	HUDEdge.SetVisible( true );

	if( SSG_PC.Pawn == None )
	{
		HUDEdge.SetIconToAButton();
		HUDEdge.SetHealthLevel( 0 );
		//HUDCorner.SetBackgroundColor( 128, 128, 128 );
		HUDEdge.SetNameTextColor( 255, 0, 0 );
	}
	else
	{
		HUDEdge.SetHealthLevel( SSG_PC.Pawn.Health );
		//HUDCorner.SetColorsFromLinearColor( SSG_PC.PlayerColors[ PlayerID ] );
		HUDEdge.SetNameTextColor( 255, 255, 255 );

		HUDEdge.SetIconToNone();
	}
}

//----------------------------------------------------------------------------------------------------------
function UpdateHUDRing( int PlayerID, SSG_PlayerController SSG_PC, Vector PlayerScreenLocation )
{
	local SSG_HUD_Ring HUDRing;

	HUDRing = PlayerHUD[ PlayerID ];
	HUDRing.SetVisible( true );

	SetObjectScaledScreenPosition( HUDRing, PlayerScreenLocation.X, PlayerScreenLocation.Y );

	HUDRing.SetHealthLevel( SSG_PC.Pawn.Health );
	HUDRing.SetFacingArrowRotation( SSG_PC.Pawn.Rotation.Yaw * URotToDegree );

	// This has been moved to a new function called UpdateChangeInMoneyPopup()
	//if( SSG_PC.MoneyEarnedSinceLastUpdate > 0 )
	//	HUDRing.ReleaseTreasurePopup( "+" $ SSG_PC.MoneyEarnedSinceLastUpdate, 0, 255, 0 );
	//else if( SSG_PC.MoneyEarnedSinceLastUpdate < 0)
	//	HUDRing.ReleaseTreasurePopup( "" $ SSG_PC.MoneyEarnedSinceLastUpdate, 255, 0, 0 );
	//SSG_PC.MoneyEarnedSinceLastUpdate = 0;

	// if( SSG_PC.TakenDamageSinceLastUpdate )
	// {
	// 	HUDRing.ReleaseHealthPopup( "--", 255, 0, 0 );
	// 	SSG_PC.TakenDamageSinceLastUpdate = false;
	// }

	if( SSG_PC.IDOfWeaponPickedUpLastUpdate != 0 )
	{
		switch( SSG_PC.IDOfWeaponPickedUpLastUpdate )
		{
			case ID_Crossbow:
				HUDRing.ReleaseCrossbowPopup( "+", 0, 255, 0 );
				break;
			case ID_Shield:
				HUDRing.ReleaseShieldPopup( "+", 0, 255, 0 );
				break;
			default:
				break;
		}
		SSG_PC.IDOfWeaponPickedUpLastUpdate = 0;
	}

	if( SSG_PC.bShowPlayerHUD )
		HUDRing.ShowName();
	else
		HUDRing.HideName();

	if( bShowRingHUD )
	{
		HUDRing.ShowTreasure();
	}
	else
	{
		HUDRing.HideTreasure();
	}
	HUDRing.HideHealth();
}

//----------------------------------------------------------------------------------------------------------
function UpdateChangeInMoneyPopup( int PlayerID, SSG_PlayerController SSG_PC )
{
	local SSG_HUD_Ring HUDRing;

	HUDRing = PlayerHUD[ PlayerID ];

	if( SSG_PC.MoneyEarnedSinceLastUpdate > 0 )
		HUDRing.ReleaseTreasurePopup( "+" $ SSG_PC.MoneyEarnedSinceLastUpdate, 0, 255, 0 );
	else if( SSG_PC.MoneyEarnedSinceLastUpdate < 0)
		HUDRing.ReleaseTreasurePopup( "" $ SSG_PC.MoneyEarnedSinceLastUpdate, 255, 0, 0 );

	SSG_PC.MoneyEarnedSinceLastUpdate = 0;
}

//----------------------------------------------------------------------------------------------------------
function UpdateObjectiveCompass()
{
	local Vector ObjectiveScreenPosition;
	local Vector ScreenCenter;
	local Vector VectorFromObjectiveToCenter;
	local float AngleToObjectiveRadians;

	if( ActiveGameInfo.CurrentObjective == None )
	{
		ObjectiveCompass.HideArrow();
		return;
	}

	ObjectiveScreenPosition = GetPC().myHUD.Canvas.Project( ActiveGameInfo.CurrentObjective.Location );
	if( GetObjectScreenState( ObjectiveScreenPosition ) == STATE_OnScreen )
	{
		ObjectiveCompass.HideArrow();
		return;
	}

	ObjectiveCompass.ShowArrow();

	ScreenCenter.X = WindowDimensions.X / 2.0;
	ScreenCenter.Y = WindowDimensions.Y / 2.0;
	VectorFromObjectiveToCenter = ScreenCenter - ObjectiveScreenPosition;
	AngleToObjectiveRadians = ATan2( VectorFromObjectiveToCenter.X, VectorFromObjectiveToCenter.Y );
	ObjectiveCompass.SetArrowRotation( AngleToObjectiveRadians * RadToDeg );
}

//----------------------------------------------------------------------------------------------------------
function UpdateObjectiveIndicator()
{
	local Vector2D ArrowLocation;
	local Vector ObjectiveScreenPosition;
	local EScreenState ObjectiveScreenState;

	if( ActiveGameInfo.CurrentObjective == None )
	{
		ObjectiveArrow.SetVisible( false );
		return;
	}

	ObjectiveScreenPosition = GetPC().myHUD.Canvas.Project( ActiveGameInfo.CurrentObjective.Location );
	ObjectiveScreenState = GetObjectScreenState( ObjectiveScreenPosition );
	if(ObjectiveScreenState  == STATE_OnScreen )
	{
		ObjectiveArrow.SetVisible( false );
		return;
	}

	ObjectiveArrow.SetVisible( true );

	switch( ObjectiveScreenState )
	{
		case STATE_OffNorthEdge:
			ObjectiveArrow.SetRotation( 45 );
			ArrowLocation.X = ObjectiveScreenPosition.X;
			ArrowLocation.Y = 0.0;
		break;
		case STATE_OffSouthEdge:
			ObjectiveArrow.SetRotation( 225 );
			ArrowLocation.X = ObjectiveScreenPosition.X;
			ArrowLocation.Y = WindowDimensions.Y;
		break;
		case STATE_OffWestEdge:
			ObjectiveArrow.SetRotation( -45 );
			ArrowLocation.X = 0.0;
			ArrowLocation.Y = ObjectiveScreenPosition.Y;
		break;
		case STATE_OffNorthWest:
			ObjectiveArrow.SetRotation( 0 );
			ArrowLocation.X = 0.0;
			ArrowLocation.Y = 0.0;
		break;
		case STATE_OffSouthWest:
			ObjectiveArrow.SetRotation( -90 );
			ArrowLocation.X = 0.0;
			ArrowLocation.Y = WindowDimensions.Y;
		break;
		case STATE_OffEastEdge:
			ObjectiveArrow.SetRotation( 135 );
			ArrowLocation.X = WindowDimensions.X;
			ArrowLocation.Y = ObjectiveScreenPosition.Y;
		break;
		case STATE_OffNorthEast:
			ObjectiveArrow.SetRotation( 90 );
			ArrowLocation.X = WindowDimensions.X;
			ArrowLocation.Y = 0.0;
		break;
		case STATE_OffSouthEast:
		default:
			ObjectiveArrow.SetRotation( 180 );
			ArrowLocation.X = WindowDimensions.X;
			ArrowLocation.Y = WindowDimensions.Y;
		break;
	}
	SetObjectScaledScreenPosition( ObjectiveArrow, ArrowLocation.X, ArrowLocation.Y );
}

//----------------------------------------------------------------------------------------------------------
function UpdateOffscreenArrow( int PlayerID, SSG_PlayerController SSG_PC, Vector PlayerScreenLocation, EScreenState PlayerScreenState )
{
	const ARROW_OFFSET = 0.0;
	local SSG_HUD_Arrow HUDArrow;
	local Vector2D ArrowLocation;

	HUDArrow = PlayerArrows[ PlayerID ];
	HUDArrow.SetVisible( true );
	HudArrow.SetToOffscreenMode();

	switch( PlayerScreenState )
	{
		case STATE_OffNorthEdge:
			HUDArrow.SetRotation( 45 );
			ArrowLocation.X = PlayerScreenLocation.X;
			ArrowLocation.Y = 0.0;
		break;
		case STATE_OffSouthEdge:
			HUDArrow.SetRotation( 225 );
			ArrowLocation.X = PlayerScreenLocation.X;
			ArrowLocation.Y = WindowDimensions.Y;
		break;
		case STATE_OffWestEdge:
			HUDArrow.SetRotation( -45 );
			ArrowLocation.X = 0.0;
			ArrowLocation.Y = PlayerScreenLocation.Y;
		break;
		case STATE_OffNorthWest:
			HUDArrow.SetRotation( 0 );
			ArrowLocation.X = 0.0;
			ArrowLocation.Y = 0.0;
		break;
		case STATE_OffSouthWest:
			HUDArrow.SetRotation( -90 );
			ArrowLocation.X = 0.0;
			ArrowLocation.Y = WindowDimensions.Y;
		break;
		case STATE_OffEastEdge:
			HUDArrow.SetRotation( 135 );
			ArrowLocation.X = WindowDimensions.X;
			ArrowLocation.Y = PlayerScreenLocation.Y;
		break;
		case STATE_OffNorthEast:
			HUDArrow.SetRotation( 90 );
			ArrowLocation.X = WindowDimensions.X;
			ArrowLocation.Y = 0.0;
		break;
		case STATE_OffSouthEast:
		default:
			HUDArrow.SetRotation( 180 );
			ArrowLocation.X = WindowDimensions.X;
			ArrowLocation.Y = WindowDimensions.Y;
		break;
	}
	SetObjectScaledScreenPosition( HUDArrow, ArrowLocation.X, ArrowLocation.Y );
	HUDArrow.SetTimeText( string( SSG_PC.SecondsLeftBeforeKilled ) );
}

//----------------------------------------------------------------------------------------------------------
function UpdatePlayerIndicator( PlayerController PlayerControl )
{
	local int ControllerID;
	local Pawn PlayerPawn;
	local Vector PlayerScreenLocation;
	local SSG_PlayerController SSG_PC;
	local EScreenState PlayerScreenState;

	ControllerID = LocalPlayer( PlayerControl.Player ).ControllerID;

	SSG_PC = SSG_PlayerController( PlayerControl );
	if( SSG_PC == None )
		return;

	if( bShowCornerHUD )
		UpdateHUDCorner( ControllerID, SSG_PC );
	else
		CornerHUD[ ControllerID ].SetVisible( false );

	if( bShowEdgeHUD )
		UpdateHUDEdge( ControllerID, SSG_PC );
	else
		EdgeHUD[ ControllerID ].SetVisible( false );

	UpdateChangeInMoneyPopup( ControllerID, SSG_PC );

	PlayerPawn = PlayerControl.Pawn;
	if( PlayerPawn == None )
	{
		//PlayerHUD[ ControllerID ].SetVisible( false );
		PlayerArrows[ ControllerID ].SetVisible( false );
		//UpdateRespawnArrow( ControllerID );
		return;
	}

	PlayerScreenLocation = GetPC().myHUD.Canvas.Project( PlayerPawn.Location );

	PlayerScreenState = GetObjectScreenState( PlayerScreenLocation );
	if( PlayerScreenState == STATE_OnScreen )
	{
		SSG_PC.bIsOffScreen = false;
		PlayerArrows[ ControllerID ].SetVisible( false );
		UpdateHUDRing( ControllerID, SSG_PC, PlayerScreenLocation );
	}
	else
	{
		SSG_PC.bIsOffScreen = true;
		PlayerHUD[ ControllerID ].SetVisible( false );
		UpdateOffscreenArrow( ControllerID, SSG_PC, PlayerScreenLocation, PlayerScreenState );
	}
}

//----------------------------------------------------------------------------------------------------------
function UpdateRespawnArrow( int ArrowID )
{
	local Pawn PawnToRespawnOn;
	local Vector SpawnScreenLocation;

	PawnToRespawnOn = ActiveGameInfo.FindLivingPlayerPawn();
	if( PawnToRespawnOn == None )
	{
		PlayerArrows[ ArrowID ].SetVisible( false );
		return;
	}

	PlayerArrows[ ArrowID ].SetVisible( true );
	PlayerArrows[ ArrowID ].SetToRespawnMode();

	SpawnScreenLocation = GetPC().myHUD.Canvas.Project( PawnToRespawnOn.Location );
	SetObjectScaledScreenPosition( PlayerArrows[ ArrowID ], SpawnScreenLocation.X + RespawnArrowPositionOffset[ ArrowID ].X, 
															SpawnScreenLocation.Y + RespawnArrowPositionOffset[ ArrowID ].Y );

	PlayerArrows[ ArrowID ].SetRotation( 225 - RespawnArrowRotationOffset[ ArrowID ] );
}

//----------------------------------------------------------------------------------------------------------
function EScreenState GetObjectScreenState( Vector ObjectScreenLocation )
{
	const HALF_RING_WIDTH = 20.0;
	local byte ScreenStateAsByte;
	ScreenStateAsByte = 0;

	if( ObjectScreenLocation.Y + HALF_RING_WIDTH < 0.0 )
		ScreenStateAsByte += STATE_OffNorthEdge;
	if( ObjectScreenLocation.Y - HALF_RING_WIDTH > WindowDimensions.Y )
		ScreenStateAsByte += STATE_OffSouthEdge;
	if( ObjectScreenLocation.X + HALF_RING_WIDTH < 0.0 )
		ScreenStateAsByte += STATE_OffWestEdge;
	if( ObjectScreenLocation.X - HALF_RING_WIDTH > WindowDimensions.X )
		ScreenStateAsByte += STATE_OffEastEdge;

	return EScreenState( ScreenStateAsByte );
}

//----------------------------------------------------------------------------------------------------------
function UpdateTimer( int SecondsRemaining )
{
	EnrageTimer.SetTimeText( class'Text_Formatting'.static.FormatTimeIntoString( SecondsRemaining ) );

	if( SecondsRemaining == 0 )
	{
		// if( !SirenStarted )
		// {
		// 	EnrageTimer.ShowGuards();
		// 	EnrageTimer.StartSiren();
		// 	SirenStarted = true;
		// }
		return;
	}

	// EnrageTimer.HideGuards();
	// EnrageTimer.StopSiren();
	// SirenStarted = false;

	if( SecondsRemaining > TIME_LEFT_WARNING )
		EnrageTimer.SetTextColor( 255, 255, 255 );
	else if( SecondsRemaining > TIME_LEFT_CRITICAL )
		EnrageTimer.SetTextColor( 255, 255, 0 );
	else
		EnrageTimer.SetTextColor( 255, 0, 0 );
}



//----------------------------------------------------------------------------------------------------------
defaultproperties
{
	bDisplayWithHudoff=false
	MovieInfo=SwfMovie'InGameHUD.InGameHUD'
	SirenStarted=false

	bShowCornerHUD=false
	bShowEdgeHUD=true
	bShowRingHUD=false

	RespawnArrowPositionOffset(0)=( X=0.0, Y=-30.0 )
	RespawnArrowPositionOffset(1)=( X=0.0, Y=-30.0 )
	RespawnArrowPositionOffset(2)=( X=0.0, Y=-30.0 )
	RespawnArrowPositionOffset(3)=( X=0.0, Y=-30.0 )

	RespawnArrowRotationOffset(0)= 90
	RespawnArrowRotationOffset(1)= 30
	RespawnArrowRotationOffset(2)=-30
	RespawnArrowRotationOffset(3)=-90

	ScaleformArrowNames(0)="_root.mc_player_1_arrow"
	ScaleformArrowNames(1)="_root.mc_player_2_arrow"
	ScaleformArrowNames(2)="_root.mc_player_3_arrow"
	ScaleformArrowNames(3)="_root.mc_player_4_arrow"

	ScaleformCornerNames(0)="_root.mc_player_1_corner"
	ScaleformCornerNames(1)="_root.mc_player_2_corner"
	ScaleformCornerNames(2)="_root.mc_player_3_corner"
	ScaleformCornerNames(3)="_root.mc_player_4_corner"

	ScaleformEdgeNames(0)="_root.mc_player_1_edge"
	ScaleformEdgeNames(1)="_root.mc_player_2_edge"
	ScaleformEdgeNames(2)="_root.mc_player_3_edge"
	ScaleformEdgeNames(3)="_root.mc_player_4_edge"

	ScaleformRingNames(0)="_root.mc_player_1_hud"
	ScaleformRingNames(1)="_root.mc_player_2_hud"
	ScaleformRingNames(2)="_root.mc_player_3_hud"
	ScaleformRingNames(3)="_root.mc_player_4_hud"

	WasInFirst(0)=0
	WasInFirst(1)=0
	WasInFirst(2)=0
	WasInFirst(3)=0
	GoldLeadThreshold=1100
}
