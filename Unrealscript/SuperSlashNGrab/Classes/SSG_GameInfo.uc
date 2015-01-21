class SSG_GameInfo extends UDKGame
	dependson(SSG_DamageType);

//----------------------------------------------------------------------------------------------------------
var SSG_Camera_SharedMulti GameCamera;
var Actor EndGameCameraFocus;
var bool bCameraLockedOnPlayers;
var bool bSpawnPlayersAtStart;

var class<SSG_Bot> BotClass;
var class<SSG_LocalMessage> GameplayMessageClass;

var SSG_POI_TeamExit ExitForTeam;
var SSG_POI_PlayerStart LastCheckpointStart;
var array< SSG_POI_SectionExit > SectionTransitionZones;
var int TransitionTimeLeftSeconds;
var int PlayersFinished;
var int SecondsUntilLevelEnd;

var int InitialSecondsUntilSuddenDeath;
var int SecondsLeftUntilSuddenDeath;
var SoundCue SuddenDeathBeginsCue;
var bool InSuddenDeath;
var bool bInitialSpawn;
var bool bCalledGameOver;
var SSG_POI_CameraFocusPoint CameraFoci[ 2 ];
var int CurrentCameraFocusID;
var int CurrentSection;
var int NumPlayersExpected;

var SSG_HUD_Base TeamHUD;
var Pawn CurrentPlayerToRespawnOn;
var Actor CurrentObjective;
var Vector LastPlayerDeathLocation;

var float RespawnTime;

struct SuperlativeNode 
{
	var SSG_PlayerController id; 
	var int amt; 
	var string localization;
	structdefaultproperties
	{
		id=none
		amt=0
		localization="VictorySuperlativesCheater"
	}
};
enum SuperlativeEnum
{
	ESUP_MostKills, ESUP_FewestKills, ESUP_MostDeaths, ESUP_FewestDeaths, ESUP_MostGold, ESUP_LeastGold, 
	ESUP_DiedWater, ESUP_DiedFire, ESUP_DiedIce, ESUP_DiedGuard, ESUP_DiedCannon, ESUP_DiedOffscreen, ESUP_DiedExplosion,
	ESUP_MostBetrayals
};

var string LevelNames[4];

var bool bShowLostArrow;

var bool bIsFullyLoaded;

//----------------------------------------------------------------------------------------------------------
event Tick ( float DeltaTime )
{
	local Vector NextCameraFocus;
	NextCameraFocus = GameCamera.CalculateCentroidOfAttachedPlayers();

	// if( !bInitialSpawn && !bCalledGameOver && AllPlayersAreDead() )
	// {
	// 	EndGame( None, "PlayersDied" );
	// 	bCalledGameOver=true;
	// }

	if( bCameraLockedOnPlayers )
	{
		//Don't interpolate to origin; this generally indicates that there are no players.
		if( NextCameraFocus == vect( 0, 0, 0 ) )
			return;

		if( VSize( NextCameraFocus - CameraFoci[ CurrentCameraFocusID ].Location ) > 100.0 )
		{
			if( GameCamera.PendingViewTarget.Target != None )
				CameraFoci[ CurrentCameraFocusID ].SetLocation( NextCameraFocus );
			else
			{
				CurrentCameraFocusID = ( CurrentCameraFocusID + 1 ) % 2;
				CameraFoci[ CurrentCameraFocusID ].SetLocation( NextCameraFocus );
				GameCamera.SetViewTarget( CameraFoci[ CurrentCameraFocusID ], GameCamera.SectionTransitionParams );
			}
		}
		else
		{
			CameraFoci[ CurrentCameraFocusID ].SetLocation( NextCameraFocus );
			GameCamera.SetViewTarget( CameraFoci[ CurrentCameraFocusID ] );
		}
	}
}

//----------------------------------------------------------------------------------------------------------
event Timer()
{
	//local int i;
	//local Sequence GameSeq;
	//local array<SequenceObject> AllSeqEvents;

	Super.Timer();
	
	if( MatchIsInProgress() )
	{
		UpdateAndKillOffscreenPlayers();
		//UpdateLostArrow();

		if( PlayerTeamHasExitedLevel() )
		{
			EndGame( None, "PlayersEscapedWithTreasure" );
			SetEndGameCameraFocusOn( ExitForTeam );
		}

		if( PlayersFinished > 0 )
		{
			--SecondsUntilLevelEnd;
			if(TeamHUD.InGameHUD != none)
			{
				TeamHUD.InGameHUD.UpdateTimer( SecondsUntilLevelEnd );
			}
			if( SecondsUntilLevelEnd == 0 )
			{
				EndGame( None, "PlayersEscapedWithTreasure" );
				SetEndGameCameraFocusOn( ExitForTeam );
			}
		}

		// ---------------------------------------- Old Enrage Timer Code ----------------------------------
		// if( SecondsLeftUntilSuddenDeath > 0 )
		// 	--SecondsLeftUntilSuddenDeath;
		// if( SecondsLeftUntilSuddenDeath == 0 && !InSuddenDeath ) //We can't elseif here or we will lose a second before the sound plays
		// {
		// 	PlaySound( SuddenDeathBeginsCue );
		// 	InSuddenDeath = true;

		// 	GameSeq = WorldInfo.GetGameSequence();
		// 	if (GameSeq != None)
		// 	{
		// 		GameSeq.FindSeqObjectsByClass(class'SSG_SeqEvent_SuddenDeathBegins', true, AllSeqEvents);
		// 		for (i = 0; i < AllSeqEvents.Length; i++)
		// 		{
		// 			if(SSG_SeqEvent_SuddenDeathBegins(AllSeqEvents[i]).Section == CurrentSection)
		// 			{
		// 				SSG_SeqEvent_SuddenDeathBegins(AllSeqEvents[i]).CheckActivate(WorldInfo, self, false);
		// 			}
		// 		}
		// 	}
		// }


		// ---------------------------------------- Old Transition Code ----------------------------------
		// if( TransitionTimeLeftSeconds > 0 )
		// {
		// 	--TransitionTimeLeftSeconds;
		// }

		// //Disable player inputs early to insure they can't do stuff like dropping an item right before a transition
		// DisablePlayerInputs();


		// for( i = 0; i < SectionTransitionZones.length; ++i )
		// {
		// 	SectionTransitionZones[ i ].ResetColor();
		// 	if( SectionTransitionZones[ i ].IsEnabled && PlayerTeamIsInSectionExit( i ) )
		// 	{
		// 		DoSectionTransition(i);
		// 	}
				
		// }

		// //Only enable the player inputs if we are out of the transition.
		// if( TransitionTimeLeftSeconds == 0 )
		// {
		// 	EnablePlayerInputs();
		// }
	}
}

//----------------------------------------------------------------------------------------------------------
function DelayedLost()
{
	/*local SSG_PlayerController CurrentPC;
	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentPC)
	{
		CurrentPC.bIsLost = true;
	}*/
}

//----------------------------------------------------------------------------------------------------------
function RemoveLost()
{
	/*local SSG_PlayerController CurrentPC;
	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentPC)
	{
		CurrentPC.bIsLost = false;
	}*/
}

//----------------------------------------------------------------------------------------------------------
exec function ToggleLostArrow()
{
	//bShowLostArrow = !bShowLostArrow;
}

//----------------------------------------------------------------------------------------------------------
//DEPRECATED
function UpdateLostArrow()
{
	local SSG_PlayerController CurrentController;
	local SSG_HUD_Base HUDasSSGHUD;
	local Vector CompositeDirection;
	local Rotator CompositeRotation;
	local float OrientationOfArrowDegrees;
	local bool ShouldPlay;

	ShouldPlay = false;
	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentController)
	{
		if(CurrentController.bIsLost && CurrentController.Pawn != none)
		{
			ShouldPlay = true && bShowLostArrow;
			CompositeDirection += CurrentController.ToNextRoom;
		}
	}

	
	if(ShouldPlay)
	{
		//calculate the composite orientation
		//CompositeDirection = normal(CompositeDirection);
		CompositeRotation = Rotator(CompositeDirection);
		OrientationOfArrowDegrees = CompositeRotation.Yaw*UnrRotToDeg;
	}

	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentController)
	{
		HUDasSSGHUD = SSG_HUD_Base(CurrentController.myHUD);
		if(HUDasSSGHUD != none)
		{
			if(ShouldPlay)
			{
				HUDasSSGHUD.InGameHUD.NavigationArrow.Show(OrientationOfArrowDegrees);
				//HUDasSSGHUD.InGameHUD.NavigationArrow.Play(OrientationOfArrowDegrees);
			}
			else
			{
				HUDasSSGHUD.InGameHUD.NavigationArrow.Hide();
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function DoSectionTransition(int i)
{
	local int j;
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local SSG_Pawn_Bot CurrentBot;

	SectionTransitionZones[ i ].SetColor( 1.0, 1.0, 1.0 );
	SectionTransitionZones[ i ].IsEnabled = false;

	InSuddenDeath=false;
	SecondsLeftUntilSuddenDeath += SectionTransitionZones[ i ].SecondsAddedToTimerOnTransition;
	DisplayTimePopupOnHUD( SectionTransitionZones[ i ].SecondsAddedToTimerOnTransition );

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		GameSeq.FindSeqObjectsByClass(class'SSG_SeqEvent_SuddenDeathEnds', true, AllSeqEvents);
		for (j = 0; j < AllSeqEvents.Length; j++)
		{
			SSG_SeqEvent_SuddenDeathEnds(AllSeqEvents[j]).CheckActivate(WorldInfo, self, false);
		}
	}

	CurrentSection = SectionTransitionZones[i].NextLevelSectionID;

	foreach WorldInfo.AllPawns(class'SSG_Pawn_Bot', CurrentBot)
	{
		if(CurrentBot.SectionNumber != -1 && CurrentBot.SectionNumber < CurrentSection)
		{
			CurrentBot.Controller.GotoState('DoNothing');
			CurrentBot.Destroy();
		}
		else if(CurrentBot.SectionNumber == CurrentSection)
		{
			if(SSG_Bot(CurrentBot.Controller).GetStateName() == 'DoNothing')
			{
				CurrentBot.Controller.PopState();
			}
		}
	}


	
	TransitionBetweenSections( i );
	
}

//----------------------------------------------------------------------------------------------------------
function UpdateAndKillOffscreenPlayers()
{
	local SSG_PlayerController PC;
	local Pawn PlayerPawn;

	if( !bCameraLockedOnPlayers )
		return;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		PlayerPawn = PC.Pawn;
		if( !PC.bIsOffScreen )
			PC.SecondsLeftBeforeKilled = PC.MAX_SECONDS_OFFSCREEN_BEFORE_KILLED;
		else
		{
			if( PC.SecondsLeftBeforeKilled > PC.MAX_SECONDS_OFFSCREEN_BEFORE_KILLED )
				PC.SecondsLeftBeforeKilled = PC.MAX_SECONDS_OFFSCREEN_BEFORE_KILLED;

			--PC.SecondsLeftBeforeKilled;
			
			if( PC.SecondsLeftBeforeKilled <= 0 )
			{
				PlayerPawn.TakeDamage( 4, None, PlayerPawn.Location, vect( 0, 0, 0 ), class'SSG_DmgType_Offscreen' );
			}
		}
	}
}



//++++++++++++++++++++++++++++++++++++++++++++++ Lifecycle +++++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
event InitGame( string Options, out string ErrorMessage )
{
	super.InitGame( Options, ErrorMessage );

	GameCamera = Spawn( class'SSG_Camera_SharedMulti' );
}

//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	local SSG_POI_PlayerStart PlayerSpawn;

	Super.PostBeginPlay();

	SecondsLeftUntilSuddenDeath = InitialSecondsUntilSuddenDeath;

	CameraFoci[0] = Spawn( class'SSG_POI_CameraFocusPoint' );
	CameraFoci[1] = Spawn( class'SSG_POI_CameraFocusPoint' );

	foreach WorldInfo.AllActors( class'SSG_POI_PlayerStart', PlayerSpawn )
	{
		if( PlayerSpawn.Name == 'SSG_POI_PlayerStart_0' )
		{
			LastCheckpointStart = PlayerSpawn;
			LastPlayerDeathLocation = PlayerSpawn.Location;
			break;
		}
	}

	SetTimer(1.0, false, 'GeneratePlayersFromSave');
}

//----------------------------------------------------------------------------------------------------------
function SetPlayerDefaults(Pawn PlayerPawn)
{
	Super.SetPlayerDefaults( PlayerPawn );

	if( PlayerPawn.IsA( 'SSG_Pawn' ) )
	{
		SSG_Pawn( PlayerPawn ).UpdateAccelRate( class'SSG_IcePhysicsVolume'.default.PlayerAccelRate );
	}
}

//----------------------------------------------------------------------------------------------------------
function StartOnlineGame()
{
}

//----------------------------------------------------------------------------------------------------------
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
	UpdateHighScore();
	super.EndGame( Winner, Reason );

	if( bGameEnded )
	{
		if( Reason == "PlayersDied" )
			NotifyPlayersThatGameHasEnded( false );
		else if( Reason == "PlayersEscapedWithTreasure" )
			NotifyPlayersThatGameHasEnded( true );
		GotoState( 'MatchEnded' );
	}
}

//----------------------------------------------------------------------------------------------------------
function EndOnlineGame()
{
}

//----------------------------------------------------------------------------------------------------------
function ResetLevel()
{
	super.Reset();
}


//++++++++++++++++++++++++++++++++++++++++++++ Load and Save ++++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
exec function LoadAllProfiles()
{
	local SSG_PlayerController CurrentPlayer;
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local SSG_Save_SessionObject CurrentSession;
	local int CurrentPlayerIndex;

	CurrentSession = new class'SSG_Save_SessionObject';
	CurrentSession.LoadFromDisk();

	foreach WorldInfo.AllControllers(class'SSG_PlayerController', CurrentPlayer)
	{
		CurrentPlayerAsLocalPlayer = LocalPlayer(CurrentPlayer.Player);
		if (CurrentPlayerAsLocalPlayer != none)
		{
			CurrentPlayerIndex = CurrentPlayerAsLocalPlayer.ControllerId;
			CurrentPlayer.ThiefName = CurrentSession.PlayerNames[CurrentPlayerIndex];
		}
	}
}

//----------------------------------------------------------------------------------------------------------
exec function GeneratePlayersFromSave()
{
	local SSG_PlayerController CurrentPlayer, NewPlayer;
	local LocalPlayer CurrentPlayerAsLocalPlayer;
	local SSG_Save_SessionObject CurrentSession;
	local SSG_PlayerController PlayerArray[4];
	local int CurrentPlayerIndex;

	CurrentSession = new class'SSG_Save_SessionObject';
	CurrentSession.LoadFromDisk();

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', CurrentPlayer )
	{
		CurrentPlayerAsLocalPlayer = LocalPlayer(CurrentPlayer.Player);
		PlayerArray[CurrentPlayerAsLocalPlayer.ControllerId] = CurrentPlayer;
	}
	
	for( CurrentPlayerIndex = 0; CurrentPlayerIndex < 4; ++CurrentPlayerIndex )
	{
		if(CurrentSession.PlayerNames[CurrentPlayerIndex] != "none")
		{
			if( PlayerArray[CurrentPlayerIndex] == none )
			{
				PlayerArray[0].ConsoleCommand( "DebugCreatePlayer"@CurrentPlayerIndex, true );
			}
			foreach WorldInfo.AllControllers( class'SSG_PlayerController', NewPlayer )
			{
				CurrentPlayerAsLocalPlayer = LocalPlayer( NewPlayer.Player );
				if(CurrentPlayerAsLocalPlayer.ControllerId == CurrentPlayerIndex)
				{
					NewPlayer.ThiefName = CurrentSession.PlayerNames[CurrentPlayerIndex];
				}
			}
		}
	}

	foreach WorldInfo.AllControllers( class'SSG_PlayerController', NewPlayer )
	{
		++NumPlayersExpected;
	}

	if( NumPlayersExpected == 0 )
		NumPlayersExpected = 1;
}

//----------------------------------------------------------------------------------------------------------
exec function UpdateHighScore()
{
	local string GameNameTemp;
	local int i;
	local bool HasHighScore;
	local SSG_Save_HighScore HighScoreFile;
	local SSG_Save_SessionObject CurrentSession;
	local SSG_PlayerController currentController, Winner;
	local int highestGold;

	HighScoreFile = new class'SSG_Save_HighScore';
	HighScoreFile.LoadFromDisk();
	GameNameTemp = WorldInfo.GetMapName(false);
	HasHighScore = false;
	for(i = 0; i < 4 && !HasHighScore; i++)
	{
		if(GameNameTemp ~= LevelNames[i])
		{
			HasHighScore = true;
			i--;
		}
	}
	
	if(HasHighScore)
	{
		CurrentSession = new class'SSG_Save_SessionObject';
		CurrentSession.LoadFromDisk();
		CurrentSession.NextLevel = i == 3 ? i : i+1;
		CurrentSession.SaveToDisk();

		highestGold = 0;
		foreach WorldInfo.AllControllers(class'SSG_PlayerController', currentController)
		{
			if(currentController.MoneyEarned > currentController.Highscores[i])
			{
				currentController.Highscores[i] = currentController.MoneyEarned;  //@TODO NEW HIGH SCORE!
			}
			if(currentController.MoneyEarned > highestGold)
			{
				highestGold = currentController.MoneyEarned;
				Winner = currentController;
			}
		}

		if(highestGold > HighScoreFile.LevelScore[i])
		{
			HighScoreFile.LevelScore[i] = highestGold;
			HighScoreFile.LevelWinner[i] = Winner.ThiefName;
		}
		HighScoreFile.InsertScoreIntoList(Winner, i);   //@TODO remove the top two lines when the highscore in the menus has been revised, and insert all of the players in to the 
														//highscore in order, rather than just the winning player
		
	}
	else
	{
		`log(GameNameTemp@"is not a valid map for highscore");
	}

	HighScoreFile.SaveToDisk();
}

//+++++++++++++++++++++++++++++++++++++++++++++ Game States ++++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
auto State PendingMatch
{
	event BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
	}

	function StartMatch()
	{
		Super.StartMatch();
		GoToState( 'MatchInProgress' );
	}

	event EndState( name NextStateName )
	{
		Super.EndState( NextStateName );
	}
}

//----------------------------------------------------------------------------------------------------------
state MatchInProgress
{
	function bool MatchIsInProgress()
	{
		return true;
	}

	event BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
	}

	event EndState( name NextStateName )
	{
		Super.EndState( NextStateName );
	}
}

//----------------------------------------------------------------------------------------------------------
state MatchEnded
{
	function bool MatchIsInProgress()
	{
		return false;
	}

	event BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );
	}

	event EndState( name NextStateName )
	{
		Super.EndState( NextStateName );
	}
}



//++++++++++++++++++++++++++++++++++++++++++++++++ Bots ++++++++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function SSG_Bot AddBot(optional string BotName)
{
	local SSG_Bot NewBot;
	local CharacterInfo BotInfo;


	//BotInfo = GetBotInfo(botName);

	NewBot = Spawn(BotClass);

	if ( NewBot != None )
	{
		InitializeBot(NewBot, BotInfo);

		if (BaseMutator != None)
		{
			BaseMutator.NotifyLogin(NewBot);
		}
	}
	if ( NewBot == None )
	{
		`warn("Failed to spawn bot.");
		return none;
	}
	//NewBot.PlayerReplicationInfo.PlayerID = GetNextPlayerID(); //TODO PlayerReplicationInfo is coming back as None
	NumBots++;
	if ( WorldInfo.NetMode == NM_Standalone )
	{
		RestartPlayer(NewBot);
	}
	else
	{
		NewBot.GotoState('Dead','MPStart');
	}
	return NewBot;
}

//----------------------------------------------------------------------------------------------------------
exec function AddBots(int Num)
{
	local int AddCount;
	AddCount = 0;
	while(AddCount < Num)
	{
		AddBot();
		AddCount++;
	}
}

//----------------------------------------------------------------------------------------------------------
exec function StopBots()
{
	local SSG_Bot BotController;

	foreach WorldInfo.AllActors(class'SSG_Bot', BotController)
	{
		if(BotController.GetStateName() == 'DoNothing')
		{
			BotController.PopState();
		}
		else
		{
			BotController.PushState('DoNothing');
		}
	}
}

//----------------------------------------------------------------------------------------------------------
exec function BlindBots(optional bool CanSee)
{
	local SSG_Bot BotController;

	foreach WorldInfo.AllActors(class'SSG_Bot', BotController)
	{
		BotController.DebugCaresAboutHumans = CanSee;
	}
}

//----------------------------------------------------------------------------------------------------------
function InitializeBot(SSG_Bot NewBot,  const out CharacterInfo BotInfo)
{
	local int AdjustedDifficulty;
	AdjustedDifficulty = 0;
	NewBot.Initialize(AdjustedDifficulty, BotInfo);
	ChangeName(NewBot, BotInfo.CharName, false);
}



//++++++++++++++++++++++++++++++++++++++++++ End Game Checking +++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	//`log(Winner$" CheckEndGame "$Reason);
	//TODO check to see if they have exited the level, or check to see if we've run out of lives
	if( PlayerTeamHasExitedLevel() )
		return true;
	else if( AllPlayersAreDead() )
		return true;
	else
	{
		return super.CheckEndGame(Winner, Reason);
	}
}

//----------------------------------------------------------------------------------------------------------
function bool PlayerTeamHasExitedLevel()
{
	local SSG_PlayerController Player;
	local int PlayersAtExit;
	local bool TeamHasExited;
	TeamHasExited = true;

	PlayersAtExit = 0;
	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', Player )
	{
		if( Player.Pawn == None )
			continue; //If a player is dead, we might allow players to move on without them?

		if( !ExitForTeam.PawnIsInRadius( Player.Pawn ) )
		{
			TeamHasExited = false;
			continue;
		}

		++PlayersAtExit;
		if( Player.ExitedInPosition == 0 )
		{
			if( PlayersFinished == 0 )
			{
				SSG_PlayerController( TeamHUD.PlayerOwner ).Announcer.PlayAnnouncement( GameplayMessageClass, 0 );
				SSG_PlayerController( TeamHUD.PlayerOwner ).ReceiveLocalizedMessage( GameplayMessageClass, 0 );
			}

			++PlayersFinished;
			Player.ExitedInPosition = PlayersFinished;
		}
	}

	if( PlayersAtExit == 0 ) //If we have no players at the exit, we can't move on no matter what.
		return false;

	return TeamHasExited;
}

//----------------------------------------------------------------------------------------------------------
function bool PlayerTeamIsInSectionExit( int SectionExitID )
{
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local int i;
	local SSG_PlayerController Player;
	local int PlayersAtExit;
	local bool TeamIsInExit;
	local bool TeamHasObjective;

	TeamIsInExit = true;
	PlayersAtExit = 0;
	SectionTransitionZones[ SectionExitID ].ResetColor();
	TeamHasObjective = !SectionTransitionZones[ SectionExitID ].NeedsObjectiveToTransition;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', Player )
	{
		if( Player.Pawn == None )
			continue; //If a player is dead, we might allow players to move on without them?

		if( Player.Pawn.InvManager.FindInventoryType( class'SSG_Inventory_Objective', true ) != None )
		{
			TeamHasObjective = true;
		}

		if( !SectionTransitionZones[ SectionExitID ].PawnIsInRadius( Player.Pawn ) )
		{
			TeamIsInExit = false;
			if(Player.InSectionTransitionNumber == SectionExitID)
			{
				GameSeq = WorldInfo.GetGameSequence();
				if (GameSeq != None)
				{
					GameSeq.FindSeqObjectsByClass(class'SSG_SeqEvent_PlayerLeavesTransition', true, AllSeqEvents);
					for (i = 0; i < AllSeqEvents.Length; i++)
					{
						if(SSG_SeqEvent_PlayerLeavesTransition(AllSeqEvents[i]).Section == SectionExitID)
						{
							SSG_SeqEvent_PlayerLeavesTransition(AllSeqEvents[i]).CheckActivate(Player, Player, false);
						}
					}
				}
				Player.InSectionTransitionNumber = -1;
			}
		}
		else
		{
			++PlayersAtExit;
			SectionTransitionZones[ SectionExitID ].AddColor( class'SSG_PlayerController'.default.PlayerColors[ LocalPlayer( Player.Player ).ControllerID ] );
			if(Player.InSectionTransitionNumber != SectionExitID)
			{
				GameSeq = WorldInfo.GetGameSequence();
				if (GameSeq != None)
				{
					GameSeq.FindSeqObjectsByClass(class'SSG_SeqEvent_PlayerEntersTransition', true, AllSeqEvents);
					for (i = 0; i < AllSeqEvents.Length; i++)
					{
						if(SSG_SeqEvent_PlayerEntersTransition(AllSeqEvents[i]).Section == SectionExitID)
						{
							SSG_SeqEvent_PlayerEntersTransition(AllSeqEvents[i]).CheckActivate(Player, Player, false);
						}
					}
				}
				Player.InSectionTransitionNumber = SectionExitID;
			}
		}
	}

	if( PlayersAtExit == 0 ) //If we have no players at the exit, we can't move on no matter what.
		return false;

	if( !TeamHasObjective ) // One player must have objective to advance
		return false;

	return TeamIsInExit;
}



//+++++++++++++++++++++++++++++++++++++++++ Object Registration ++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function OverrideDefaultsWithLevelSettings( SSG_LevelSettings LevelSettings )
{
	InitialSecondsUntilSuddenDeath = LevelSettings.InitialSecondsUntilSuddenDeath;
	CurrentSection = LevelSettings.DebugStartSection;
	bSpawnPlayersAtStart = LevelSettings.bSpawnPlayersAtStart;
}

//----------------------------------------------------------------------------------------------------------
function RegisterCameraFocusPoint( SSG_POI_CameraFocusPoint FocusPoint )
{
	GameCamera.RegisterFocusPoint( FocusPoint );
}

//----------------------------------------------------------------------------------------------------------
function RegisterObjective( Actor NewObjective )
{
	CurrentObjective = NewObjective;
}

//----------------------------------------------------------------------------------------------------------
function RegisterSectionExit( SSG_POI_SectionExit SectionExit )
{
	SectionTransitionZones.AddItem( SectionExit );
}

//----------------------------------------------------------------------------------------------------------
function RegisterTeamExit( SSG_POI_TeamExit TeamExit )
{
	ExitForTeam = TeamExit;
}


//----------------------------------------------------------------------------------------------------------
function RegisterLastCheckpoint( SSG_POI_PlayerStart CheckpointStart )
{
	LastCheckpointStart = CheckpointStart;
}



//++++++++++++++++++++++++++++++++++++++++++ Section Transitions +++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function Vector CalculateCentroidOfSpawnsInSection( int SectionID )
{
	local Vector CentroidOfSpawns;
	local int NumberOfSpawnsInSection;
	local SSG_POI_PlayerStart CurrentPlayerStart;

	CentroidOfSpawns = vect( 0, 0, 0 );

	NumberOfSpawnsInSection = 0;
	foreach WorldInfo.AllNavigationPoints( class'SSG_POI_PlayerStart', CurrentPlayerStart )
	{
		if( CurrentPlayerStart.LevelSectionID == SectionID )
		{
			CentroidOfSpawns += CurrentPlayerStart.Location;
			++NumberOfSpawnsInSection;
		}
	}

	if( NumberOfSpawnsInSection == 0 )
	{
		`warn( "No player spawns found for section ID" @ SectionID );
		return vect( 0, 0, 0 );
	}

	CentroidOfSpawns /= NumberOfSpawnsInSection;
	return CentroidOfSpawns;
}

//----------------------------------------------------------------------------------------------------------
function DisablePlayerInputs()
{
	local SSG_PlayerController Player;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', Player )
	{
			Player.bCinematicMode = true;
			Player.IgnoreMoveInput( true );
			Player.IgnoreLookInput( true );
	}
}

//----------------------------------------------------------------------------------------------------------
function DisplayTimePopupOnHUD( int timeChangeSeconds )
{
	local SSG_PlayerController PC;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		if( LocalPlayer( PC.Player ).ControllerID == 0 )
			SSG_HUD_Base( PC.myHUD ).PopupTimeChange( timeChangeSeconds );
	}
}

//----------------------------------------------------------------------------------------------------------
function EnablePlayerInputs()
{
	local SSG_PlayerController Player;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', Player )
	{
			Player.bCinematicMode = false;
			Player.ResetPlayerMovementInput();
	}
}

//----------------------------------------------------------------------------------------------------------
function TransitionBetweenSections( int CurrentSectionID )
{
	local SSG_PlayerController Player;
	local SSG_POI_SectionExit SectionExit;

	local Vector TransitionStartLocation;
	local Vector TransitionEndLocation;
	local Vector DirectionFromStartToEnd;
	//local float DistanceFromStartToEnd;

	SectionExit = SectionTransitionZones[ CurrentSectionID ];
	TransitionTimeLeftSeconds = SectionExit.SecondsTakenToTransition;
	TransitionStartLocation = SectionExit.Location;
	TransitionEndLocation = CalculateCentroidOfSpawnsInSection( SectionExit.NextLevelSectionID );

	DirectionFromStartToEnd = TransitionEndLocation - TransitionStartLocation;
	//DistanceFromStartToEnd = VSize( DirectionFromStartToEnd );
	Normal( DirectionFromStartToEnd );

	GameCamera.SetTransitionTimeSeconds( TransitionTimeLeftSeconds );
	//GameCamera.SetCameraFocusPoint( SectionExit.NextLevelSectionID );
	SectionExit.TriggerTransitionEvent();

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', Player )
	{
		//Player.TransitionMovementVector = DirectionFromStartToEnd;
		//Player.SecondsLeftInMovementTransition = 1.0;
	}
}



//+++++++++++++++++++++++++++++++++++++++++++++ Miscellaneous ++++++++++++++++++++++++++++++++++++++++++++//
//----------------------------------------------------------------------------------------------------------
function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
	if( CurrentPlayerToRespawnOn == KilledPawn )
		CurrentPlayerToRespawnOn = None;

	if( KilledPlayer.IsA( 'PlayerController' ) )
	{
		LastPlayerDeathLocation = KilledPawn.Location;
	}

	super.Killed(Killer, KilledPlayer, KilledPawn, damageType);
}

//----------------------------------------------------------------------------------------------------------
function NotifyPlayersThatGameHasEnded( bool PlayersWon )
{
	local Controller controller;

	foreach WorldInfo.AllControllers(class'Controller', controller)
	{
		controller.GameHasEnded( EndGameCameraFocus, PlayersWon );
	}
}

//----------------------------------------------------------------------------------------------------------
function float RatePlayerStart(PlayerStart P, byte Team, Controller Player)
{
	local float Score;
	local Controller OtherPlayer;
	local SSG_PlayerController PlayerAsPController;
	local SSG_POI_PlayerStart PStartAsSSG;
	local LocalPlayer PlayerAsLocalPlayer;
	local int PlayerControllerIndex;

	Score = -10; // arbitrary number

	PStartAsSSG = SSG_POI_PlayerStart(P);
	if(PStartAsSSG != none)
	{
		PlayerAsPController = SSG_PlayerController(Player);
		if(PlayerAsPController != none)
		{
			PlayerAsLocalPlayer = LocalPlayer(PlayerAsPController.Player);
			if(PlayerAsLocalPlayer != none)
			{
				PlayerControllerIndex = PlayerAsLocalPlayer.ControllerId;
			}
			else
			{
				PlayerControllerIndex = PlayerAsPController.HackedPlayerNum;
			}

			if(PlayerControllerIndex == PStartAsSSG.PlayerNum)
			{
				Score = 1000; //the "correct" spawn location
			}
			
		}
	}
	else
	{
		Score = -100; //undesirable, and should never happen
	}

	ForEach WorldInfo.AllControllers(class'Controller', OtherPlayer)
	{
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Pawn != None) )
		{
			// check if playerstart overlaps this pawn
			if ( (Abs(P.Location.Z - OtherPlayer.Pawn.Location.Z) < P.CylinderComponent.CollisionHeight + OtherPlayer.Pawn.CylinderComponent.CollisionHeight)
				&& (VSize2D(P.Location - OtherPlayer.Pawn.Location) < P.CylinderComponent.CollisionRadius + OtherPlayer.Pawn.CylinderComponent.CollisionRadius) )
			{
				// overlapping causes issues, so avoid at all cost
				return -1000;
			}
		}
	}

	return Score;
}

//----------------------------------------------------------------------------------------------------------
event PlayerController Login(string Portal, string Options, const UniqueNetID UniqueID, out string ErrorMessage)
{
	local PlayerController NewPlayer;
	
	NewPlayer = super.Login(Portal, Options, UniqueID, ErrorMessage);
	NewPlayer.StartSpot = FindPlayerStart(NewPlayer);
	SSG_PlayerController(NewPlayer).NextSpawnSpot = NewPlayer.StartSpot.Location;

	return NewPlayer;
}

//----------------------------------------------------------------------------------------------------------
event PostLogin( PlayerController NewPlayer )
{
	local SSG_PlayerController PC;

	Super.PostLogin( NewPlayer );

	PC = SSG_PlayerController( NewPlayer );
	if( PC == None )
		return;

	if( PC.RespawnSelectionEffect == none)
	{
		PC.RespawnSelectionEffect = Spawn( class'SSG_Respawn_Mesh' );
		PC.RespawnSelectionEffect.SelectorMesh.SetStaticMesh( PC.RespawnSelectionEffect.StaticMeshArray[LocalPlayer(PC.Player).ControllerId] );
		PC.RespawnSelectionEffect.SelectorMesh.SetMaterial( 0, PC.RespawnSelectionEffect.MaterialArray[LocalPlayer(PC.Player).ControllerId] );
		PC.RespawnSelectionEffect.SetOwner( PC );
		PC.RespawnSelectionEffect.SetHidden( true );
	}
}

//----------------------------------------------------------------------------------------------------------
function bool AllPlayersAreDead()
{
	local PlayerController PC;
	local bool NoPlayersAlive;

	NoPlayersAlive = true;
	ForEach WorldInfo.AllControllers( class'PlayerController', PC )
	{
		if( PC.Pawn != None )
		{
			NoPlayersAlive = false;
			break;
		}
	}
	return NoPlayersAlive;
}

//----------------------------------------------------------------------------------------------------------
function Pawn FindLivingPlayerPawn()
{
	local PlayerController OtherPlayer;

	if( CurrentPlayerToRespawnOn != None )
		return CurrentPlayerToRespawnOn;

	ForEach WorldInfo.AllControllers( class'PlayerController', OtherPlayer )
	{
		if( OtherPlayer.Pawn != None )
		{
			CurrentPlayerToRespawnOn = OtherPlayer.Pawn;
			return OtherPlayer.Pawn;
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function StartHumans()
{
	local SSG_PlayerController PC;

	Super.StartHumans();

	if( !bSpawnPlayersAtStart )
	{
		foreach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
		{
			PC.IncrementPlayerToSpawn();
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function RestartPlayer(Controller NewPlayer)
{
	//local Pawn PawnToSpawnOn;
	local LocalPlayer LP;
	local SSG_PlayerController SSG_PC;
	local SSG_POI_PlayerStart InitPlayerStart;
	local Vector NextCameraFocus;
	local bool PendingPlayerSpawn;
	//local float ClosestSpawnDistance;
	//local SSG_POI_PlayerStart ClosestSpawnZone;
	//local SSG_POI_PlayerStart PlayerSpawnZone;

	//ClosestSpawnDistance = 5000000;
	if( SecondsLeftUntilSuddenDeath <= 0 )
		return;

	SSG_PC = SSG_PlayerController( NewPlayer );

	if(SSG_PC.WaitingOnRespawn)
	{
		return;
	}

	PendingPlayerSpawn = false;

	if ( NewPlayer.IsA('SSG_PlayerController') && ( !SSG_PC.bSpawningForFirstTime || !bSpawnPlayersAtStart ) )
	{
		//This is a derivative of GameInfo's RestartPlayer, except spawning on pawns instead of start points.
		if (NewPlayer.Pawn == None)
		{

			
			//LP = LocalPlayer(SSG_PC.Player);
			SSG_PC.SelectPlayerToSpawn(SSG_PC.NextSpawnPlayerNum);
			//PawnToSpawnOn = FindLivingPlayerPawn();
			if( SSG_PC.NextSpawnSpot == Vect( 0, 0, 0 ) )
			{
				if( LastCheckpointStart == None )
				{
					`warn( "Unable to find Player Start on which to spawn!" );
					return;
				}

				SSG_PC.NextSpawnSpot = LastCheckpointStart.Location;
			}

			if( !SSG_PC.bSpawningForFirstTime )
			{
				if( SSG_PC.LivesLived <= 0 )
				{
					foreach WorldInfo.AllActors( class'SSG_POI_PlayerStart', InitPlayerStart )
					{
						if( InitPlayerStart.PlayerNum == LocalPlayer( SSG_PC.Player ).ControllerId && InitPlayerStart.Location == SSG_PC.NextSpawnSpot )
						{
							SSG_PC.WaitingOnRespawn = true;
							SSG_PC.CreateSpawnEffects();

							--NumPlayersExpected;
							if( NumPlayersExpected == 0 )
								ActivateAllPlayersSpawnedEvent();
						}
					}
				}
				else
				{
					SSG_PC.WaitingOnRespawn = true;
					SSG_PC.CreateSpawnEffects();
				}
			}

			SSG_PC.bSpawningForFirstTime = false;
			PendingPlayerSpawn = true;
		}

		if (NewPlayer.Pawn == None && !PendingPlayerSpawn) //if we're delaying the spawn, there won't be a pawn yet; don't panic
		{
			`log("failed to spawn player on a pawn");
			NewPlayer.GotoState('Dead');
			if ( PlayerController(NewPlayer) != None )
			{
				PlayerController(NewPlayer).ClientGotoState('Dead','Begin');
			}
		}

		// To fix custom post processing chain when not running in editor or PIE.
		SSG_PC = SSG_PlayerController(NewPlayer);
		if (SSG_PC != none)
		{
			LP = LocalPlayer(SSG_PC.Player); 
			if(LP != None) 
			{ 
				LP.RemoveAllPostProcessingChains(); 
				LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(),INDEX_NONE,true); 
				if(SSG_PC.myHUD != None)
				{
					SSG_PC.myHUD.NotifyBindPostProcessEffects();
				}
			} 
		}
	}
	else
	{
		super.RestartPlayer(NewPlayer);

		if( SSG_PC != None ) //It must be this player's initial spawn
		{
			//We must set view target on first player spawn or camera weirdness will occur
			if( LocalPlayer( SSG_PC.Player ).ControllerID == 0 )
			{
				`log( "Initial Spawn for Player 1" );
				CameraFoci[ CurrentCameraFocusID ].SetLocation( SSG_PC.Pawn.Location );
			}

			NextCameraFocus = GameCamera.CalculateCentroidOfAttachedPlayers();
			CurrentCameraFocusID = ( CurrentCameraFocusID + 1 ) % 2;
			CameraFoci[ CurrentCameraFocusID ].SetLocation( NextCameraFocus );
			GameCamera.SetViewTarget( CameraFoci[ CurrentCameraFocusID ], GameCamera.SectionTransitionParams );

			SSG_PC.bSpawningForFirstTime = false;
		}
	}
}

//----------------------------------------------------------------------------------------------------------
function PostRespawn(Controller NewPlayer)
{
	local LocalPlayer LP;
	local SSG_PlayerController SSG_PC;
	local Vector NextCameraFocus;

	// initialize and start it up
	if ( PlayerController(NewPlayer) != None )
	{
		PlayerController(NewPlayer).TimeMargin = -0.1;
	}
	NewPlayer.Pawn.LastStartTime = WorldInfo.TimeSeconds;
	NewPlayer.Possess(NewPlayer.Pawn, false);
	NewPlayer.Pawn.PlayTeleportEffect(true, true);
	NewPlayer.ClientSetRotation(NewPlayer.Pawn.Rotation, TRUE);

	if (!WorldInfo.bNoDefaultInventoryForPlayer)
	{
		AddDefaultInventory(NewPlayer.Pawn);
	}
	SetPlayerDefaults(NewPlayer.Pawn);

	//Let our camera slowly interpolate to the new player centroid.
	NextCameraFocus = GameCamera.CalculateCentroidOfAttachedPlayers();
	CurrentCameraFocusID = ( CurrentCameraFocusID + 1 ) % 2;
	CameraFoci[ CurrentCameraFocusID ].SetLocation( NextCameraFocus );
	GameCamera.SetViewTarget( CameraFoci[ CurrentCameraFocusID ], GameCamera.SectionTransitionParams );

	SSG_PC = SSG_PlayerController(NewPlayer);
	if (SSG_PC != none)
	{
		LP = LocalPlayer(SSG_PC.Player); 
		if(LP != None) 
		{ 
			LP.RemoveAllPostProcessingChains(); 
			LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(),INDEX_NONE,true); 
			if(SSG_PC.myHUD != None)
			{
				SSG_PC.myHUD.NotifyBindPostProcessEffects();
			}
		} 
	}
}


//----------------------------------------------------------------------------------------------------------
function Pawn SpawnDefaultPawnOnLivingPawn( Controller NewPlayer, Pawn StartSpot )
{
	local class<Pawn> DefaultPlayerClass;
	local Rotator StartRotation;
	local Pawn ResultPawn;

	DefaultPlayerClass = GetDefaultPlayerClass( NewPlayer );

	// don't allow pawn to be spawned with any pitch or roll
	StartRotation.Yaw = StartSpot.Rotation.Yaw;

	ResultPawn = Spawn( DefaultPlayerClass,,,StartSpot.Location,StartRotation );
	if ( ResultPawn == None )
	{
		`log("Couldn't spawn player of type "$DefaultPlayerClass$" on "$StartSpot);
	}
	return ResultPawn;
}

//----------------------------------------------------------------------------------------------------------
function SetEndGameCameraFocusOn( Actor CameraFocus )
{
	if ( CameraFocus != None )
	{
		EndGameCameraFocus = CameraFocus;
	}

	if ( EndGameCameraFocus != None )
		EndGameCameraFocus.bAlwaysRelevant = true;
}

//----------------------------------------------------------------------------------------------------------
function GenerateSuperlatives()
{
	local array<SuperlativeNode> SuperlativeArray;
	local SuperlativeNode currentNode, blankNode;
	local SSG_PlayerController currentController;
	local int DeathTypeIterator;
	local string DeathTypeLocalization[DeathCauses.EnumCount];
	local int SuperfluousIndex, SuperfluousStrength;
	local string SuperfluousSuperlativesLocalization[5];

	blankNode.id = none;
	blankNode.amt = 0;

	foreach WorldInfo.AllControllers(class'SSG_PlayerController', currentController)
	{
		if(currentController.Superlatives[0] != "Cheater")
		{
			return;
		}
		currentController.Superlatives.Length = 0;
		currentNode.id = currentController;

		//most kills
		currentNode.amt = currentController.NumKills;
		currentNode.localization = "victoryLabelSuperlativesMostKills";
		if(SuperlativeArray.Length <= ESUP_MostKills)
		{
			if(currentNode.amt > 0 )
			{
				SuperlativeArray.InsertItem(ESUP_MostKills, currentNode);
			}
			else
			{
				SuperlativeArray.InsertItem(ESUP_MostKills, blankNode);
			}
		}
		else if(SuperlativeArray[ESUP_MostKills].amt < currentNode.amt || (SuperlativeArray[ESUP_MostKills].id == none && currentNode.amt > 0 ))
		{
			SuperlativeArray[ESUP_MostKills] = currentNode;
		}
		
		//fewest kills
		currentNode.amt = currentController.NumKills;
		currentNode.localization = "victoryLabelSuperlativesFewestKills";
		if(SuperlativeArray.Length <= ESUP_FewestKills)
		{
			SuperlativeArray.InsertItem(ESUP_FewestKills, currentNode);
		}
		else if(SuperlativeArray[ESUP_FewestKills].amt > currentNode.amt)
		{
			SuperlativeArray[ESUP_FewestKills] = currentNode;
		}

		//most deaths
		currentNode.amt = currentController.LivesLived;
		currentNode.localization = "victoryLabelSuperlativesMostDeaths";
		if(SuperlativeArray.Length <= ESUP_MostDeaths)
		{
			if(currentNode.amt > 1 )
			{
				SuperlativeArray.InsertItem(ESUP_MostDeaths, currentNode);
			}
			else
			{
				SuperlativeArray.InsertItem(ESUP_MostDeaths, blankNode);
			}
		}
		else if(SuperlativeArray[ESUP_MostDeaths].amt < currentNode.amt || (SuperlativeArray[ESUP_MostDeaths].id == none && currentNode.amt > 1 ))
		{
			SuperlativeArray[ESUP_MostDeaths] = currentNode;
		}

		//fewest deaths
		currentNode.amt = currentController.LivesLived;
		currentNode.localization = "victoryLabelSuperlativesFewestDeaths";
		if(SuperlativeArray.Length <= ESUP_FewestDeaths)
		{
			SuperlativeArray.InsertItem(ESUP_FewestDeaths, currentNode);
		}
		else if(SuperlativeArray[ESUP_FewestDeaths].amt > currentNode.amt)
		{
			SuperlativeArray[ESUP_FewestDeaths] = currentNode;
		}

		//most gold
		currentNode.amt = currentController.MoneyEarned;
		currentNode.localization = "victoryLabelSuperlativesMostGold";
		if(SuperlativeArray.Length <= ESUP_MostGold)
		{
			if(currentNode.amt > 0 )
			{
				SuperlativeArray.InsertItem(ESUP_MostGold, currentNode);
			}
			else
			{
				SuperlativeArray.InsertItem(ESUP_MostGold, blankNode);
			}
		}
		else if(SuperlativeArray[ESUP_MostGold].amt < currentNode.amt || (SuperlativeArray[ESUP_MostGold].id == none && currentNode.amt > 0 ))
		{
			SuperlativeArray[ESUP_MostGold] = currentNode;
		}

		//least gold
		currentNode.amt = currentController.MoneyEarned;
		currentNode.localization = "victoryLabelSuperlativesLeastGold";
		if(SuperlativeArray.Length <= ESUP_LeastGold)
		{
			SuperlativeArray.InsertItem(ESUP_LeastGold, currentNode);
		}
		else if(SuperlativeArray[ESUP_LeastGold].amt > currentNode.amt)
		{
			SuperlativeArray[ESUP_LeastGold] = currentNode;
		}

		DeathTypeLocalization[0]="victoryLabelSuperlativesDiedWater";
		DeathTypeLocalization[1]="victoryLabelSuperlativesDiedFire";
		DeathTypeLocalization[2]="victoryLabelSuperlativesDiedIce";
		DeathTypeLocalization[3]="victoryLabelSuperlativesDiedGuard";
		DeathTypeLocalization[4]="victoryLabelSuperlativesDiedCannon";
		DeathTypeLocalization[5]="victoryLabelSuperlativesDiedOffscreen";
		DeathTypeLocalization[6]="victoryLabelSuperlativesDiedExplosion";
		//Death types: all
		for(DeathTypeIterator = 0; DeathTypeIterator < EPDC_MAX; DeathTypeIterator++)
		{
			currentNode.amt = currentController.TimesDiedToType[DeathTypeIterator];
			currentNode.localization = DeathTypeLocalization[DeathTypeIterator];
			if(SuperlativeArray.Length <= ESUP_DiedWater+DeathTypeIterator)
			{
				if(currentNode.amt > 0 )
				{
					SuperlativeArray.InsertItem(ESUP_DiedWater+DeathTypeIterator, currentNode);
				}
				else
				{
					SuperlativeArray.InsertItem(ESUP_DiedWater+DeathTypeIterator, blankNode);
				}
			}
			else if(SuperlativeArray[ESUP_DiedWater+DeathTypeIterator].amt < currentNode.amt || (SuperlativeArray[ESUP_DiedWater+DeathTypeIterator].id == none && currentNode.amt > 0 ))
			{
				SuperlativeArray[ESUP_DiedWater+DeathTypeIterator] = currentNode;
			}
		}

		//Betrayals
		currentNode.amt = currentController.NumTimesBetrayedPlayer[0]+currentController.NumTimesBetrayedPlayer[1]+currentController.NumTimesBetrayedPlayer[2]+currentController.NumTimesBetrayedPlayer[3];
		currentNode.localization = "victoryLabelSuperlativesMostBetrayals";
		if(SuperlativeArray.Length <= ESUP_MostBetrayals)
		{
			if(currentNode.amt > 0 )
			{
				SuperlativeArray.InsertItem(ESUP_MostBetrayals, currentNode);
			}
			else
			{
				SuperlativeArray.InsertItem(ESUP_MostBetrayals, blankNode);
			}
		}
		else if(SuperlativeArray[ESUP_MostBetrayals].amt < currentNode.amt || (SuperlativeArray[ESUP_MostBetrayals].id == none && currentNode.amt > 0 ))
		{
			SuperlativeArray[ESUP_MostBetrayals] = currentNode;
		}

	}

	foreach SuperlativeArray(currentNode)
	{
		if(currentNode.id != none)
		{
			currentNode.id.Superlatives.AddItem(currentNode.localization);
		}
	}

	SuperfluousSuperlativesLocalization[0]="victoryLabelSuperlativesBestSmile";
	SuperfluousSuperlativesLocalization[1]="victoryLabelSuperlativesSoftestHands";
	SuperfluousSuperlativesLocalization[2]="victoryLabelSuperlativesBestDressed";
	SuperfluousSuperlativesLocalization[3]="victoryLabelSuperlativesSexiestName";
	SuperfluousSuperlativesLocalization[4]="victoryLabelSuperlativesScrumMaster";

	//participation ribbon
	foreach WorldInfo.AllControllers(class'SSG_PlayerController', currentController)
	{
		if(currentController.Superlatives.Length < 2)
		{
			currentController.Superlatives.AddItem("victoryLabelSuperlativesParticipation");
		}
		//No-cause ribbons
		for(SuperfluousIndex = 0; SuperfluousIndex < 5; SuperfluousIndex++)
		{
			SuperfluousStrength = Rand(100);
			if(SuperfluousStrength < 4)
			{
				currentController.Superlatives.AddItem(SuperfluousSuperlativesLocalization[SuperfluousIndex]);
			}
		}
	}
}

//----------------------------------------------------------------------------------------------------------
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	local string NewMapName,ThisMapPrefix,GameOption;
	local int PrefixIndex, MapPrefixPos;
	local class<GameInfo> NewGameType;

	// allow commandline to override game type setting
	GameOption = ParseOption( Options, "Game");
	if ( GameOption != "" )
	{
		return Default.class;
	}

	// strip the "play on" prefixes from the filename, if it exists (meaning this is a Play in Editor game)
	NewMapName = StripPlayOnPrefix( MapName );

	// Get the prefix for this map
	MapPrefixPos = InStr(NewMapName,"-");
	ThisMapPrefix = left(NewMapName,MapPrefixPos);

	// Change game type 
	for ( PrefixIndex=0; PrefixIndex<Default.DefaultMapPrefixes.Length; PrefixIndex++ )
	{
		if ( Default.DefaultMapPrefixes[PrefixIndex].Prefix ~= ThisMapPrefix )
		{
			NewGameType = class<GameInfo>(DynamicLoadObject(Default.DefaultMapPrefixes[PrefixIndex].GameType,class'Class'));
			if ( NewGameType != None )
			{
				return NewGameType;
			}
		}
	}

	return Default.class;
}


//----------------------------------------------------------------------------------------------------------
function ActivateAllPlayersSpawnedEvent()
{
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local SequenceObject SeqObj;
	local SequenceEvent SeqEvent;

	GameSeq = WorldInfo.GetGameSequence();
	if( GameSeq != None )
	{
		GameSeq.FindSeqObjectsByClass( class'SSG_SeqEvent_AllPlayersSpawned', true, AllSeqEvents );
		foreach AllSeqEvents( SeqObj )
		{
			SeqEvent = SequenceEvent( SeqObj );
			SeqEvent.CheckActivate( self, self, false );
		}
	}
}


//----------------------------------------------------------------------------------------------------------
exec function SafeOpen( string MapName )
{
	local SSG_PlayerController PC;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		if( LocalPlayer( PC.Player ).ControllerID == 0 )
		{
			SSG_HUD_Base( PC.myHUD ).ExitHUD();
		}
	}
	ConsoleCommand( "open " $MapName);
}

//----------------------------------------------------------------------------------------------------------
exec function FocusCameraOnPosition(Actor FocalPoint)
{
	GameCamera.SetViewTarget( FocalPoint, GameCamera.SectionTransitionParams );
}


//----------------------------------------------------------------------------------------------------------
exec function LockCameraOnPlayers()
{
	CameraFoci[ CurrentCameraFocusID ].SetLocation( GameCamera.ViewTarget.Target.Location );
	bCameraLockedOnPlayers = true;
}

//----------------------------------------------------------------------------------------------------------
exec function UnlockCameraFromPlayers()
{
	bCameraLockedOnPlayers = false;
}


//++++++++++++++++++++++++++++++++++++++++++ Default Properties ++++++++++++++++++++++++++++++++++++++++++//
DefaultProperties
{
	InitialSecondsUntilSuddenDeath = 90 //Default of 90 seconds; will be overrided by LevelSettings
	SecondsLeftUntilSuddenDeath = 0
	SuddenDeathBeginsCue=SoundCue'MiscSounds.EnrageHornCue'
	InSuddenDeath=false
	bInitialSpawn=true
	bCalledGameOver=false

	TransitionTimeLeftSeconds = 0
	CurrentCameraFocusID = 0
	CurrentPlayerToRespawnOn=None
	bCameraLockedOnPlayers=true
	bSpawnPlayersAtStart=true
	PlayersFinished=0
	SecondsUntilLevelEnd=5
	NumPlayersExpected=0

	//LastCheckpointStart=

	bDelayedStart=false
	bPauseable = true
	bRestartLevel=false

	BotClass=class'SSG_Bot'
	GameplayMessageClass=class'SSG_Message_Gameplay'
	DefaultPawnClass=class'SuperSlashNGrab.SSG_Pawn'
	HUDType=class'SSG_HUD_Base'
	//OnlineGameSettingsClass = class'SSG_GameSettings'
	PlayerControllerClass=class'SuperSlashNGrab.SSG_PlayerController'

	RespawnTime=2.0

	LevelNames(0)="rtmt_persistent";
	LevelNames(1)="rtm1_persistent";
	LevelNames(2)="rtm2_persistent";
	LevelNames(3)="rtm3_persistent";

	bShowLostArrow=true
	bIsFullyLoaded=false
}
