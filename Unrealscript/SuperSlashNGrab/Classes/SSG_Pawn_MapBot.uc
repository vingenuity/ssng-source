class SSG_Pawn_MapBot extends SSG_Pawn_Bot;

event PostBeginPlay()
{
	super.PostBeginPlay();
	ThiefMaterial.SetVectorParameterValue( 'Player Color', class'SSG_PlayerController'.default.PlayerColors[ 0 ] );
}

DefaultProperties
{

	begin object name=PawnSkeletalMesh
		SkeletalMesh=SkeletalMesh'SSG_Characters.Thief.SSG_Character_Thief_SK_01'
		Materials(0)=Material'SSG_Characters.Thief.SSG_Thief_MAT_01'
		PhysicsAsset=PhysicsAsset'SSG_Characters.thief.SSG_Character_Thief_PHS_01'
	end object

	ControllerClass=class'SSG_Bot_Map'
}
