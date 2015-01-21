package
{
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import scaleform.clik.controls.Label;
	
	public class SSG_SingleLineLabel extends Label
	{
		var initial_label_width:Number;
		var initial_label_height:Number;
		
		// Constructor
		public function SSG_SingleLineLabel()
		{
			super();
			
			initial_label_width = textField.width;
			initial_label_height = textField.height;
		}
		
		
		
		public function SetText( new_text:String )
		{
			textField.text = new_text;
			
			var format:TextFormat = textField.getTextFormat();
			
			while( textField.textWidth > initial_label_width || textField.textHeight > initial_label_height )
			{
				format.size = int( format.size ) - 1;
				textField.setTextFormat( format );
			}
		}
	}
}