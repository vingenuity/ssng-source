class SSG_Pawn_ShieldBot extends SSG_Pawn_Bot;

//----------------------------------------------------------------------------------------------------------
function AddDefaultInventory()
{
	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Sword' );
	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Shield' );
}

//----------------------------------------------------------------------------------------------------------
function bool BotBlock(bool bFinished)
{
	StartFire(1);
	return true;
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	Health=1
	RangeToBeginAttacking = 10
	ControllerClass=class'SSG_Bot_Shield'
	bHasSecondaryWeapon = true

	Begin Object Name=PawnSkeletalMesh
	  	SkeletalMesh=SkeletalMesh'SSG_Characters.Guard.SSG_Character_ShieldGuard_01'
    	Materials(0)=Material'SSG_Characters.Guard.SSG_Character_ShieldGuard_MAT_01'
		PhysicsAsset=PhysicsAsset'SSG_Characters.Guard.SSG_Character_ShieldGuard_PHS_01'
	End Object
}
