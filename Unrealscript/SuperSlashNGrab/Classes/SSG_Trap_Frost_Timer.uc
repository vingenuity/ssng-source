class SSG_Trap_Frost_Timer extends SSG_Trap_Flames_Timer;

DefaultProperties
{
	GlowColor=(R=0.2,G=1.0,B=1.0,A=1.0)

	Begin Object Name=TrapStaticMeshComponent
		StaticMesh=StaticMesh'SSG_Traps.Ice_Trap.SSG_Trap_Ice_Grate_01'
	End Object

	Begin Object Name=TrapFlameParticleSystem
        Template=ParticleSystem'SSG_Trap_Particles.Frost.SSG_Frost_PS_01'
	End Object

	DamageTypeToApply=class'SSG_DmgType_Frozen'
}
