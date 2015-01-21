class SSG_GameInfo_Map extends SSG_GameInfo; //TODO may eventually extend from UDKGame, but for now, this will do

var int CurrentLevelSelect;

var int maxLevels;

var array<string> ConnectedLevels;

//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	Super.PostBeginPlay();
}

//----------------------------------------------------------------------------------------------------------
event InitGame( string Options, out string ErrorMessage )
{
	super.InitGame( Options, ErrorMessage );
}

//----------------------------------------------------------------------------------------------------------
exec function SelectNextLevel()
{
	if(CurrentLevelSelect < maxLevels)
	{
		CurrentLevelSelect++;
		SelectLevelByNum(CurrentLevelSelect);
	}
}

//----------------------------------------------------------------------------------------------------------
exec function SelectPreviousLevel()
{
	if(CurrentLevelSelect > 1)
	{
		CurrentLevelSelect--;
		SelectLevelByNum(CurrentLevelSelect);
	}
}

//----------------------------------------------------------------------------------------------------------
exec function SelectLevelByNum(int LevelNum)
{
	local SSG_Bot_Map FoundBot;
	foreach WorldInfo.AllControllers(class'SSG_Bot_Map', FoundBot)
	{
		FoundBot.NewHomeByIndex(LevelNum);
	}
}

exec function LoadSelectedLevel()
{
	local SSG_PlayerController PC;

	ForEach WorldInfo.AllControllers( class'SSG_PlayerController', PC )
	{
		if( LocalPlayer( PC.Player ).ControllerID == 0 )
		{
			SSG_HUD_Base( PC.myHUD ).ExitHUD();
		}
	}
	ConsoleCommand( "open " $ConnectedLevels[CurrentLevelSelect-1]);
}

DefaultProperties
{
	maxLevels=3
	CurrentLevelSelect=1
	ConnectedLevels(0)="SSG-POCT_AISandbox.udk"
	ConnectedLevels(1)="SSG-POCG_MeadPrototype.udk"
	ConnectedLevels(2)="SSG-POCT_Prototype2048x3072.udk"
}
