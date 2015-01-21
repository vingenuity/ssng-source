class SSG_DamageType extends DamageType;

//From UTDamageType

/** Information About the weapon that caused this if available */

var 	class<SSG_Weap_Base>	DamageWeaponClass;
var		int						DamageWeaponFireMode;

/************** DEATH ANIM *********/

/** Name of animation to play upon death. */
var(DeathAnim)	name	DeathAnim;
/** How fast to play the death animation */
var(DeathAnim)	float	DeathAnimRate;
/** If true, char is stopped and root bone is animated using a bone spring for this type of death. */
var(DeathAnim)	bool	bAnimateHipsForDeathAnim;
/** If non-zero, motor strength is ramped down over this time (in seconds) */
var(DeathAnim)	float	MotorDecayTime;
/** If non-zero, stop death anim after this time (in seconds) after stopping taking damage of this type. */
var(DeathAnim)	float	StopAnimAfterDamageInterval;

/** Whether or not this damage type can cause a blood splatter **/
var bool bCausesBloodSplatterDecals;

//End UTDamageType

enum DeathCauses
{
	EPDC_Water, EPDC_Fire, EPDC_Ice, EPDC_Guard, EPDC_Cannon, EPDC_Offscreen, EPDC_Explosion
};

var int DeathCauseType;

//From UTDamageType
/**
 * Possibly spawn a custom hit effect
 */
static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation);

/** @return duration of hit effect, primarily used for replication timeout to avoid replicating out of date hits to clients when pawns become relevant */
static function float GetHitEffectDuration(Pawn P, float Damage)
{
	return 0.5;
}
//End UTDamageType

//Possibly spanw a custom effect on the pawn when it dies, eg. covered in burns
static function SpawnDeathEffect(Pawn P, vector HitLocation);

DefaultProperties
{
	bAnimateHipsForDeathAnim=true
	DeathAnimRate=1.0
	bCausesBloodSplatterDecals = true
	DeathCauseType = EPDC_MAX;
}
