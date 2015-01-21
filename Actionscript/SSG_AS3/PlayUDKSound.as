package
{
	import scaleform.gfx.Extensions;
	
	//---------------------------------------------------------------------------------------------------
	public function PlayUDKSound( sound_theme_name:String, sound_event_name:String )
	{
		if( Extensions.isGFxPlayer )
			trace( "Playing " + sound_event_name );
		if( Extensions.gfxProcessSound != null )
		{
			Extensions.gfxProcessSound( this, sound_theme_name, sound_event_name );
		}
	}
}