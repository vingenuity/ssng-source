class SSG_Respawn_Mesh extends Actor;

var StaticMeshComponent SelectorMesh;

var StaticMesh StaticMeshArray[4];
var Material MaterialArray[4];

function Tick(float deltaTime)
{
	if( Base == none && !SSG_PlayerController(Owner).WaitingOnRespawn )
	{
		SSG_PlayerController(Owner).IncrementPlayerToSpawn();
	}
}

DefaultProperties
{
	TickGroup=TG_DuringAsyncWork 
	bIgnoreBaseRotation=true

	StaticMeshArray[0]=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_01'
	StaticMeshArray[1]=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_02'
	StaticMeshArray[2]=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_03'
	StaticMeshArray[3]=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_04'

	MaterialArray[0]=Material'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_MAT_01'
	MaterialArray[1]=Material'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_MAT_02'
	MaterialArray[2]=Material'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_MAT_03'
	MaterialArray[3]=Material'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_MAT_04'

	Begin Object Class=StaticMeshComponent Name=SelectorStaticMesh
	  TickGroup=TG_DuringAsyncWork
	  Translation=(Z=-50)
	  //Rotation=(Yaw=16384)
	  StaticMesh=StaticMesh'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_01'
      Materials(0)=Material'SSG_Character_Particles.HUD.SSG_HUD_RespawnIndicator_MAT_01'
	  Scale=1.2
	End Object
	SelectorMesh = SelectorStaticMesh;
	Components.Add( SelectorStaticMesh )
}
