package ap.instrumental {

import flash.events.EventDispatcher;
import flash.events.Event;
import ap.basic.ObjectEvent;
import ap.basic.SelectableObject;
import ap.model.Gate;

public class CustomDispatcher extends EventDispatcher 
{
//public fields & consts

	//public consts

	public static const BEFORE_RESCALE: String = "BeforeRescale";
	public static const ON_BOX_OPENED: String = "OnBoxOpened"; 
	public static const ON_GATE_LOADED:String = "OnGateLoaded";		
	public static const ON_HIDDEN: String = "OnHidden";
	public static const ON_HIDING: String = "OnHiding";	
	public static const ON_LANDED: String = "OnLanded";
	public static const ON_LEVEL_LOADED: String = "OnLevelLoaded";
	public static const ON_RESIZED: String = "OnResized";
	public static const ON_SHOWN: String = "OnShown";

	//public fields
	
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

	public function fireBeforeRescale():void {
		dispatchEvent(new Event(CustomDispatcher.BEFORE_RESCALE));
	}

	public function fireOnBoxOpened(ABoxNumber: int):void {
		dispatchEvent(new ObjectEvent(ON_BOX_OPENED, {BoxNumber: ABoxNumber}));
	}	
	
	public function fireOnGateLoaded(AGate: Gate):void {
		dispatchEvent(new ObjectEvent(ON_GATE_LOADED, AGate));
	}

	public function fireOnHidden():void {
		dispatchEvent(new Event(CustomDispatcher.ON_HIDDEN));
	}

	public function fireOnHiding():void {
		dispatchEvent(new Event(CustomDispatcher.ON_HIDING));
	}

	public function fireOnLanded(ASourceObj: SelectableObject):void {
		dispatchEvent(new ObjectEvent(ON_LANDED, ASourceObj));
	}

	public function fireOnLevelLoaded():void {
		dispatchEvent(new Event(CustomDispatcher.ON_LEVEL_LOADED));
	}

	public function fireOnResized():void {
		dispatchEvent(new Event(CustomDispatcher.ON_RESIZED));
	}

	public function fireOnShown():void {
		dispatchEvent(new Event(CustomDispatcher.ON_SHOWN));
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