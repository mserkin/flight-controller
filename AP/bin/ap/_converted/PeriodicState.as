package ap.basic  {

///////////////////////////////////////////////////////////
//  PeriodicState.as
///////////////////////////////////////////////////////////

//import <#Package#>;

public class PeriodicState
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
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	private var FCounter: int
	private var FIsUsed: Boolean
	private var FKeyObject: Object
	private var FPeriod: int

	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	internal function get IsUsed(): Boolean
	{
		return FIsUsed;
	}

	internal function get KeyObject(): Object
	{
		return FKeyObject;
	}

	internal function get Period(): int
	{
		return FPeriod;
	}

	internal function set Period(APeriod: int)
	{
		FPeriod = APeriod;
	}
		
//methods
	//constructor
	public function PeriodicState (AKeyObject: Object, APeriod: int)
	{
		FKeyObject = AKeyObject;
		FPeriod = APeriod;
		FCounter = -APeriod;
		FIsUsed = true;
	}

	//public methods	
	internal function getState(APeriod: int = 0)
	{
		FIsUsed = true;
		if (APeriod != -1) {
			FPeriod = APeriod;
		}
		if (FCounter > FPeriod || FCounter < -FPeriod) {
			FCounter = -FPeriod;
		}
			
		return FCounter > 0;
	}	
	
	internal function tick(): Boolean
	{
		if (++FCounter > FPeriod)
		{
			if (!FIsUsed) 
				return false;
			else
				FCounter = -FPeriod;
		}
		FIsUsed = false;
		return true;
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