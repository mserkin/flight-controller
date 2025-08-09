package ap.basic {

///////////////////////////////////////////////////////////
//  ToolBar.as
///////////////////////////////////////////////////////////

import flash.events.Event;
import flash.events.MouseEvent;

public class ToolBar extends Rect
{
//public fields & consts		

	//public consts
	static public const ALIGNMENT_LEFT: int = 0;
	static public const ALIGNMENT_CENTER: int = 1;
	static public const ALIGNMENT_RIGHT: int = 2;

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	/*<#OnDelphiStyle#>: CustomDispatcher = new CustomDispatcher();*/

//protected fields & consts

	//protected consts
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	private const DBL_HORIZONTAL_MARGIN = 1/10; //of toolbar width
	private const DBL_VERTICAL_MARGIN = 1/12; //of toolbar height

	//property fields
	private var atbiCenterAlignedItems: Vector.<ToolBarItem> = new Vector.<ToolBarItem>;
	private var atbiLeftAlignedItems: Vector.<ToolBarItem> = new Vector.<ToolBarItem>;
	private var atbiRightAlignedItems: Vector.<ToolBarItem> = new Vector.<ToolBarItem>;
	
	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/

//methods
	//constructor
	public function ToolBar (ALocation: Point = null, AnExtent: Size = null)
	{
		super(ALocation, AnExtent);
	}		

	//public methods

	public function addItem(AnItem: ToolBarItem)
	{
		switch(AnItem.Alignment)
		{
			case ALIGNMENT_LEFT: 
				atbiLeftAlignedItems.push(AnItem);
				break;
			case ALIGNMENT_CENTER:
				atbiCenterAlignedItems.push(AnItem);
				break;
			case ALIGNMENT_RIGHT: 
				atbiRightAlignedItems.push(AnItem);
				break;
		}
	}
	
	public function display()
	{
		arrangeItems();
		var tbi_item: ToolBarItem = null;
		for each(tbi_item in atbiLeftAlignedItems) tbi_item.display(Location);
		for each(tbi_item in atbiCenterAlignedItems) tbi_item.display(Location);
		for each(tbi_item in atbiRightAlignedItems) tbi_item.display(Location);
	}
	
	public function processEvent(AnEvent: Event): Boolean
	{
		if (AnEvent is MouseEvent)
		{
			var mouse_event: MouseEvent = MouseEvent(AnEvent);
			var pnt_screen: Point = new Point(mouse_event.stageX, mouse_event.stageY);
			if (!isInside(pnt_screen)) 
			{
				return false;
			}
			
			var str_event_type = mouse_event.type;
			var pnt_client: Point = pnt_screen.sub(Location);
			var tbi_item: ToolBarItem = null;
			for each(tbi_item in atbiLeftAlignedItems) tbi_item.processEvent(str_event_type, pnt_client);
			for each(tbi_item in atbiCenterAlignedItems) tbi_item.processEvent(str_event_type, pnt_client);
			for each(tbi_item in atbiRightAlignedItems) tbi_item.processEvent(str_event_type, pnt_client);
			return true;
		}
		return false;
	}	
	
	public function removeAllItems()
	{
		atbiCenterAlignedItems.length = 0;
		atbiLeftAlignedItems.length = 0;
		atbiRightAlignedItems.length = 0;
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods
	
	private function arrangeAlignedItems(AnAlignment: int, AnItemVector: Vector.<ToolBarItem>, 
		AMargin: Size, AnItemHeight: Number)
	{
		var dbl_total_width: Number = AMargin.Width;
		var dbl_bound: Number;
		var tbi_item: ToolBarItem;
		
		for (var i: int = 0; i < AnItemVector.length; i++)
		{
			tbi_item = AnItemVector[i];
			var dbl_width: Number = AnItemHeight/tbi_item.Extent.Height*tbi_item.Extent.Width;
			tbi_item.Location.Y = AMargin.Height;
			tbi_item.Extent.Width = dbl_width;
			tbi_item.Extent.Height = AnItemHeight;
			dbl_total_width += dbl_width + AMargin.Width;
		}
		
		switch (AnAlignment) {
			case ALIGNMENT_RIGHT:
				dbl_bound = Extent.Width - AMargin.Width;
				break;
			case ALIGNMENT_LEFT:
				dbl_bound = AMargin.Width;
				break;
			case ALIGNMENT_CENTER:
				dbl_bound = Extent.Width/2 - dbl_total_width/2 + AMargin.Width;
				break;
		}

		for (var n: int = 0; n < AnItemVector.length; n++)
		{
			tbi_item = AnItemVector[n];
			
			tbi_item.Location.X = dbl_bound - ((AnAlignment == ALIGNMENT_RIGHT) ? tbi_item.Extent.Width : 0);
			dbl_bound = tbi_item.Location.X + ((AnAlignment == ALIGNMENT_RIGHT) ? -AMargin.Width : tbi_item.Extent.Width + AMargin.Width); 
		}
	}
	
	private function arrangeItems()
	{
		var sz_margin: Size = new Size(Extent.Height*DBL_HORIZONTAL_MARGIN, Extent.Height*DBL_VERTICAL_MARGIN);
		var dbl_height: Number = Extent.Height*(1 - DBL_VERTICAL_MARGIN*2);
		
		arrangeAlignedItems(ALIGNMENT_LEFT, atbiLeftAlignedItems, sz_margin, dbl_height); 

		arrangeAlignedItems(ALIGNMENT_RIGHT, atbiRightAlignedItems, sz_margin, dbl_height); 
			
		arrangeAlignedItems(ALIGNMENT_CENTER, atbiCenterAlignedItems, sz_margin, dbl_height); 

	}

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
