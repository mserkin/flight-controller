package ap.model {

///////////////////////////////////////////////////////////
//  Copter.as
///////////////////////////////////////////////////////////

import ap.basic.Angle;
import ap.basic.Point;
import ap.basic.Rect;
import ap.enumerations.AircraftState;
import ap.enumerations.AircraftType;

public class Copter extends Aircraft
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
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/

//methods
	//constructor
    public function Copter(AType: AircraftType, ALocation:Point, ACourse:Angle, AnAirportRect: Rect, AState:AircraftState, AFuelResidue: Number, AGate: Gate = null)
    {
		super(AType, ALocation, ACourse, AnAirportRect, AState, AFuelResidue, AGate);
		if (AGate) 
		{
			(AGate as Helipad).occupyToLand(this);
		}
    }

	//public methods

	/*public function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//protected methods
	protected override function declareLanded()
	{
		FState = AircraftState.PreparingToTakeoff;
		OnLanded.fireOnLanded(this);				
	}	
	
	protected override function getTargetCourse(): Angle
	{
		return Angle.direction(Location, TargetAirfield.Location, {});
	}

	protected override function navigateToAirfield(IsInLandingZone: Boolean, AWind: Wind): Boolean
	{
		nTurn = Course.getRotation(Angle.direction(Location, FTargetAirfield.Location, {}));
		return true;
	} 

	protected override function stayReadyToTakeoff(): Boolean
	{
		var is_ready: Boolean = super.stayReadyToTakeoff();
		if (is_ready)
		{
			FState = AircraftState.TakingOff;
		}
		return is_ready;
	}

	protected override function takeoff(AWind: Wind): void
	{
		dblAcceleration = (dblSpeed < FType.CruiseSpeed) ? FType.Acceleration : 0;
		super.takeoff(AWind);
	}	

	protected override function touchdown(AWind: Wind)
	{
		super.touchdown(AWind);
		stop();
		declareLanded();
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
