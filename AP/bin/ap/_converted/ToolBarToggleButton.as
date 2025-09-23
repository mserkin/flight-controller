package ap.basic {

///////////////////////////////////////////////////////////
//  ToolBarToggleButton.as
///////////////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.MouseEvent;
import ap.instrumental.ScreenManager;

public class ToolBarToggleButton extends ToolBarItem
{
//public fields & consts

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	public var OnToggle: ToolBarEventDispatcher = new ToolBarEventDispatcher();

//protected fields & consts

	//protected consts
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	private var FChecked: Boolean = false;
	
	//other fields

//properties


	public function get Checked (): Boolean
	{
		return FChecked;
	}
	
	public function set Checked (AValue: Boolean)
	{
		FChecked = AValue;
		OnToggle.fireOnToggle(this);		
	}
//methods
	//constructor
	public function ToolBarToggleButton (ASize: Size, AnAlignment: int, AGravity: Number = 0, ANormalImage: Sprite = null, 
		APressedImage: Sprite = null)
	{
		super(ASize, AnAlignment, AGravity, ANormalImage, APressedImage);
	}		

	//public methods

	public override function processEvent(AnEventType: String, ALocation: Point)
	{
		super.processEvent(AnEventType, ALocation);
	}
		
	//protected methods

	protected override function displayHook(): int {
		return FChecked ? 1 : 0;
	}	
	
	protected override function onClickHook(){
		FChecked = !FChecked;
		OnToggle.fireOnToggle(this);
	}

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
