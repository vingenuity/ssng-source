package
{
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.events.FocusHandlerEvent;
	import scaleform.clik.events.ListEvent;
	import scaleform.gfx.Extensions;
	import PlayUDKSound;
	
	public class SSG_ScrollingList extends ScrollingList
	{
	
		// Constructor
		public function SSG_ScrollingList()
		{
			super();
			
			Extensions.enabled = true;
			
			//addEventListener( FocusHandlerEvent.FOCUS_IN, PlayFocusSound );
			addEventListener( ListEvent.INDEX_CHANGE, PlayListEventSound );
			//addEventListener( ListEvent.ITEM_CLICK, PlayListEventSound );
		}
		
		function PlayFocusSound( focus_event:FocusHandlerEvent )
		{
			if( focus_event.type != FocusHandlerEvent.FOCUS_IN )
				return;
			
			PlayUDKSound( "MenuSounds", "ScaleformFocused" );
		}
		
		function PlayListEventSound( list_event:ListEvent )
		{
			switch( list_event.type )
			{
			case ListEvent.INDEX_CHANGE:
				PlayUDKSound( "MenuSounds", "ListIndexChanged" );
				break;
			case ListEvent.ITEM_CLICK:
				PlayUDKSound( "MenuSounds", "ListItemClicked" );
				break;
			default:
				break;
			}
		}
	}
}
