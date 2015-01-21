class SSG_LevelSettings extends Actor
	ClassGroup( Common )
	placeable;

//----------------------------------------------------------------------------------------------------------
var() int InitialSecondsUntilSuddenDeath;
var() int DebugStartSection;
var() bool bSpawnPlayersAtStart;
var const transient SpriteComponent GoodSprite;



//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	SSG_GameInfo( WorldInfo.Game ).OverrideDefaultsWithLevelSettings( self );
}



//++++++++++++++++++++++++++++++++++++++++++ Default Properties ++++++++++++++++++++++++++++++++++++++++++//
DefaultProperties
{
	InitialSecondsUntilSuddenDeath=90;
	DebugStartSection=0
	bSpawnPlayersAtStart=true
	TickGroup=TG_DuringAsyncWork 

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Camera'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Camera"
	End Object
	Components.Add(Sprite)
	GoodSprite=Sprite
}
