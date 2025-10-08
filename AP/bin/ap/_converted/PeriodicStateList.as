package ap.basic  {

///////////////////////////////////////////////////////////
//  PeriodicStateList.as
///////////////////////////////////////////////////////////

//import ap.basic.PeriodicState;

public class PeriodicStateList
{
//public fields & consts		

	//public consts
	static public const STATE_OFF: Boolean = false; 
	static public const STATE_ON: Boolean = true;

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
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	private var apsStates: Vector.<PeriodicState> = null;

//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/

//methods
	//constructor
	public function PeriodicStateList ()
	{
		apsStates = new Vector.<PeriodicState>();
	}

	//public methods

	public function getState(AKeyObject: Object, APeriod: int = 0): Boolean
	{
		for each (var ps: PeriodicState in apsStates)
		{
			if (ps.KeyObject == AKeyObject)
			{
				return ps.getState(APeriod);
			}
		}
		apsStates.push(new PeriodicState(AKeyObject, APeriod));
		return STATE_OFF;
	}
	
	public function tick()
	{
		for (var i: int = apsStates.length - 1; i >= 0; i--) 
		{
			if (!apsStates[i].tick())
			{
				apsStates.splice(i, 1);
			}
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