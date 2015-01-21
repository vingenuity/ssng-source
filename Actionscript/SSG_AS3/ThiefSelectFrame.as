package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.controls.ScrollingList;
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	
	public class ThiefSelectFrame extends MovieClip
	{
		public var text_select_thief:TextField;
		public var mc_thief_selection_list:ScrollingList;
		
		private var internal_thief_list:Array;
		
		// Constructor
		public function ThiefSelectFrame()
		{
			
			mc_thief_selection_list.addEventListener( ListEvent.ITEM_CLICK, BubbleOutItemClickEvent );
		}
		
		
		//---------------------------------------------------------------------------------------------------
		public function AddNewThief( thief_name:String )
		{
			trace( "Adding thief" );
			internal_thief_list.push( thief_name );
			var thief_data_provider:DataProvider = new DataProvider( internal_thief_list );
			
			mc_thief_selection_list.dataProvider = thief_data_provider;
			mc_thief_selection_list.selectedIndex = internal_thief_list.length - 1;
		}
		
		//---------------------------------------------------------------------------------------------------
		public function BubbleOutItemClickEvent( list_event:ListEvent )
		{
			dispatchEvent( list_event );
		}
		
		//---------------------------------------------------------------------------------------------------
		public function PopulateThiefList( thief_list_data:Array )
		{
			internal_thief_list = new Array();
			internal_thief_list.unshift( "New Thief" );
			for( var i:Number = 0; i < thief_list_data.length;  ++i )
			{
				internal_thief_list.push( thief_list_data[ i ].ThiefName );
			}
			
			var thief_data_provider:DataProvider = new DataProvider( internal_thief_list );
			
			mc_thief_selection_list.dataProvider = thief_data_provider;
			mc_thief_selection_list.selectedIndex = 0;
		}
	}
}
