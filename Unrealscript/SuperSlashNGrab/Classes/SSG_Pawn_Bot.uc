class SSG_Pawn_Bot extends SSG_Pawn
	placeable;

var() string PatrolName;

var() Actor LookAtTargetWhenIdle;

var() int RangeToBeginAttacking;

var() int AlertRange;

var() float TimeToWaitAtNodes;

var() bool bBotIsCurious;

var() int GoldToDropOnDeath;

var() int SectionNumber;

//----------------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	super.PostBeginPlay();
	AddDefaultInventory(); //Not automatically called because it's not "restarting" the bot
}

//----------------------------------------------------------------------------------------------------------
function AddDefaultInventory()
{
	InvManager.CreateInventory( class'SuperSlashNGrab.SSG_Weap_Sword' );
}

//----------------------------------------------------------------------------------------------------------
event DoSSGMead()
{
	local SSG_Bot Drunkard;
	Drunkard = SSG_Bot(Controller);
	Drunkard.DoMead();
}

//----------------------------------------------------------------------------------------------------------
function TakeDamage( int Damage, Controller InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser )
{
	if(DamageType == class'SSG_DmgType_Offscreen')
	{
		return;
	}
	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}
//----------------------------------------------------------------------------------------------------------
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local bool deathAllowed;
	local SSG_SeqEvent_GuardDied bestFitEvent;
	local SSG_SeqEvent_GuardDied currentEvent;
	local Sequence GameSeq;
	local array<SequenceObject> AllSeqEvents;
	local int j;

	deathAllowed = super.Died( Killer, DamageType, HitLocation );
	DropAmountOfTreasure( GoldToDropOnDeath );
	if (SectionNumber >= SSG_GameInfo(WorldInfo.Game).CurrentSection)
	{
	
		GameSeq = WorldInfo.GetGameSequence();
		if (GameSeq != None)
		{
			GameSeq.FindSeqObjectsByClass(class'SSG_SeqEvent_GuardDied', true, AllSeqEvents);
			for (j = 0; j < AllSeqEvents.Length; j++)
			{
				currentEvent = SSG_SeqEvent_GuardDied(AllSeqEvents[j]);
				if(bestFitEvent == none)
				{
					bestFitEvent = currentEvent;
				}
				else if(VSize(location - currentEvent.GetGuardroomLocation()) < VSize(location - bestFitEvent.GetGuardroomLocation()) )
				{
					bestFitEvent = currentEvent;
				}
			}
			if(bestFitEvent != none)
			{
				bestFitEvent.CheckActivate(self, self, false);
			}
		}
	}

	return deathAllowed;
}

//----------------------------------------------------------------------------------------------------------
DefaultProperties
{
	Health=1 //should not have mattered, but it seems to have been affecting sword guard spawns
	bCanPickupInventory = false
	GroundSpeed= 550.0
	RangeToBeginAttacking = 128
	AlertRange = 2048
	TimeToWaitAtNodes = 0.5
	bBotIsCurious = false
	GoldToDropOnDeath = 100
	JumpZ = 0

	SectionNumber = -1;

	PatrolName = "None";
	ControllerClass=class'SSG_Bot'

	Begin Object Name=CollisionCylinder
		BlockActors=false
	End Object

	Begin Object Name=PawnSkeletalMesh
	  	SkeletalMesh=SkeletalMesh'SSG_Characters.Guard.SSG_Character_SwordGuard_01'
    	Materials(0)=Material'SSG_Characters.Guard.SSG_Character_SwordGuard_MAT_01'
		PhysicsAsset=PhysicsAsset'SSG_Characters.guard.SSG_Character_Guard_PHS_01'
	End Object

	SoundGroupClass=class'SSG_Sound_BotSoundGroup'

}
