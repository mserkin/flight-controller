package ap.basic {
	
import flash.events.Event;

public class ObjectEvent extends Event
{
//public fields & consts		

	//public consts
	
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

	//property fields
	private var FSourceObject: Object;

	//other fields
	
//properties

	public function get SourceObject(): Object
	{
		return FSourceObject;
	}

//methods
	//constructor
	public function ObjectEvent(AType:String, AnObject:Object = null)
	{
		FSourceObject = AnObject;
		super(AType);
	}

	//public methods
	
	public override function clone():Event 
	{
		return new ObjectEvent(type, FSourceObject);
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
