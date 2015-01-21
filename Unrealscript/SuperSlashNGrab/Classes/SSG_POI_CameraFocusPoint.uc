class SSG_POI_CameraFocusPoint extends Actor
	ClassGroup( Common )
	placeable;

//----------------------------------------------------------------------------------------------------------
var() int LevelSectionID;

var const transient SpriteComponent GoodSprite;



//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
  super.PostBeginPlay();

  SSG_GameInfo( WorldInfo.Game ).RegisterCameraFocusPoint( self );
}



//++++++++++++++++++++++++++++++++++++++++++ Default Properties ++++++++++++++++++++++++++++++++++++++++++//
DefaultProperties
{
	LevelSectionID=0

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
