class Text_Localizer extends Object
	config(Game);

//----------------------------------------------------------------------------------------------------------
enum Language
{
    /* 0*/LANGUAGE_ENG<DisplayName=English>,
    /* 1*/LANGUAGE_ESM<DisplayName=Espanol>,
    /* 2*/LANGUAGE_FRA<DisplayName=Francais>,
    /* 3*/LANGUAGE_XXX<DisplayName=Test Language Xx>
};

//----------------------------------------------------------------------------------------------------------
var config Language GameLanguage;

var string localizationFile_ENG;
var string localizationFile_ESM;
var string localizationFile_FRA;
var string localizationFile_XXX;


//----------------------------------------------------------------------------------------------------------
static function string ConvertLanguageToString( Language Lang )
{
    local string LanguageString;

    switch( Lang )
    {
    case LANGUAGE_ENG:
        LanguageString = "English";
        break;
    case LANGUAGE_ESM:
        LanguageString = "Espanol";
        break;
    case LANGUAGE_FRA:
        LanguageString = "Francais";
        break;
    case LANGUAGE_XXX:
        default:
        LanguageString = "Test Language Xx";
    }

    return LanguageString;
}

//----------------------------------------------------------------------------------------------------------
static function string GetLocalizedStringWithName( string sectionName, string stringName )
{
    local string currentFile;

    switch( Default.GameLanguage )
    {
    case LANGUAGE_ENG:
        currentFile = Default.localizationFile_ENG;
        break;
    case LANGUAGE_ESM:
        currentFile = Default.localizationFile_ESM;
        break;
    case LANGUAGE_FRA:
        currentFile = Default.localizationFile_FRA;
        break;
    case LANGUAGE_XXX:
        default:
        currentFile = Default.localizationFile_XXX;
    }

    return ParseLocalizedPropertyPath( currentFile $ "." $ sectionName $ "." $ stringName );
}

//----------------------------------------------------------------------------------------------------------
static function Language GetCurrentLocalizationLanguage()
{
    return Default.GameLanguage;
}

//----------------------------------------------------------------------------------------------------------
static function string GetCurrentLocalizationName()
{
    return ConvertLanguageToString( GetCurrentLocalizationLanguage() );
}

//----------------------------------------------------------------------------------------------------------
static function SetLocalizationLanguage( Language newLanguage )
{
	Default.GameLanguage = newLanguage;
	StaticSaveConfig();
}

//----------------------------------------------------------------------------------------------------------
static function array< string > GetSupportedLanguages()
{
    local array< string > SupportedLanguages;
    local int i;

    for( i = 0; i < Language.EnumCount - 1; ++i )
    {
        SupportedLanguages.AddItem( ConvertLanguageToString( Language( i ) ) );
    }

    return SupportedLanguages;
}

DefaultProperties
{
    localizationFile_ENG = "SSG_ENG"
    localizationFile_ESM = "SSG_ESM"
    localizationFile_FRA = "SSG_FRA"
    localizationFile_XXX = "SSG_XXX"
}
