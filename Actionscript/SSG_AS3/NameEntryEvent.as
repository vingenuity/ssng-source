package 
{
	import flash.events.Event;

	//Made with: http://projects.stroep.nl/EventGenerator/
	public class NameEntryEvent extends Event
	{
		public static const ENTRY_REJECTED:String = "EntryRejected";
		public static const ENTRY_ACCEPTED:String = "EntryAccepted";
		
		private var _name:String;
		
		
		// Constructor
		public function NameEntryEvent(type:String, name:String, bubbles:Boolean = false, cancelable:Boolean = false):void 
		{ 
			super(type, bubbles, cancelable);
			_name = name;
		}

		public function GetName():String
		{
			return _name;
		}

		public function Clone():Event 
		{ 
			return new NameEntryEvent(type, _name, bubbles, cancelable);
		} 

		public function ToString():String 
		{ 
			return formatToString("NameEntryEvent", "type", "name", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
