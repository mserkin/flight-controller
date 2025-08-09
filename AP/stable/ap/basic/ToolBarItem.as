package ap.basic {

///////////////////////////////////////////////////////////
//  ToolBarItem.as
///////////////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.MouseEvent;
import ap.instrumental.ScreenManager;

public class ToolBarItem extends Rect
{
//public fields & consts

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	public var OnClick: ToolBarEventDispatcher = new ToolBarEventDispatcher();
	public var OnPressed: ToolBarEventDispatcher = new ToolBarEventDispatcher();
	public var OnReleased: ToolBarEventDispatcher = new ToolBarEventDispatcher();
	public var OnPaint: ToolBarEventDispatcher = new ToolBarEventDispatcher();
//protected fields & consts

	//protected consts
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	private var FAlignment: int
	private var FPressed: Boolean = false;
	
	//other fields
	private var spNormalImage: Sprite;
	private var spPressedImage: Sprite;

//properties

	public function get Alignment (): int
	{
		return FAlignment;
	}

	public function set Alignment (AnAlignment: int)
	{
		FAlignment = AnAlignment;
	}
	
	public function get Pressed (): Boolean
	{
		return FPressed;
	}
	
	public function set Pressed (AValue: Boolean)
	{
		FPressed = AValue;
	}
//methods
	//constructor
	public function ToolBarItem (ASize: Size, AnAlignment: int, ANormalImage: Sprite = null, 
		APressedImage: Sprite = null)
	{
		super(new Point(), ASize);
		FAlignment = AnAlignment;
		spNormalImage = ANormalImage;
		spPressedImage = APressedImage;
	}		

	//public methods

	public function display(AnOffset: Point)
	{
		var rect: Rect = this.clone();
		rect.Location = rect.Location.add(AnOffset);
		var sp_image = FPressed ? spPressedImage : spNormalImage;
		if (sp_image)
		{
			ScreenManager.displayImage(sp_image, rect);
		}
		else
		{
			OnPaint.fireOnPaint(this);
		}
	}

	public function processEvent(AnEventType: String, ALocation: Point)
	{
		switch(AnEventType) {
			case MouseEvent.CLICK:
				if (isInside(ALocation))
				{
					OnClick.fireOnClick(this);
				}
				break;
			case MouseEvent.MOUSE_UP:
				if (FPressed)
				{
					FPressed = false;
					OnReleased.fireOnReleased(this)
				}
				break;
			case MouseEvent.MOUSE_DOWN:
				if (isInside(ALocation))
				{
					FPressed = true;
					OnPressed.fireOnPressed(this);
				}
				break;
		}
	}
		
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	/* private function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
