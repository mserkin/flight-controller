package ap.instrumental {

public class Profiler //static
{
//public fields & consts		

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

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

	//property fields
    /*private var FValue: Number = 0; */

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	static private var objWatches: Object = new Object();
	
//properties

	
//methods
	//constructor

	//public methods
	static public function checkin(AName: String)
    {
		if (!objWatches[AName])
			objWatches[AName] = {CheckinTime: new Date(), Watch: 0}
		else
		{
			var obj_watch = objWatches[AName];
			if ((obj_watch.CheckinTime as Date).getTime() == 0)
			{
				obj_watch.CheckinTime = new Date();
				//trace(">> " + AName + " checked in");
			}
			else
				trace("Reccurent checkin for " + AName);
		}
    }

    static public function checkout(AName: String)
    {
		if (objWatches[AName])
		{
			var obj_watch = objWatches[AName];
			if ((obj_watch.CheckinTime as Date).getTime() == 0)
				trace("Checkout without checkin for " + AName);
			else
			{
				var dt_time: Date = new Date();
				obj_watch.Watch += (dt_time.getTime() - obj_watch.CheckinTime.getTime());
				obj_watch.CheckinTime = new Date(0);
				//trace("<< " + AName + " checked out");
			}
		}
		else
			trace("Checkout without checkin for " + AName);
    }
	
	static public function getWatch(AName: String): String
	{
		var str_report: String = AName + " : ";
		if (!objWatches[AName]) 
			str_report += "not found."
		else
		{
			var obj_watch = objWatches[AName];
			str_report += obj_watch.Watch + "ms";
			if (obj_watch.CheckinTime.getTime() != 0)
				str_report += " and running";
		}
		return str_report;
	}
	
	static public function reset()
    {
		objWatches = {};
    }	

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	/*	
	private function normalize()
	{
	}
	*/

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}