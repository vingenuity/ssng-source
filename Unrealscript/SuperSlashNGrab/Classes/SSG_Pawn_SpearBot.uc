class SSG_Pawn_SpearBot extends SSG_Pawn_Bot;

//----------------------------------------------------------------------------------------------------------
function AddDefaultInventory()
{
	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Spear' );
}

//----------------------------------------------------------------------------------------------------------
function bool BotFire(bool bFinished)
{
	StartFire(1);
	return true;
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	Health=1
	RangeToBeginAttacking = 150
	bHasSecondaryWeapon=true
	
	Begin Object Name=PawnSkeletalMesh
	  	SkeletalMesh=SkeletalMesh'SSG_Characters.Guard.SSG_Character_SpearGuard_01'
    	Materials(0)=Material'SSG_Characters.Guard.SSG_Character_SpearGuard_MAT_01'
		PhysicsAsset=PhysicsAsset'SSG_Characters.Guard.SSG_Character_SpearGuard_PHS_01'
	End Object
}
