package ap.enumerations {
///////////////////////////////////////////////////////////
//  AircraftState.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments; 

public class AircraftState //enum
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

	//other protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	//state names, in order of state occurance
	static private const STATE_ARRIVING: String = "Arriving"; 						//подлетающие к аэродрому самолеты, но еще не вошедшие в его зону
	static private const STATE_UNDIRECTED: String = "Undirected"; 					//самолеты, маршрут для которых не задан
	static private const STATE_DIRECTED: String = "Directed";	 					//самолеты, летящие по маршруту
	static private const STATE_APPROACHING: String = "Approaching"; 				//самолеты, производящие заход
    static private const STATE_LANDING: String = "Landing";							//производящие посадку
    static private const STATE_TAXIING_TO_GATE: String = "TaxiingToGate";			//рулящие к гейту
	static private const STATE_PREPARING_TO_TAKEOFF: String = "PreparingToTakeoff";	//готовищиеся к взлету
    static private const STATE_READY_TO_TAKEOFF: String = "ReadyToTakeoff";			//готовые к взлету
    static private const STATE_TAXIING_TO_AIRFIELD: String = "TaxiingToAirfield";		//рулящие к ВВП
	static private const STATE_TAKING_OFF: String = "TakingOff";					//взлетающие и взлетевшие, покидающие аэродром

	//property fields
	//states, in order of occurance
	static private var FArriving: AircraftState = new AircraftState(STATE_ARRIVING); 				//подлетающие к аэродрому самолеты
	static private var FUndirected: AircraftState = new AircraftState(STATE_UNDIRECTED); 					//самолеты, маршрут для которых не задан
	static private var FDirected: AircraftState = new AircraftState(STATE_DIRECTED);	 					//самолеты, летящие по маршруту
    static private var FApproaching: AircraftState = new AircraftState(STATE_APPROACHING);				//самолеты, производящие заход
    static private var FLanding: AircraftState = new AircraftState(STATE_LANDING);						//производящие посадку
    static private var FTaxiingToGate: AircraftState = new AircraftState(STATE_TAXIING_TO_GATE);			//рулящие к гейту
	static private var FPreparingToTakeoff: AircraftState = new AircraftState(STATE_PREPARING_TO_TAKEOFF);//готовищиеся к взлету
    static private var FReadyToTakeoff: AircraftState = new AircraftState(STATE_READY_TO_TAKEOFF);		//готовые к взлету
    static private var FTaxiingToAirfield: AircraftState = new AircraftState(STATE_TAXIING_TO_AIRFIELD);		//рулящие к ВВП
	static private var FTakingOff: AircraftState = new AircraftState(STATE_TAKING_OFF);					//взлетающие и взлетевшие, покидающие аэродром
	private var FStateName: String;

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties
	//state properties, in order of occurence
	static public function get Arriving(): AircraftState
    {
    	return FArriving;
    }
	
	static public function get Undirected(): AircraftState
    {
    	return FUndirected;
    }

    static public function get Directed(): AircraftState
    {
    	return FDirected;
    }

    static public function get Approaching(): AircraftState
    {
    	return FApproaching;
    }

    static public function get Landing(): AircraftState
    {
    	return FLanding;
    }

    static public function get TaxiingToGate(): AircraftState
    {
    	return FTaxiingToGate;
    }

    static public function get PreparingToTakeoff(): AircraftState
    {
    	return FPreparingToTakeoff;
    }

    static public function get ReadyToTakeoff(): AircraftState
    {
		return FReadyToTakeoff;
    }

    static public function get TaxiingToAirfield(): AircraftState
    {
    	return FTaxiingToAirfield;
    }

	static public function get TakingOff(): AircraftState
    {
		return FTakingOff;
    }

	//other properties
	//является ли самолет в данном состоянии прибывающим. севшие самолеты уже прибыли, для них функция вернет false.
	public function get IsComing()
	{
		return this == Arriving || this == Directed || this == Undirected 
			|| this == Approaching || this == Landing;
	}	

	public function get StateName(): String
    {
		return FStateName;
	}

//methods
	//constructor
	public function AircraftState(AName: String)
	{
		FStateName = AName;
	}

	//public methods			
    public function toString(AnIndent: int = 0): String
    {
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		return str_indent + "[AircraftState]\n"
			+ str_indent + "{\n"
			+ str_indent_plus + "StateName=" + FStateName + "\n"
			+ str_indent + "}\n";
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