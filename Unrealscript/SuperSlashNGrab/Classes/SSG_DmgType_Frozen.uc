class SSG_DmgType_Frozen extends SSG_DamageType;

var Material DeathMaterial;

static function SpawnHitEffect(Pawn P, float Damage, vector Momentum, name BoneName, vector HitLocation)
{
	//TODO small burn effects on damage
}

static function SpawnDeathEffect(Pawn P, vector HitLocation)
{
	//TODO large burn effects on death, including texture replacement
	P.Mesh.SetMaterial(0, default.DeathMaterial);
}

DefaultProperties
{
	DeathMaterial=Material'SSG_Characters.SpecialEffects.SSG_Character_Frozen_MAT_01'
	bCausesBloodSplatterDecals=false
	DeathCauseType=EPDC_Ice
}
