package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import scaleform.clik.controls.ListItemRenderer;
    import scaleform.clik.data.ListData;
    import flash.text.TextFormat;
    import scaleform.clik.controls.CoreList;
	
	public class SSG_ScoreListItemRenderer extends ListItemRenderer
	{
    	public var text_label:TextField;
    	public var text_score:TextField;
    	public var text_gold:TextField;
    	public var text_g:TextField;
		
		
		// Constructor
		public function SSG_ScoreListItemRenderer()
		{
        	super();
		}
		
		public override function setData( data:Object ):void
		{
			this.data = data;
			text_label.text = data ? data.label : "";
			text_score.text = data ? data.score : "";
			text_gold.text = data ? data.gold : "";
			
			var isMultiplierData:Boolean = (text_gold.text.charAt(0) == 'x') || (text_gold.text.charAt(0) == 'X');
			var owningList:CoreList = owner as CoreList;
			
			if( text_gold.text.charAt(0) == '+' )
				text_gold.textColor = 0x00FF00;
			else if( text_gold.text.charAt(0) == '-' )
				text_gold.textColor = 0xFF0000;
			else
				text_gold.textColor = 0xFFD700;
				
			if( (index == owningList.dataProvider.length - 1) || isMultiplierData )
			{
				const LARGER_TEXT_SIZE = 20;
				var text_format:TextFormat = text_gold.getTextFormat();
				text_format.size = LARGER_TEXT_SIZE;
				text_gold.setTextFormat( text_format );
				
				text_format = text_g.getTextFormat();
				text_format.size = LARGER_TEXT_SIZE;
				text_g.setTextFormat( text_format );
			}
			
			text_gold.visible = ( text_gold.text != "null" );
			text_g.visible = ( (text_gold.text != "") && text_gold.visible && !isMultiplierData );
		}

		protected override function updateAfterStateChange():void
		{
			this.data = data;
			text_label.text = data ? data.label : "";
			text_score.text = data ? data.score : "";
			text_gold.text = data ? data.gold : "";
			
			var isMultiplierData:Boolean = (text_gold.text.charAt(0) == 'x') || (text_gold.text.charAt(0) == 'X');
			var owningList:CoreList = owner as CoreList;
			
			if( text_gold.text.charAt(0) == '+' )
				text_gold.textColor = 0x00FF00;
			else if( text_gold.text.charAt(0) == '-' )
				text_gold.textColor = 0xFF0000;
			else
				text_gold.textColor = 0xFFD700;
				
			if( (index == owningList.dataProvider.length - 1) || isMultiplierData )
			{
				const LARGER_TEXT_SIZE = 20;
				var text_format:TextFormat = text_gold.getTextFormat();
				text_format.size = LARGER_TEXT_SIZE;
				text_gold.setTextFormat( text_format );
				
				text_format = text_g.getTextFormat();
				text_format.size = LARGER_TEXT_SIZE;
				text_g.setTextFormat( text_format );
			}
			
			text_gold.visible = ( text_gold.text != "null" );
			text_g.visible = ( (text_gold.text != "") && text_gold.visible && !isMultiplierData );
		}
	}
}
