package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class ConfirmationDialog extends MovieClip
	{
		public static const TYPE_RETURN:int = 0;
		public static const TYPE_QUIT:int = 1;
		public static const TYPE_MENU:int = 2;
		
		public var text_title:TextField;
		public var text_sure:TextField;
		public var text_progress:TextField;
		public var mc_confirm_frame:MovieClip;
		
		public var type:int;
		
		private var pausing_player_controller_id:uint;
		
		
		
		// Constructor
		public function ConfirmationDialog( controller_id:uint, dialog_type:int )
		{
			switch( dialog_type )
			{
			case TYPE_RETURN:
				text_title.text = "Back to Map";
				break;
			case TYPE_MENU:
				text_title.text = "Back to Main Menu";
				break;
			case TYPE_QUIT:
			default:
				text_title.text = "Quit Game";
				break;
			}
			
			type = dialog_type;
			pausing_player_controller_id = controller_id;
		}
	}
}
