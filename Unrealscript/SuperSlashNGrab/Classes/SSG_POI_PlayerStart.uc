class SSG_POI_PlayerStart extends PlayerStart
	placeable;

//----------------------------------------------------------------------------------------------------------
var() int					LevelSectionID;
var() int					PlayerNum;
var() bool                  bAddSpawnTarget;
var SSG_PlayerSpawnTarget   Target;
var Vector                  TargetLocOffset;


//----------------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if( bAddSpawnTarget )
	{
		Target = Spawn( class'SSG_PlayerSpawnTarget', self,, Location + TargetLocOffset );
	}

	if( Target != None && PlayerNum >= 0 && PlayerNum < 4 )
		Target.SetColor( PlayerNum );
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	PlayerNum=0
	LevelSectionID=0
	bAddSpawnTarget=false
	TargetLocOffset=(X=0.0,Y=0.0,Z=-80.0)
}
