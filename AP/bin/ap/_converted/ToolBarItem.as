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
	private var FGravity: Number = 0;
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
	
	public function get Gravity (): Number
	{
		return FGravity;
	}
	
	public function set Gravity (AValue: Number)
	{
		FGravity = AValue;
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
	public function ToolBarItem (ASize: Size, AnAlignment: int, AGravity: Number = 0, ANormalImage: Sprite = null, 
		APressedImage: Sprite = null)
	{
		super(new Point(), ASize);
		FGravity = AGravity;
		FAlignment = AnAlignment;
		spNormalImage = ANormalImage;
		spPressedImage = APressedImage;
	}		

	//public methods

	public function display(AnOffset: Point)
	{
		var rect: Rect = this.clone();
		rect.Location = rect.Location.add(AnOffset);
		var n_state: int  = displayHook();
		var sp_image: Sprite;
		if (n_state == 0) {
			sp_image = FPressed ? spPressedImage : spNormalImage;
		}
		else {
			sp_image = (n_state > 0) ? spPressedImage : spNormalImage;
		}
		
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
					onClickHook();
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
	//function returns 1 if the button should be displayed pressed
	//function returns -1 if the button should be displayed unpressed	
	//function returns 0 if makes no decision on that
	protected function displayHook(): int {return 0;}

	protected function onClickHook(){}
	
	
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
