class SSG_Mesh_LocalizedText extends Actor placeable;


//var MaterialInstanceConstant LocalizedMaterial;

var() array<Material> LocalizedMaterialArray;
var() const editconst StaticMeshComponent	StaticMeshComponent;

event PostBeginPlay()
{
	super.PostBeginPlay();
	UpdateLocalization();
}

event UpdateLocalization()
{
	local int LanguageIndex;

	LanguageIndex = class'Text_Localizer'.static.GetCurrentLocalizationLanguage();
	self.StaticMeshComponent.SetMaterial(0, LocalizedMaterialArray[LanguageIndex]);
}


DefaultProperties
{
	TickGroup=TG_DuringAsyncWork
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		TickGroup=TG_DuringAsyncWork
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
	End Object
	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
}
