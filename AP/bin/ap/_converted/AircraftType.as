package ap.enumerations {
///////////////////////////////////////////////////////////
//  AircraftType.as
///////////////////////////////////////////////////////////

import ap.basic.Angle; 

public class AircraftType //enum
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
	//маневренность in order of cruise speed
	private const ANG_TURN_ANGLE_COPTER: Angle = new Angle(32, Angle.DEGREE); //deg  	
	private const ANG_TURN_ANGLE_PROP: Angle = new Angle(16, Angle.DEGREE); //deg  
	private const ANG_TURN_ANGLE_LINER: Angle = new Angle(16, Angle.DEGREE); //deg  	
	private const ANG_TURN_ANGLE_SUPER: Angle = new Angle(16, Angle.DEGREE); //deg  	
	//разгон in order of cruise speed
	private const DBL_ACCELERATION_COPTER: Number = 6; //m/s	
	private const DBL_ACCELERATION_PROP: Number = 8; //m/s	
	private const DBL_ACCELERATION_LINER: Number = 10; //m/s	
	private const DBL_ACCELERATION_SUPER: Number = 12; //m/s		
	//скорость подхода in order of cruise speed
	private const DBL_CRUISE_SPEED_COPTER: Number = 220; //m/s 
	private const DBL_CRUISE_SPEED_PROP: Number = 270; //m/s 
	private const DBL_CRUISE_SPEED_LINER: Number = 320; //m/s 
	private const DBL_CRUISE_SPEED_SUPER: Number = 360; //m/s 	
	//замедление in order of cruise speed
	private const DBL_DECELERATION_COPTER: Number = -5; //m/s	
	private const DBL_DECELERATION_PROP: Number = -6; //m/s	
	private const DBL_DECELERATION_LINER: Number = -7; //m/s	
	private const DBL_DECELERATION_SUPER: Number = -8; //m/s		
	//скорость для отрыва in order of cruise speed
	private const DBL_LIFTOFF_SPEED_COPTER: Number = 100; //m/s	
	private const DBL_LIFTOFF_SPEED_PROP: Number = 230; //m/s	
	private const DBL_LIFTOFF_SPEED_LINER: Number = 280; //m/s	
	private const DBL_LIFTOFF_SPEED_SUPER: Number = 330; //m/s			
	//скорость руления in order of cruise speed
	private const DBL_TAXIING_SPEED_COPTER: Number = 120; //m/s	
	private const DBL_TAXIING_SPEED_PROP: Number = 140; //m/s	
	private const DBL_TAXIING_SPEED_LINER: Number = 150; //m/s	
	private const DBL_TAXIING_SPEED_SUPER: Number = 160; //m/s		
	//скорость при касании in order of cruise speed
	private const DBL_TOUCHDOWN_SPEED_COPTER: Number = 100; //m/s	
	private const DBL_TOUCHDOWN_SPEED_PROP: Number = 200; //m/s	
	private const DBL_TOUCHDOWN_SPEED_LINER: Number = 250; //m/s	
	private const DBL_TOUCHDOWN_SPEED_SUPER: Number = 300; //m/s		
	//разбег (зависимые константы) 
	private const DBL_ROLL_RESERVE: Number = 300; //m
	private const DBL_TO_ROLL_LENGTH_COPTER: Number = (DBL_LIFTOFF_SPEED_COPTER - DBL_TAXIING_SPEED_COPTER) / DBL_ACCELERATION_COPTER 
		* (DBL_LIFTOFF_SPEED_COPTER + DBL_TAXIING_SPEED_COPTER) / 2 + DBL_ROLL_RESERVE; //m 	
	private const DBL_TO_ROLL_LENGTH_PROP: Number = (DBL_LIFTOFF_SPEED_PROP - DBL_TAXIING_SPEED_PROP) / DBL_ACCELERATION_PROP 
		* (DBL_LIFTOFF_SPEED_PROP + DBL_TAXIING_SPEED_PROP) / 2 + DBL_ROLL_RESERVE; //m 	
	private const DBL_TO_ROLL_LENGTH_LINER: Number = (DBL_LIFTOFF_SPEED_LINER - DBL_TAXIING_SPEED_LINER) / DBL_ACCELERATION_LINER 
		* (DBL_LIFTOFF_SPEED_LINER + DBL_TAXIING_SPEED_LINER) / 2 + DBL_ROLL_RESERVE; //m 	
	private const DBL_TO_ROLL_LENGTH_SUPER: Number = (DBL_LIFTOFF_SPEED_SUPER - DBL_TAXIING_SPEED_SUPER) / DBL_ACCELERATION_SUPER 
		* (DBL_LIFTOFF_SPEED_SUPER + DBL_TAXIING_SPEED_SUPER) / 2 + DBL_ROLL_RESERVE; //m 		
	//пробег  in order of cruise speed
	private const DBL_LAND_ROLL_LENGTH_COPTER: Number = 1500; //m	
	private const DBL_LAND_ROLL_LENGTH_PROP: Number = 2000; //m	
	private const DBL_LAND_ROLL_LENGTH_LINER: Number = 3500; //m/s	
	private const DBL_LAND_ROLL_LENGTH_SUPER: Number = 5500; //m/s		
	
	//names in order of cruise speed
	static private const TYPE_COPTER: String = "Copter";
	static private const TYPE_PROPELLER: String = "Propeller";
	static private const TYPE_LINER: String = "Liner";
	static private const TYPE_SUPERSONIC: String = "Supersonic";

	//property fields
	//aircraft types  in order of cruise speed
	static private var FCopter: AircraftType = new AircraftType(TYPE_COPTER);
	static private var FLiner: AircraftType = new AircraftType(TYPE_LINER);
	static private var FPropeller: AircraftType = new AircraftType(TYPE_PROPELLER);	
	static private var FSupersonic: AircraftType = new AircraftType(TYPE_SUPERSONIC);
	
	private var FAcceleration: Number;
	private var FCruiseSpeed: Number;
	private var FDeceleration: Number;
	private var FLandingRollLength: Number;
	private var FLiftoffSpeed: Number;
	private var FTakeoffRollLength: Number;
	private var FTaxiingSpeed: Number;
	private var FTouchdownSpeed: Number;
	private var FTurnAngle: Angle;
	private var FTypeName: String;

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties
	//state properties, in order of occurence
	public function get Acceleration(): Number
    {
    	return FAcceleration;
    }

	static public function get Copter(): AircraftType
    {
    	return FCopter;
    }
	
	public function get CruiseSpeed(): Number
    {
    	return FCruiseSpeed;
    }
	
	public function get Deceleration(): Number
    {
    	return FDeceleration;
    }

	public function get LandingRollLength(): Number
    {
    	return FLandingRollLength;
    }

	public function get LiftoffSpeed(): Number
    {
    	return FLiftoffSpeed;
    }
	
	static public function get Liner(): AircraftType
    {
    	return FLiner;
    }

	static public function get Propeller(): AircraftType
    {
    	return FPropeller;
    }
	
    static public function get Supersonic(): AircraftType
    {
    	return FSupersonic;
    }
	
	public function get TakeoffRollLength(): Number
    {
    	return FTakeoffRollLength;
    }

	public function get TaxiingSpeed(): Number
    {
    	return FTaxiingSpeed;
    }
	
	public function get TouchdownSpeed(): Number
    {
    	return FTouchdownSpeed;
    }

	public function get TurnAngle(): Angle
    {
    	return FTurnAngle;
    }

	//other properties
	public function get TypeName(): String
    {
		return FTypeName;
	}

//methods
	//constructor
	public function AircraftType(AName: String)
	{
		FTypeName = AName;
		switch(AName)
		{
			case TYPE_COPTER:
				FAcceleration = DBL_ACCELERATION_COPTER;
				FCruiseSpeed = DBL_CRUISE_SPEED_COPTER;
				FDeceleration = DBL_DECELERATION_COPTER;
				FLandingRollLength = DBL_LAND_ROLL_LENGTH_COPTER;
				FLiftoffSpeed = DBL_LIFTOFF_SPEED_COPTER;
				FTakeoffRollLength = DBL_TO_ROLL_LENGTH_COPTER;
				FTaxiingSpeed = DBL_TAXIING_SPEED_COPTER;
				FTouchdownSpeed = DBL_TOUCHDOWN_SPEED_COPTER;
				FTurnAngle = ANG_TURN_ANGLE_COPTER;				
				break;
		case TYPE_PROPELLER:
				FAcceleration = DBL_ACCELERATION_PROP;
				FCruiseSpeed = DBL_CRUISE_SPEED_PROP;
				FDeceleration = DBL_DECELERATION_PROP;
				FLandingRollLength = DBL_LAND_ROLL_LENGTH_PROP;
				FLiftoffSpeed = DBL_LIFTOFF_SPEED_PROP;
				FTakeoffRollLength = DBL_TO_ROLL_LENGTH_PROP;
				FTaxiingSpeed = DBL_TAXIING_SPEED_PROP;
				FTouchdownSpeed = DBL_TOUCHDOWN_SPEED_PROP;
				FTurnAngle = ANG_TURN_ANGLE_PROP;				
				break;
			case TYPE_LINER:
				FAcceleration = DBL_ACCELERATION_LINER;
				FCruiseSpeed = DBL_CRUISE_SPEED_LINER;
				FDeceleration = DBL_DECELERATION_LINER;				
				FLandingRollLength = DBL_LAND_ROLL_LENGTH_LINER;
				FLiftoffSpeed = DBL_LIFTOFF_SPEED_LINER;
				FTakeoffRollLength = DBL_TO_ROLL_LENGTH_LINER;
				FTaxiingSpeed = DBL_TAXIING_SPEED_LINER;
				FTouchdownSpeed = DBL_TOUCHDOWN_SPEED_LINER;
				FTurnAngle = ANG_TURN_ANGLE_LINER;
				break;			
			case TYPE_SUPERSONIC:
				FAcceleration = DBL_ACCELERATION_SUPER;
				FCruiseSpeed = DBL_CRUISE_SPEED_SUPER;
				FDeceleration = DBL_DECELERATION_SUPER;				
				FLandingRollLength = DBL_LAND_ROLL_LENGTH_SUPER;
				FLiftoffSpeed = DBL_LIFTOFF_SPEED_SUPER;
				FTakeoffRollLength = DBL_TO_ROLL_LENGTH_SUPER;				
				FTaxiingSpeed = DBL_TAXIING_SPEED_SUPER;
				FTouchdownSpeed = DBL_TOUCHDOWN_SPEED_SUPER;			
				FTurnAngle = ANG_TURN_ANGLE_SUPER;				
				break;
		}
	}

	//public methods

    public function toString(): String
    {
		return "{\n[AircraftType]\n  TypeName=" + FTypeName + "\n}";
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