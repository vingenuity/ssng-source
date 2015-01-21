class SSG_Weap_Sword extends SSG_Weap_Melee;

//----------------------------------------------------------------------------------------------------------
reliable client function ClientGivenTo( Pawn NewOwner, bool bDoNotActivate )
{
	local SSG_Pawn SSGP;
	
	super.ClientGivenTo( NewOwner, bDoNotActivate );
	
	SSGP = SSG_Pawn( NewOwner );
	
	if( SSGP.Controller == none || SSGP != none && SSGP.Mesh.GetSocketByName( SSGP.WeaponSocket ) != none )
	{
		Mesh.SetShadowParent( SSGP.Mesh );
		Mesh.SetLightEnvironment( SSGP.LightEnvironment );
		SSGP.Mesh.AttachComponentToSocket( Mesh, SSGP.WeaponSocket );
	}
}


//----------------------------------------------------------------------------------------------------------
function RenderAttackParticle()
{
	local SSG_Pawn SSGP;

	SSGP = SSG_Pawn( Instigator );
	if( SSGP == None )
		return;

	SSGP.SwordFirstSwingParticleSystem.SetActive( false );
	SSGP.SwordSecondSwingParticleSystem.SetActive( false );

	if( bSwingTwice )
	{
		SSGP.Mesh.AttachComponentToSocket( SSGP.SwordSecondSwingParticleSystem, SSGP.AttackParticleSocket );
		SSGP.SwordSecondSwingParticleSystem.SetActive( true );
	}
	else
	{
		SSGP.Mesh.AttachComponentToSocket( SSGP.SwordFirstSwingParticleSystem, SSGP.AttackParticleSocket );
		SSGP.SwordFirstSwingParticleSystem.SetActive( true );
	}
}


//----------------------------------------------------------------------------------------------------------
//state Swinging
//{
//	simulated event BeginState(Name PreviousStateName)
//	{

//		local SkeletalMeshComponent SkelMesh;
//		Super.BeginState(PreviousStateName);

//		SkelMesh = SkeletalMeshComponent(Mesh);
//		if(SkelMesh != None)
//		{
//			if( AttackingParticleComponent == None )
//			{
//				AttackingParticleComponent = new(self) class'ParticleSystemComponent';
//			}
			
//			AttackingParticleComponent.SetTemplate(AttackingParticleTemplate);
//			AttackingParticleComponent.SetColorParameter( 'Trail_Color', AttackingParticleColor );
//			SkelMesh.AttachComponentToSocket(AttackingParticleComponent, TipSocketName);
//			AttackingParticleComponent.ActivateSystem();
//		}
//	}

//	simulated event EndState(Name NextStateName)
//	{
//		Super.EndState(NextStateName);
//		AttackingParticleComponent.DeactivateSystem();
//	}
//}


//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	WeaponID=ID_Sword
	InstantHitDamage(0)=1
	FireInterval(0)=+0.3111
	InstantHitMomentum(0)=40000.0

	WeapRangeUnrUnits=110.0
	NumCheckHitSections=4
	MinAttackAngle=-80.0
	MaxAttackAngle=110.0

	SwingFullBodyAnimationName1=SSG_Animations_Character_SwordAttack_FirstSwing_FullBody_01
	SwingFullBodyAnimationName2=SSG_Animations_Character_SwordAttack_SecondSwing_FullBody_01
	SwingUpperBodyAnimationName1=SSG_Animations_Character_SwordAttack_FirstSwing_Torso_01
	SwingUpperBodyAnimationName2=SSG_Animations_Character_SwordAttack_SecondSwing_Torso_01
	AnimationPlaySpeed=1.5

	WeaponAnimationName=SSG_Weapon_Sword_01

	LockerOffset=(X=60.0,Y=25.0,Z=-20.0)
	LockerRotation=(Yaw=-8192,Pitch=-4096,Roll=-4096)

	FiringSound=SoundCue'SSG_WeaponSounds.Melee.SwordSwingCue'
	
	Begin Object Name=WeapSkeletalMeshComponent
	  	AnimSets=( AnimSet'SSG_Weapons.Sword.SSG_Weapons_Sword_ANIMS_01' )
	  	AnimTreeTemplate=AnimTree'SSG_Weapons.Sword.SSG_Weapon_Sword_AnimTree_01'
		SkeletalMesh=SkeletalMesh'SSG_Weapons.Sword.SSG_Weapon_Sword_01'
	  	PhysicsAsset=PhysicsAsset'SSG_Weapons.Sword.SSG_Weapon_Sword_01_Physics'
	End Object

	AttackingParticleTemplate=ParticleSystem'SSG_Weapon_Particles.swordtrail.SSG_Particles_SwordArch_PS_01'
	//AttackingParticleTemplate=ParticleSystem'SSG_Character_Particles.Blood.SSG_Particles_Blood_Spray_PS_01'
}
