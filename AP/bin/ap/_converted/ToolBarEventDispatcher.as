package ap.basic {
import flash.events.EventDispatcher;
import flash.events.Event;

public class ToolBarEventDispatcher extends EventDispatcher 
{
//public fields & consts		

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	public static var ON_CLICK:String = "OnClick";		
	public static var ON_PAINT:String = "OnPaint";
	public static var ON_PRESSED:String = "OnPressed";
	public static var ON_RELEASED:String = "OnReleased";
	public static var ON_TOGGLE:String = "OnToggle";	
	//events
	/*<#OnDelphiStyle#>: CustomDispatcher = new CustomDispatcher();*/

//protected fields & consts

	//protected consts
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#FDelphiStyle#>: <#Type#>,*/

	//other protected fields
	/*protected var <#FDelphiStyle#>: <#Type#>;*/
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//methods
	//constructor
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods
	
	public function fireOnClick(ASource: Object):void {
		dispatchEvent(new ObjectEvent(ON_CLICK, ASource));
	}

	public function fireOnPaint(ASource: Object):void {
		dispatchEvent(new ObjectEvent(ON_PAINT, ASource));
	}

	public function fireOnPressed(ASource: Object):void {
		dispatchEvent(new ObjectEvent(ON_PRESSED, ASource));
	}

	public function fireOnReleased(ASource: Object):void {
		dispatchEvent(new ObjectEvent(ON_RELEASED, ASource));
	}

	public function fireOnToggle(ASource: Object):void {
		dispatchEvent(new ObjectEvent(ON_TOGGLE, ASource));
	}

	//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/

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