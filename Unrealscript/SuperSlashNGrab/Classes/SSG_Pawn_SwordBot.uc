class SSG_Pawn_SwordBot extends SSG_Pawn_Bot;

//----------------------------------------------------------------------------------------------------------
function AddDefaultInventory()
{
	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Sword' );
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	Health=1
	RangeToBeginAttacking = 128
	
	Begin Object Name=PawnSkeletalMesh
	  	SkeletalMesh=SkeletalMesh'SSG_Characters.Guard.SSG_Character_SwordGuard_01'
    	Materials(0)=Material'SSG_Characters.Guard.SSG_Character_SwordGuard_MAT_01'
		PhysicsAsset=PhysicsAsset'SSG_Characters.guard.SSG_Character_Guard_PHS_01'
	End Object
}
