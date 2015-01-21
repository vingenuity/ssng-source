/**
 * Derivative of UTPawnSoundGroup
 */
class SSG_Sound_PawnSoundGroup extends Object
	abstract
	dependson(SSG_PhysicalMaterialProperty);

var SoundCue DodgeSound;
var SoundCue DoubleJumpSound;
var SoundCue DefaultJumpingSound;
var SoundCue LandSound;
var SoundCue FallingDamageLandSound;
var SoundCue DyingSound;
var SoundCue HitSounds[3];
var SoundCue GibSound;
var SoundCue DrownSound;
var SoundCue GaspSound;
var SoundCue PawnBloodSound;

struct FootstepSoundInfo
{
	var name MaterialType;
	var SoundCue Sound;
};
/** footstep sound effect to play per material type */
var array<FootstepSoundInfo> FootstepSounds;
/** default footstep sound used when a given material type is not found in the list */
var SoundCue DefaultFootstepSound;

var array<FootstepSoundInfo> JumpingSounds;

var array<FootstepSoundInfo> LandingSounds;
var SoundCue DefaultLandingSound;

// The following are /body/ sounds, not vocals:
/* sound for regular bullet hits on the body */
var SoundCue BulletImpactSound;
/* sound from being crushed, such as by a vehicle */
var SoundCue CrushedSound;
/* sound when the body is gibbed*/
var SoundCue BodyExplosionSound;
var SoundCue InstagibSound;

static function PlayInstagibSound(Pawn P)
{
	P.Playsound(Default.InstagibSound, false, true);
}

static function PlayBulletImpact(Pawn P)
{
	P.PlaySound(Default.BulletImpactSound, false, true);
}

static function PlayCrushedSound(Pawn P)
{
	P.PlaySound(Default.CrushedSound,false,true);
}

static function PlayBodyExplosion(Pawn P)
{
	P.PlaySound(Default.CrushedSound,false,true);
}

static function PlayDodgeSound(Pawn P)
{
	P.PlaySound(Default.DodgeSound, false, true);
}

static function PlayDoubleJumpSound(Pawn P)
{
	P.PlaySound(Default.DoubleJumpSound, false, true);
}

static function PlayJumpSound(Pawn P)
{
	P.PlaySound(Default.DefaultJumpingSound, false, true);
}

static function PlayLandSound(Pawn P)
{
    //    PlayOwnedSound(GetSound(EST_Land), SLOT_Interact, FMin(1,-0.3 * P.Velocity.Z/P.JumpZ));
	local SoundCue LandSoundToPlay;
	local SSG_Pawn PasSSGP;

	PasSSGP = SSG_Pawn(P);
	LandSoundToPlay = GetLandSound(PasSSGP.GetMaterialBelowFeet());
	P.PlaySound(LandSoundToPlay, false, true);
}

static function PlayFallingDamageLandSound(Pawn P)
{
	P.PlaySound(Default.FallingDamageLandSound, false, true);
}

static function SoundCue GetFootstepSound(int FootDown, name MaterialType)
{
	local int i;

	i = default.FootstepSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? default.DefaultFootstepSound : default.FootstepSounds[i].Sound; // checking for a '' material in case of empty array elements
}

static function SoundCue GetJumpSound(name MaterialType)
{
	local int i;
	i = default.JumpingSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? default.DefaultJumpingSound : default.JumpingSounds[i].Sound; // checking for a '' material in case of empty array elements
}

static function SoundCue GetLandSound(name MaterialType)
{
	local int i;
	i = default.LandingSounds.Find('MaterialType', MaterialType);
	return (i == -1 || MaterialType=='') ? default.DefaultLandingSound : default.LandingSounds[i].Sound; // checking for a '' material in case of empty array elements
}

static function PlayDyingSound(Pawn P)
{
	P.PlaySound(Default.DyingSound);
}

/** play sound when taking a hit
 * this sound should be played replicated
 */
static function PlayTakeHitSound(Pawn P, int Damage)
{
	local int HitSoundIndex;

	if ( P.Health > 0.5 * P.HealthMax )
	{
		HitSoundIndex = (Damage < 2) ? 0 : 1;
	}
	else
	{
		HitSoundIndex = (Damage < 2) ? 1 : 2;
	}
	P.PlaySound(default.HitSounds[HitSoundIndex]);
	P.PlaySound(default.PawnBloodSound);
}

static function PlayGibSound(Pawn P)
{
	P.PlaySound(default.GibSound, true);
}

static function PlayGaspSound(Pawn P)
{
	P.PlaySound(default.GaspSound, true);
}

static function PlayDrownSound(Pawn P)
{
	P.PlaySound(default.DrownSound, true);
}

static function PlayFootstepSound(SSG_Pawn P, int FootDown)
{
	local SoundCue FootstepSoundToPlay;

	FootstepSoundToPlay = GetFootstepSound(FootDown, P.GetMaterialBelowFeet());
	P.PlaySound(FootstepSoundToPlay, false, true);
}

defaultproperties
{
	DrownSound=SoundCue'SSG_TrapSounds.MeadTrap.BigSplashCue'
	GaspSound=SoundCue'CharacterSounds.HitGruntCue'

	BulletImpactSound=SoundCue'CharacterSounds.HitGruntCue'

	DefaultJumpingSound=SoundCue'CharacterSounds.Falling.SSG_Player_Land_Cue_01'
	DefaultLandingSound=SoundCue'CharacterSounds.Falling.SSG_Player_Land_Cue_01'
	DefaultFootstepSound=SoundCue'CharacterSounds.Footsteps.FootstepStoneCue'

	FootstepSounds[0]=(MaterialType=Stone,Sound=SoundCue'CharacterSounds.Footsteps.FootstepStoneCue')
	FootstepSounds[1]=(MaterialType=Dirt,Sound=SoundCue'MiscSounds.SilenceCue')
	FootstepSounds[2]=(MaterialType=Wood,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Wood_Cue')
	FootstepSounds[3]=(MaterialType=ShallowWater,Sound=SoundCue'MiscSounds.SilenceCue')
	FootstepSounds[4]=(MaterialType=Snow,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Snow_Cue')
	FootstepSounds[5]=(MaterialType=Ice,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Ice_Cue')

	JumpingSounds[0]=(MaterialType=Stone,Sound=SoundCue'CharacterSounds.Footsteps.FootstepStoneCue')
	JumpingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'MiscSounds.SilenceCue')
	JumpingSounds[2]=(MaterialType=Wood,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Wood_Cue')
	JumpingSounds[3]=(MaterialType=ShallowWater,Sound=SoundCue'MiscSounds.SilenceCue')
	JumpingSounds[4]=(MaterialType=Snow,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Snow_Cue')
	JumpingSounds[5]=(MaterialType=Ice,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Ice_Cue')

	LandingSounds[0]=(MaterialType=Stone,Sound=SoundCue'CharacterSounds.Falling.SSG_Player_Land_Cue_01')
	LandingSounds[1]=(MaterialType=Dirt,Sound=SoundCue'MiscSounds.SilenceCue')
	LandingSounds[2]=(MaterialType=Wood,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Wood_Cue')
	LandingSounds[3]=(MaterialType=ShallowWater,Sound=SoundCue'MiscSounds.SilenceCue')
	LandingSounds[4]=(MaterialType=Snow,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Snow_Cue')
	LandingSounds[5]=(MaterialType=Ice,Sound=SoundCue'CharacterSounds.Footsteps.SSG_Footstep_Ice_Cue')

	HitSounds[0]=SoundCue'CharacterSounds.Testing.HitGuardGruntTestCue01'
	HitSounds[1]=SoundCue'CharacterSounds.Testing.HitGuardGruntTestCue01'
	HitSounds[2]=SoundCue'CharacterSounds.Testing.HitGuardGruntTestCue01'

	PawnBloodSound=SoundCue'CharacterSounds.Testing.HitBloodCue'
}

