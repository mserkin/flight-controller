package ap.basic {
import flash.events.EventDispatcher;
import flash.events.Event;

public class PointsEventDispatcher extends EventDispatcher 
{
//public fields & consts		

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	public static var ON_ADD:String = "OnAdd";		
	public static var ON_REMOVE:String = "OnRemove";
	
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
	
	public function fireOnAdd():void {
		//trace("OnAdd");
		dispatchEvent(new Event(PointsEventDispatcher.ON_ADD));
	}
	
	public function fireOnRemove():void {
		//trace("OnRemove");		
		dispatchEvent(new Event(PointsEventDispatcher.ON_REMOVE));
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