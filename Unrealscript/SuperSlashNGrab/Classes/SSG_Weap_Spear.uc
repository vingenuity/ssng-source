class SSG_Weap_Spear extends SSG_Weap_Melee;

//----------------------------------------------------------------------------------------------------------
reliable client function ClientGivenTo( Pawn NewOwner, bool bDoNotActivate )
{
	local SSG_Pawn SSGP;
	
	super.ClientGivenTo( NewOwner, bDoNotActivate );
	
	SSGP = SSG_Pawn( NewOwner );
	
	if( SSGP != none && SSGP.Mesh.GetSocketByName( SSGP.WeaponSocket ) != none )
	{
		if( SSGP.Controller == none || SSGP.Controller.IsA( 'SSG_PlayerController' ) )
			return;

		Mesh.SetShadowParent( SSGP.Mesh );
		Mesh.SetLightEnvironment( SSGP.LightEnvironment );
		SSGP.Mesh.AttachComponentToSocket( Mesh, SSGP.WeaponSocket );
	}
}



//----------------------------------------------------------------------------------------------------------
simulated state Swinging
{
	//----------------------------------------------------------------------------------------------------------
	simulated event Tick( float DeltaTime )
	{
		//Super.Tick( DeltaTime );
		TraceSwing();
	}


	//----------------------------------------------------------------------------------------------------------
	simulated event BeginState(Name PreviousStateName)
	{
	
		local SkeletalMeshComponent SkelMesh;
		Super.BeginState(PreviousStateName);
	
		SkelMesh = SkeletalMeshComponent(Mesh);
		if(SkelMesh != None)
		{
			if( AttackingParticleComponent == None )
			{
				AttackingParticleComponent = new(self) class'ParticleSystemComponent';
			}
			
			AttackingParticleComponent.SetTemplate(AttackingParticleTemplate);
			AttackingParticleComponent.SetColorParameter( 'Trail_Color', AttackingParticleColor );
			SkelMesh.AttachComponentToSocket(AttackingParticleComponent, TipSocketName);
			AttackingParticleComponent.ActivateSystem();
		}
	}


	//----------------------------------------------------------------------------------------------------------
	simulated event EndState( name NextStateName )
	{
		local SSG_Pawn SSGP;
		local SSG_Weap_Sword Sword;

		Super.EndState( NextStateName );
		AttackingParticleComponent.DeactivateSystem();

		SSGP = SSG_Pawn( Instigator );
		Sword = SSG_Weap_Sword( InvManager.FindInventoryType( class'SSG_Weap_Sword', false ) );
  		if( Sword != None && SSGP.Controller.IsA( 'SSG_PlayerController' ) )
  		{
			SSGP.Mesh.DetachComponent( Mesh );
			SSGP.Mesh.AttachComponentToSocket( Sword.Mesh, SSGP.WeaponSocket );
    		InvManager.SetCurrentWeapon( Sword );
  		}
	}
}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	WeaponID=ID_Spear

	MaxSwings=1
	Swings(0)=1

	WeapRangeUnrUnits=175.0
	NumCheckHitSections=1
	MinAttackAngle=-20.0
	MaxAttackAngle=0.0

	InstantHitDamage(0)=1
	InstantHitDamage(1)=1
	FireInterval(0)=+0.9667
	FireInterval(1)=+0.9667
	InstantHitMomentum(0)=40000.0
	InstantHitMomentum(1)=40000.0

	Swings(1)=1
	FiringStatesArray(1)="Swinging"
	WeaponFireTypes(1)=EWFT_Custom

	bHidden=true

	LockerOffset=(X=60.0,Y=20.0,Z=-20.0)
	LockerRotation=(Yaw=16384,Pitch=4096)

	FiringSound=SoundCue'SSG_WeaponSounds.Melee.SwordSwingCue'

	WeaponAnimationName=SSG_Weapon_Spear_01
	
	SwingFullBodyAnimationName1=SSG_Animations_Character_SpearAttack_Fullbody_01
	SwingFullBodyAnimationName2=SSG_Animations_Character_SpearAttack_Fullbody_01
	SwingUpperBodyAnimationName1=SSG_Animations_Character_SpearAttack_Torso_01
	SwingUpperBodyAnimationName2=SSG_Animations_Character_SpearAttack_Torso_01
	AnimationPlaySpeed=1.0
	
	Begin Object Name=WeapSkeletalMeshComponent
	  	AnimSets=( AnimSet'SSG_Weapons.Spear.SSG_Weapon_Spear_ANIMS_01' )
	  	AnimTreeTemplate=AnimTree'SSG_Weapons.Spear.SSG_Weapon_Spear_AnimTree'
		SkeletalMesh=SkeletalMesh'SSG_Weapons.Spear.SSG_Weapon_Spear_01'
	  	PhysicsAsset=PhysicsAsset'SSG_Weapons.Spear.SSG_Weapon_Spear_01_Physics'
	End Object

	AttackingParticleTemplate=ParticleSystem'SSG_Weapon_Particles.speartrail.SSG_Particles_SpearTrail_PS_01'
}
