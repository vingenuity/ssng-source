class SSG_HUD_Base extends UDKHUD
	dependson( Text_Formatting );

//----------------------------------------------------------------------------------------------------------
enum ETextHorizontalAlignment
{
	ALIGN_Left<DisplayName=Left Aligned>,
	ALIGN_Center<DisplayName=Centered>,
	ALIGN_Right<DisplayName=Right Aligned>
};

enum ETextVerticalAlignment
{
	ALIGN_Top<DisplayName=Top Aligned>,
	ALIGN_Center<DisplayName=Centered>,
	ALIGN_Bottom<DisplayName=Bottom Aligned>
};

var int BotDebugVerbosity;
var bool ShouldShowGameOverMessage;

var SSG_HUD_Scaleform InGameHUD;
var SSG_HUD_IntroScreen IntroScreen;
var SSG_Menu_Loading LoadingScreen;
var SSG_Menu_Pause PauseMenu;
var SSG_Menu_Victory VictoryScreen;
var SSG_Cutscene_Closing ClosingCutscene;

var string LastLevelName;

//++++++++++++++++++++++++++++++++++++++++++ Lifecycle Functions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

 	InGameHUD = new class'SSG_HUD_Scaleform';
 	InGameHUD.SetTimingMode(TM_Real);
 	InGameHUD.Init( LocalPlayer( PlayerOwner.Player ) );

 	LoadingScreen = new class'SSG_Menu_Loading';
 	LoadingScreen.SetTimingMode( TM_Real );
 	LoadingScreen.Init( LocalPlayer( PlayerOwner.Player ) );
    SetTimer(0.05f, true, NameOf(CheckForLevelLoad));

    SSG_GameInfo( WorldInfo.Game ).TeamHUD = self;

 	// IntroScreen = new class'SSG_HUD_IntroScreen';
 	// IntroScreen.SetTimingMode(TM_Real);
 	// IntroScreen.Init( LocalPlayer( PlayerOwner.Player ) );
}

//----------------------------------------------------------------------------------------------------------
//This is a riff on http://udn.epicgames.com/Three/DevelopmentKitGemsSaveGameStates.html#When the map has finished loading, reload the saved game state object
// In this case, we are preventing the player from seeing the "popping" of objects when streams are loaded.
function CheckForLevelLoad()
{
	local int i;
	local SSG_Pawn CurrentPawn;

	for ( i = 0; i < WorldInfo.StreamingLevels.Length; ++i )
	{
		// Don't start until everything is visible
		if ( !WorldInfo.StreamingLevels[i].bIsVisible )
		{
			return;
		}
	}

	// Clear the looping timer
	ClearTimer( NameOf( CheckForLevelLoad ) );
	LoadingScreen.ShowLoaded();
	LoadingScreen.SetExternalInterface( LoadingScreen );
	//LoadingScreen = None; //The Loading Screen will close itself when the time comes
	foreach WorldInfo.AllPawns(class'SSG_Pawn', CurrentPawn)
	{
		CurrentPawn.CustomGravityScaling = 1.0;
	}
	SSG_GameInfo(WorldInfo.Game).bIsFullyLoaded = true;
}

//----------------------------------------------------------------------------------------------------------
event PostRender()
{

	super.PostRender();

	if( InGameHUD != None )
		InGameHUD.TickHUD();

	//DrawDebugPlayerHUD();
	//DrawDebugTimer();
	DrawBotDebugInfo();

	if( ShouldShowGameOverMessage )
		DrawGameOverMessage();
}

//----------------------------------------------------------------------------------------------------------
singular event Destroyed()
{
	super.Destroyed();
	
	ExitHUD();
}

//----------------------------------------------------------------------------------------------------------
exec function ExitHUD()
{
	if( InGameHUD != None )
	{
		InGameHUD.Close( true );
		InGameHUD = None;
	}
	if( IntroScreen != None )
	{
		IntroScreen.Close( true );
		IntroScreen = None;
	}
	if( LoadingScreen != None )
	{
		LoadingScreen.Close( true );
		LoadingScreen = None;
	}
	if( PauseMenu != None )
	{
		PauseMenu.Close( true );
		PauseMenu = None;
	}
	if( VictoryScreen != None )
	{
		VictoryScreen.Close( true );
		VictoryScreen = None;
	}
}

//----------------------------------------------------------------------------------------------------------
function PopupTimeChange( int TimeChangeSeconds )
{
	InGameHUD.PopupTimeChange( TimeChangeSeconds );
}


//++++++++++++++++++++++++++++++++++++++++++ Text Helper Functions +++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function DrawTextAlignedAndScaled( string text, float xPosition, float yPosition,
									optional float xScale = 1.0, optional float yScale = 1.0,
									optional ETextHorizontalAlignment xAlignment = ALIGN_Left, optional ETextVerticalAlignment yAlignment = ALIGN_Top )
{
	local float alignedXPosition, alignedYPosition;

	local float textWidth, textHeight;
	Canvas.TextSize( text, textWidth, textHeight ); //Get the true width of our text

	switch( xAlignment )
	{
		case ALIGN_Right:
			alignedXPosition = xPosition - ( textWidth * xScale );
			break;
		case ALIGN_Center:
			alignedXPosition = xPosition - ( ( textWidth * xScale ) * 0.5 );
			break;
		case ALIGN_Left:
		default:
			alignedXPosition = xPosition;
			break;
	}

	switch( yAlignment )
	{
		case ALIGN_Bottom:
			alignedYPosition = yPosition - ( textHeight * yScale );
			break;
		case ALIGN_Center:
			alignedYPosition = yPosition - ( ( textHeight * yScale ) * 0.5 );
			break;
		case ALIGN_Top:
		default:
			alignedYPosition = yPosition;
			break;
	}

	Canvas.SetPos( alignedXPosition, alignedYPosition );
	Canvas.DrawText( text, false, xScale, yScale );
}

//----------------------------------------------------------------------------------------------------------
function LocalizeConfirmationPopup()
{
	local string LocalizationSection;
	local int PopupType;
	local GFxObject Title;
	local string TitleString;
	local GFxObject Button;
	local string ButtonString;
	LocalizationSection="SSG_Menu_Pause";

	Title = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.text_sure");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "pauseLabelConfirmationSure");
	Title.SetText(TitleString);

	Title = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.text_progress");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "pauseLabelConfirmationProgress");
	Title.SetText(TitleString);

	PopupType = PauseMenu.GetVariableInt("_root.mc_menu.confirmation_popup.type");
	if(PopupType == 0)
	{
		//map
		Title = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.text_title");
		TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "pauseTitleConfirmationMenu");
		Title.SetText(TitleString);
	}
	else if( PopupType == 1 )
	{
		//quit
		Title = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.text_title");
		TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "pauseTitleConfirmationQuit");
		Title.SetText(TitleString);
	}
	else
	{
		Title = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.text_title");
		TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "pauseTitleConfirmationMainMenu");
		Title.SetText(TitleString);
	}

	Button = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.mc_confirm_frame.button_yes");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseTitleConfirmationYes");
	Button.SetString("label", ButtonString);

	Button = PauseMenu.GetVariableObject("_root.mc_menu.confirmation_popup.mc_confirm_frame.button_no");
	ButtonString = class'Text_Localizer'.static.GetLocalizedStringWithName(localizationSection, "pauseTitleConfirmationNo");
	Button.SetString("label", ButtonString);

}


//+++++++++++++++++++++++++++++++++++++++++ Debug Drawing Functions ++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function DrawDebugPlayerHUD()
{
	const HUD_BOX_WIDTH = 130;
	const HUD_BOX_HEIGHT = 80;
	local LinearColor HUDDrawColor;

	local PlayerController localPlayerController;
	foreach LocalPlayerControllers( class'PlayerController', localPlayerController )
	{
		HUDDrawColor = class'SSG_PlayerController'.default.PlayerColors[ LocalPlayer( localPlayerController.Player ).ControllerID ];

		switch( LocalPlayer( localPlayerController.Player ).ControllerID )
		{
			case 3:
				Canvas.SetPos( Canvas.ClipX - HUD_BOX_WIDTH, Canvas.ClipY - HUD_BOX_HEIGHT );
				Canvas.SetDrawColor( 192, 192, 192 );
				Canvas.DrawRect( HUD_BOX_WIDTH, HUD_BOX_HEIGHT );
				Canvas.SetDrawColor( HUDDrawColor.R * 255, HUDDrawColor.G * 255, HUDDrawColor.B * 255 );
				DrawPawnInfoAtPosition( "Player 4", SSG_Pawn( localPlayerController.Pawn ), Canvas.ClipX - HUD_BOX_WIDTH, 	Canvas.ClipY - HUD_BOX_HEIGHT, ALIGN_Left );
				break;
			case 2:
				Canvas.SetPos( 0, Canvas.ClipY - HUD_BOX_HEIGHT );
				Canvas.SetDrawColor( 192, 192, 192 );
				Canvas.DrawRect( HUD_BOX_WIDTH, HUD_BOX_HEIGHT );
				Canvas.SetDrawColor( HUDDrawColor.R * 255, HUDDrawColor.G * 255, HUDDrawColor.B * 255 );
				DrawPawnInfoAtPosition( "Player 3", SSG_Pawn( localPlayerController.Pawn ), 0,								Canvas.ClipY - HUD_BOX_HEIGHT, ALIGN_Left );
				break;
			case 1:
				Canvas.SetPos( Canvas.ClipX - HUD_BOX_WIDTH, 0 );
				Canvas.SetDrawColor( 192, 192, 192 );
				Canvas.DrawRect( HUD_BOX_WIDTH, HUD_BOX_HEIGHT );
				Canvas.SetDrawColor( HUDDrawColor.R * 255, HUDDrawColor.G * 255, HUDDrawColor.B * 255 );
				DrawPawnInfoAtPosition( "Player 2", SSG_Pawn( localPlayerController.Pawn ), Canvas.ClipX - HUD_BOX_WIDTH,	0, 								ALIGN_Left );
				break;
			case 0:
			default:
				Canvas.SetPos( 0, 0 );
				Canvas.SetDrawColor( 192, 192, 192 );
				Canvas.DrawRect( HUD_BOX_WIDTH, HUD_BOX_HEIGHT );
				Canvas.SetDrawColor( HUDDrawColor.R * 255, HUDDrawColor.G * 255, HUDDrawColor.B * 255 );
				DrawPawnInfoAtPosition( "Player 1", SSG_Pawn( localPlayerController.Pawn ), 0, 								0, 								ALIGN_Left );
				break;
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function DrawDebugTimer()
{
	local int SecondsLeft;
	SecondsLeft = SSG_GameInfo( WorldInfo.Game ).SecondsLeftUntilSuddenDeath;

	Canvas.SetDrawColor( 255, 255, 255 );
	DrawTextAlignedAndScaled( "Sudden Death In:" @ class'Text_Formatting'.static.FormatTimeIntoString( SecondsLeft ), Canvas.ClipX / 2, 50, HUD_HORZ_SCALE, HUD_VERT_SCALE, ALIGN_Center, ALIGN_Center );
}

//----------------------------------------------------------------------------------------------------------
function DrawPawnInfoAtPosition( string headerText, SSG_Pawn pawn, float screenXPos, float screenYPos, ETextHorizontalAlignment alignment )
{
	const TEXT_GAP = 20.0;
	const HUD_HORZ_SCALE = 1.3;
	const HUD_VERT_SCALE = 1.3;

	local SSG_PlayerController PC;

	DrawTextAlignedAndScaled( headerText, 	screenXPos, 	screenYPos, 				HUD_HORZ_SCALE, HUD_VERT_SCALE, alignment, ALIGN_Top );

	if( pawn == None )
	{
		DrawTextAlignedAndScaled( "Press START to play!", 		screenXPos, 	screenYPos + TEXT_GAP, 		HUD_HORZ_SCALE, HUD_VERT_SCALE, alignment, ALIGN_Top );
		return;
	}

	PC = SSG_PlayerController( Pawn.Controller );
	if( PC == None )
	{
		DrawTextAlignedAndScaled( "Press START to play!", 		screenXPos, 	screenYPos + TEXT_GAP, 		HUD_HORZ_SCALE, HUD_VERT_SCALE, alignment, ALIGN_Top );
		return;
	}

	DrawTextAlignedAndScaled( "Health:" @ pawn.Health, 		screenXPos, 	screenYPos + TEXT_GAP, 		HUD_HORZ_SCALE, HUD_VERT_SCALE, alignment, ALIGN_Top );
	DrawTextAlignedAndScaled( "Treasure:" @ PC.MoneyEarned,	screenXPos,		screenYPos + 2 * TEXT_GAP,	HUD_HORZ_SCALE, HUD_VERT_SCALE, alignment, ALIGN_Top );
	DrawTextAlignedAndScaled( "Weapon:" @ "None",				screenXPos, 	screenYPos + 3 * TEXT_GAP, 	HUD_HORZ_SCALE, HUD_VERT_SCALE, alignment, ALIGN_Top );
}

//----------------------------------------------------------------------------------------------------------
function DrawBotDebugInfo()
{
	local SSG_Bot BotController;
	local Vector BotPositionOnScreen;
	local int currentLine;
	local int nodeIterator;
	const BOT_DEBUG_OFFSET = -40;
	const BOT_LEFT_OFFSET = -10;
	const LINE_OFFSET = -10;

	if(BotDebugVerbosity > 0)
	{
		foreach WorldInfo.AllActors(class'SSG_Bot', BotController)
		{
			BotPositionOnScreen = Canvas.Project(BotController.Pawn.Location);
			currentLine = 0;

			Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
			DrawTextAlignedAndScaled(string(BotController.GetStateName()), BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
			Canvas.SetDrawColor( 255, 255, 255 ); //White
			DrawTextAlignedAndScaled(string(BotController.GetStateName()), BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
			currentLine++;

			Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
			DrawTextAlignedAndScaled(BotController.ReasonIAmNotMoving, BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
			Canvas.SetDrawColor( 255, 255, 255 ); //White
			DrawTextAlignedAndScaled(BotController.ReasonIAmNotMoving, BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
			currentLine++;

			if(BotDebugVerbosity > 1)
			{
				Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
				DrawTextAlignedAndScaled("Home:"@int(BotController.Home.X)$","@int(BotController.Home.Y), BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
				Canvas.SetDrawColor( 255, 255, 255 ); //White
				DrawTextAlignedAndScaled("Home:"@int(BotController.Home.X)$","@int(BotController.Home.Y), BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
				currentLine++;

				Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
				DrawTextAlignedAndScaled("Loc:"@int(BotController.Pawn.Location.X)$","@int(BotController.Pawn.Location.Y), BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
				Canvas.SetDrawColor( 255, 255, 255 ); //White
				DrawTextAlignedAndScaled("Loc:"@int(BotController.Pawn.Location.X)$","@int(BotController.Pawn.Location.Y), BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
				currentLine++;
				
				if(BotController.StationaryOrientationTarget != none)
				{
					Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
					DrawTextAlignedAndScaled("Lookat:"@int(BotController.StationaryOrientationTarget.Location.X)$","@int(BotController.StationaryOrientationTarget.Location.Y), BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
					Canvas.SetDrawColor( 255, 255, 255 ); //White
					DrawTextAlignedAndScaled("Lookat:"@int(BotController.StationaryOrientationTarget.Location.X)$","@int(BotController.StationaryOrientationTarget.Location.Y), BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
					currentLine++;
				}
				else
				{
					Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
					DrawTextAlignedAndScaled("No Lookat", BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
					Canvas.SetDrawColor( 255, 255, 255 ); //White
					DrawTextAlignedAndScaled("No Lookat", BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
					currentLine++;
				}
				if(BotDebugVerbosity > 2)
				{
					Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
					DrawTextAlignedAndScaled("Controller:"@BotController.Name, BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
					Canvas.SetDrawColor( 255, 255, 255 ); //White
					DrawTextAlignedAndScaled("Controller:"@BotController.Name, BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
					currentLine++;
					for(nodeIterator = 0; nodeIterator < BotController.PatrolPath.Length; nodeIterator++)
					{
						Canvas.SetDrawColor( 0, 0, 0 ); //Drop shadow
						DrawTextAlignedAndScaled(string(BotController.PatrolPath[nodeIterator].Name), BotPositionOnScreen.X+1+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+1+LINE_OFFSET*currentLine);
						Canvas.SetDrawColor( 255, 255, 255 ); //White
						DrawTextAlignedAndScaled(string(BotController.PatrolPath[nodeIterator].Name), BotPositionOnScreen.X+BOT_LEFT_OFFSET, BotPositionOnScreen.Y+BOT_DEBUG_OFFSET+LINE_OFFSET*currentLine);
						currentLine++;
					}
				}
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function DrawGameOverMessage()
{
	Canvas.SetDrawColor( 255, 255, 255 ); //White
	DrawTextAlignedAndScaled("Game Over!", Canvas.ClipX*0.5, Canvas.ClipY*0.5, 2.0, 2.0, ALIGN_Center, ALIGN_Center );
}

//----------------------------------------------------------------------------------------------------------
function ShowGameOverMessage( bool PlayersWon )
{
	if( InGameHUD != None )
	{
		InGameHUD.Close( true );
		InGameHUD = None;
	}

	if( PlayersWon )
	{
		VictoryScreen = new class'SSG_Menu_Victory';
		VictoryScreen.Init();
	}
}



//+++++++++++++++++++++++++++++++++++++ Scaleform External Interfaces ++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function RestartGame()
{
	WorldInfo.Game.RestartGame();
}

//----------------------------------------------------------------------------------------------------------
function ReturnToMainMenu()
{
	//TODO: open menu level using exec functions
	ExitHUD();
	ConsoleCommand( "SafeOpen " $ "SGS-MainMenu.udk" );
}

//----------------------------------------------------------------------------------------------------------
function ReturnToMap()
{
	local bool PlayingCutscene;
	PlayingCutscene = false;

	`log( WorldInfo.GetMapName( true ) );
	if( (VictoryScreen != None ) && ( WorldInfo.GetMapName( true ) ~= LastLevelName ) )
	{
		VictoryScreen.SetPause( true );
		PlayingCutscene = true;
		ClosingCutscene = new class'SSG_Cutscene_Closing';
		ClosingCutscene.Init();
		PlaySound( SoundCue'SSG_AnnouncerSounds.Cutscene.ClosingCue' );
		//ConsoleCommand( "movietest SSG_Ending_Cutscene" );
	}

	ExitHUD();

	if( !PlayingCutscene )
		ConsoleCommand( "SafeOpen " $ "SGS-MapMenu.udk" );
}

//----------------------------------------------------------------------------------------------------------
function PlayVictorySound()
{
	local SSG_PlayerController SSG_PC;

	foreach class'WorldInfo'.static.getWorldInfo().AllControllers(class'SSG_PlayerController', SSG_PC)
	{
		if( VictoryScreen.GetRank( SSG_PC ) == 0)
		{
			SSG_PC.PlaySound(VictoryScreen.WinningSounds[LocalPlayer(SSG_PC.Player).ControllerId]);
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function SafelyQuitGame()
{
	ExitHUD();
	ConsoleCommand( "Exit" );
}

//----------------------------------------------------------------------------------------------------------
function TogglePauseMenu( int PlayerID )
{
	if( ( PauseMenu != None ) && PauseMenu.bMovieIsOpen )
	{
		PauseMenu.Close( true );
		PauseMenu = None;
	}
	else
	{
		PauseMenu = new class'SSG_Menu_Pause';
		PauseMenu.Init();
		PauseMenu.SetPausingPlayer( PlayerID );
	}
}

//----------------------------------------------------------------------------------------------------------
function EnterOptionsMenu()
{
	PauseMenu.EnterOptionsMenu();
}

//----------------------------------------------------------------------------------------------------------
function SetScorecardVisibility()
{
	//If the player's not signed in...
	//VictoryScreen.GetVariableObject( "_root.mc_player_X_score" ).SetVisible( false );
	//Wait until the localize call to fill out the card
	local SSG_PlayerController currentController;
	local int IsPresent[4];
	local int i;
	IsPresent[0] = 0;
	IsPresent[1] = 0;
	IsPresent[2] = 0;
	IsPresent[3] = 0;
	

	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', currentController)
	{
		IsPresent[LocalPlayer(currentController.Player).ControllerId] = 1;
	}
	for(i = 0; i < 4; i++)
	{
		if(IsPresent[i] == 1)
		{
			VictoryScreen.GetVariableObject( "_root.mc_player_"$i+1$"_score" ).SetVisible( true );
		}
		else
		{
			VictoryScreen.GetVariableObject( "_root.mc_player_"$i+1$"_score" ).SetVisible( false );
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function LocalizeReadyFrame( int controllerID )
{
	//switch on controller id for identification of which card it is
	//Just localize and fill in the player's name.
	local string LocalizationSection;
	local GFxObject Title;
	local string TitleString;
	local SSG_PlayerController currentController;
	local string PlayerName;
	LocalizationSection = "SSG_Menu_Victory";

	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'SSG_PlayerController', currentController)
	{
		if(LocalPlayer(currentController.Player).ControllerId == controllerID)
		{
			PlayerName = currentController.ThiefName;
		}
	}

	Title = VictoryScreen.GetVariableObject("_root.mc_player_"$controllerID+1$"_score.mc_ready_frame.text_player_ready");
	TitleString = class'Text_Localizer'.static.GetLocalizedStringWithName(LocalizationSection, "victoryLabelIsReady");
	Title.SetText(PlayerName@TitleString);
}



//++++++++++++++++++++++++++++++++++++++++++++ Console Commands ++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
exec function BotDebugLevel(int VerbosityLevel)
{
	BotDebugVerbosity = VerbosityLevel;
}

//----------------------------------------------------------------------------------------------------------
exec function ShowCornerHUD( bool ShowHUD )
{
	InGameHUD.bShowCornerHUD = ShowHUD;
}

//----------------------------------------------------------------------------------------------------------
exec function ShowEdgeHUD( bool ShowHUD )
{
	InGameHUD.bShowEdgeHUD = ShowHUD;
}

//----------------------------------------------------------------------------------------------------------
exec function ShowRingHUD( bool ShowHUD )
{
	InGameHUD.bShowRingHUD = ShowHUD;
}

//----------------------------------------------------------------------------------------------------------
exec function TestLoadingTextNumber( int TextNumber )
{
	if( LoadingScreen != None )
	{
		LoadingScreen.SetLoadingText( TextNumber );
	}
	else
	{
		`log( "CRAP" );
	}
}




//+++++++++++++++++++++++++++++++++++++++++++ Default Properties +++++++++++++++++++++++++++++++++++++++++//
DefaultProperties
{
	BotDebugVerbosity = 0
	ShouldShowGameOverMessage = false //Do not change
	LastLevelName="SSG-RTM3_Persistent"
}
