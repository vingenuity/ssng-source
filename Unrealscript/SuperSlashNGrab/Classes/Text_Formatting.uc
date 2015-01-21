class Text_Formatting extends Object;


const MAX_ROMAN_NUMBER_SYMBOLS = 13;
var string RomanValues[ MAX_ROMAN_NUMBER_SYMBOLS ];
var int DecimalValues[ MAX_ROMAN_NUMBER_SYMBOLS ];



//----------------------------------------------------------------------------------------------------------
static final function string FormatNumberIntoRomanNumerals( int number )
{
	local string RomanNumerals;
	local int i;

	if( number == 0 )
		return "0";

	for( i = 0; i < MAX_ROMAN_NUMBER_SYMBOLS; ++i )
	{
		while( number >= default.DecimalValues[ i ] )
		{
			number -= default.DecimalValues[ i ];
			RomanNumerals $= default.RomanValues[ i ];
		}
	}

	return RomanNumerals;
}

//----------------------------------------------------------------------------------------------------------
static final function string FormatTimeIntoString( int timeInSeconds )
{
	//This function is a slight spin on UTHUD's FormatTime
	local string NewTimeString;
	local int minutes, seconds, SECONDS_IN_MINUTE;
	SECONDS_IN_MINUTE = 60;
	
	minutes = timeInSeconds / SECONDS_IN_MINUTE;

	seconds = timeInSeconds % SECONDS_IN_MINUTE;

	NewTimeString = "" $ ( minutes > 9 ? String( minutes ) : "0" $ String( minutes ) ) $ ":";
	NewTimeString = NewTimeString $ ( seconds > 9 ? String( seconds ) : "0"$String( seconds ) );
	return NewTimeString;
}



DefaultProperties
{
	DecimalValues[0]=1000
	DecimalValues[1]=900
	DecimalValues[2]=500
	DecimalValues[3]=400
	DecimalValues[4]=100
	DecimalValues[5]=90
	DecimalValues[6]=50
	DecimalValues[7]=40
	DecimalValues[8]=10
	DecimalValues[9]=9
	DecimalValues[10]=5
	DecimalValues[11]=4
	DecimalValues[12]=1

	RomanValues[0]="M"
	RomanValues[1]="CM"
	RomanValues[2]="D"
	RomanValues[3]="CD"
	RomanValues[4]="C"
	RomanValues[5]="XC"
	RomanValues[6]="L"
	RomanValues[7]="XL"
	RomanValues[8]="X"
	RomanValues[9]="IX"
	RomanValues[10]="V"
	RomanValues[11]="IV"
	RomanValues[12]="I"
}
