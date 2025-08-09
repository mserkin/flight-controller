package ap.model {
///////////////////////////////////////////////////////////
//  Aircraft.as
///////////////////////////////////////////////////////////

import flash.events.Event;
import ap.basic.Angle;
import ap.basic.Point;
import ap.basic.Points;
import ap.basic.PointsEventDispatcher;
import ap.basic.Rect;
import ap.basic.SelectableObject;
import ap.basic.Size;
import ap.enumerations.AircraftState;
import ap.enumerations.AircraftType;
import ap.input.Core;
import ap.instrumental.CustomDispatcher;
import ap.instrumental.Instruments;

public class Aircraft extends SelectableObject
{
//public fields & consts		

	//public consts
	public static const DBL_ARRIVAL_PERIOD: Number = 8; //sec
	public static const DBL_NORMAL_ALTITUDE: Number = 600; //m	
	
	//go around reasons
	public static const DBL_GA_CAUSE_NONE: int = 0;
	public static const DBL_GA_CAUSE_WIND: int = 1;
	public static const DBL_GA_CAUSE_CLOUDS: int = 2;	
	public static const DBL_GA_CAUSE_UNKNOWN: int = 3;
	
	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	public var OnLanded: CustomDispatcher = new CustomDispatcher();
	
//protected fields & consts

	//protected consts
	protected const DBL_ANG_COURSE: Number = Math.PI / 12; //ширина курса, deg
	protected const DBL_BRAKING: Number = -8; //m/s
	
	//protected fields
	//property fields

	protected var FAltitude: Number = 0;
	protected var FCollided: Boolean = false;
	protected var FIsOccupingAirfield: Boolean; 		
    protected var FIsTakeoffPending: Boolean; 
	protected var FOccupiedGate: Gate;		
    protected var FPath: Points;

	protected var FState: AircraftState;
    protected var FTargetAirfield: IAirfield;
	protected var FTimeToArrive: Number;
	protected var FType: AircraftType;
			
	//other protected fields
	protected var dblAcceleration: Number = 0;
	protected var dblFuel: Number = DBL_MAX_FUEL;
	protected var dblSpeed: Number = 0;	
	protected var dblVelocity: Number = 0;	
    protected var nTurn: int = 0;
	protected var nWaypointMissTicks: int = 0;
	protected var rectAirport: Rect;
	protected var xyWaypointDistance: Number = Number.MAX_VALUE;

//private fields & consts

	//private consts
	private const ANG_TURN_ADMIS_ERROR: Angle = new Angle(10, Angle.DEGREE); //deg
	private const DBL_AIRCRAFT_SIZE: Number = 750; //m
	private const DBL_BOUNCE_BOUND: Number = 1000; //m
	private const DBL_COLLISION_HOR_DISTANCE: Number = 300;
	private const DBL_COLLISION_VERT_DISTANCE: Number = 50;
	private const DBL_CRITICAL_DOWNWIND: Number = 20; //if more -> wind is considered is GA cause
	private const DBL_FLARE_ALTITUDE: Number = 30; //m	
	private const DBL_FUEL_CONSUMPTION: Number = 1; //secs of flight per second
	private const DBL_FUELING_RATE: Number = 5; //secs of flight per second
	private const DBL_LANDING_DESCENT: Number = -25; //m/s
	private const DBL_LANDING_DETERIORATION_IN_CLOUD: Number = 0.2;
	private const DBL_MAX_FUEL: Number = 768; //secs of flight
	private const DBL_TAKEOFF_CLIMB: Number = 50; //m/s
	private const DBL_WAYPOINT_REACH_DISTANCE: Number = 500; //m
	private const N_COURSE_CHECK_POINTS: int = 3; //количество точек, по которым контролируется попадание маршрута в подход
	private const N_CRITICAL_CLOUD_DENSITY: int = 80; //if more -> clouds are considered is GA cause
	private const N_GA_FRAMES: int = 100; //frames after ga, when ga cause is set
	private const N_MAX_WAYPOINT_MISS_TICKS: int = 32; //макс. кол-во тиков, при которых самолет летит мимо точки
	private const N_WAYPOINT_REACH_DEPTH: int = 5;

	//property fields
	private var FGoAroundCause: int = DBL_GA_CAUSE_NONE;

	//other fields
	private var dblMaxDownwindSpeed: Number = 0; 
	private var isFirstContact: Boolean = true;
	private var isFirstLossOfContact: Boolean = true;
	private var nCloudDensityCounter: int = 0; 
	private var nGoAroundFrameCounter: int = 0;

//properties

	public function get Altitude(): Number
    {
    	return FAltitude;
    }

	public function get Collided(): Boolean
    {
    	return FCollided;
    }
	
	public function get Fuel(): Number
    {
    	return dblFuel / DBL_MAX_FUEL;
    }

	public function get GoAroundCause(): int
    {
    	return FGoAroundCause;
    }
	
	public function get IsOccupingAirfield(): Boolean
    {
    	return FIsOccupingAirfield;
    }

	public function get IsTakeoffPending(): Boolean
    {
    	return FIsTakeoffPending;
    }

	public function get OccupiedGate(): Gate
    {
    	return FOccupiedGate;
    }
			
    public function get State(): AircraftState
    {
    	return FState;
    }

	public function get TargetAirfield(): IAirfield
	{
		return FTargetAirfield;
	}

	public function get TimeToArrive(): Number
	{
		return FTimeToArrive;
	}

    public function get Path(): Points
    {
    	return FPath;
    }
	
	public function set TargetAirfield(AnAirfield: IAirfield)
	{
		resetWaypointMissCounter();
		
		if (!FState.IsComing)
		{
			depart();
		}

		if (FTargetAirfield && (FTargetAirfield != AnAirfield))
		{
			freeAirfield();
		}
		FTargetAirfield = AnAirfield;			
		
		if (FState == AircraftState.Directed && !FTargetAirfield && FPath.Length == 0)
			FState = AircraftState.Undirected;
		else
			if (FState == AircraftState.Undirected)
				FState == AircraftState.Directed;
	}

    public function get Type(): AircraftType
    {
    	return FType;
    }
	
//methods
	//constructor

	public function Aircraft(AType: AircraftType, ALocation:Point, ACourse:Angle, AnAirportRect: Rect, AState:AircraftState, AFuelResidue: Number, AGate: Gate = null)
    {
		FType = AType;
		FPath = new Points();
		FPath.OnAdd.addEventListener(PointsEventDispatcher.ON_ADD, Points_OnAdd);
		FPath.OnRemove.addEventListener(PointsEventDispatcher.ON_REMOVE, Points_OnRemove);

		super(ALocation, new Size(DBL_AIRCRAFT_SIZE, DBL_AIRCRAFT_SIZE), ACourse);

		FState = AState;
		dblFuel = AFuelResidue * DBL_MAX_FUEL;
		rectAirport = AnAirportRect;
		FAltitude = (FState == AircraftState.PreparingToTakeoff) ? 0 : DBL_NORMAL_ALTITUDE;
		FTimeToArrive = (FState == AircraftState.Arriving) ? DBL_ARRIVAL_PERIOD : 0;
		dblSpeed = (FState == AircraftState.Undirected) ? FType.CruiseSpeed : 0;
		
		if (AGate != null)
			AGate.occupy();
		FOccupiedGate = AGate;
    }

	//public methods

	public function checkCollision(AnOtherAircraft: Aircraft, APrimaryCheck: Boolean = true): Boolean
	{
		if (Math.abs(this.Location.X - AnOtherAircraft.Location.X) <= DBL_COLLISION_HOR_DISTANCE
			&& Math.abs(this.Location.Y - AnOtherAircraft.Location.Y) <= DBL_COLLISION_HOR_DISTANCE
			&& Math.abs(this.Altitude - AnOtherAircraft.Altitude) <= DBL_COLLISION_VERT_DISTANCE
			&& Instruments.xor(this.Altitude == 0, AnOtherAircraft.Altitude != 0)
			)
		{
			FCollided= true;
			if (APrimaryCheck)
			{
				AnOtherAircraft.checkCollision(this, false);
			}
		}
		
		return FCollided;
	}

	public function depart(): void
	{
		if (FState == AircraftState.ReadyToTakeoff)
			FIsTakeoffPending = true;
		//дальнейшие действия по старту см. stayReadyToTakeoff()
	}

	public override function inArea(APoint:Point)
    {
		var point: Point = APoint.sub(Location);
		return point.Radius < DBL_AIRCRAFT_SIZE / 2;
	}

	public function move(AWind: Wind, ACloudDensity: int): void
	{
		if (nGoAroundFrameCounter > 0) 
			--nGoAroundFrameCounter;
		else
			FGoAroundCause = DBL_GA_CAUSE_NONE;
			
		control(AWind, ACloudDensity);
		calcSpeeds();
		calcLocation(AWind);
	}

	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		return str_indent + "[Aircraft]\n" 
			+ super.toString(AnIndent + 1) + "\n"
			+ str_indent_plus + "Altitude=" + FAltitude + "\n"
			+ str_indent_plus + "Collided=" + FCollided + "\n"
			+ str_indent_plus + "IsOccupingAirfield=" + FIsOccupingAirfield + "\n"
			+ str_indent_plus + "IsTakeoffPending=" + FIsTakeoffPending + "\n"
			+ str_indent_plus + "OccupiedGate=\n" 
			+ (FOccupiedGate ? FOccupiedGate.toString(AnIndent + 2) : "")
			+ str_indent_plus + "State=" + FState.toString(AnIndent + 2) + "\n"
			+ str_indent_plus + "TargetAirfield=\n" 
			+ (FTargetAirfield ? FTargetAirfield.toString(AnIndent + 2): "")
		+ str_indent + "}\n";	
	}

	//protected methods

	protected function approach(AWind: Wind, ACloudDensity: int)
	{
		//ускорение и набор затем могут быть переопределены в land(), который использует данный метод
		dblAcceleration = (dblSpeed > FType.TouchdownSpeed) ? FType.Deceleration: 0;
		dblVelocity = (FAltitude > DBL_FLARE_ALTITUDE) ? 
			(DBL_LANDING_DESCENT * (1 - DBL_LANDING_DETERIORATION_IN_CLOUD * ACloudDensity)) 
			: 0;
			
		dblMaxDownwindSpeed = Math.max(AWind.Direction.sub(Course).cos() * AWind.Speed, dblMaxDownwindSpeed);
		nCloudDensityCounter += ACloudDensity;
		
		var is_in_landing_zone: Boolean = FTargetAirfield.inLandingZone(this.Location);
		
		var to_continue_approach: Boolean = navigateToAirfield(is_in_landing_zone, AWind);
				
		if (to_continue_approach)
		{
			captureAirfield();
		}
		
		return to_continue_approach && is_in_landing_zone;
	}

	protected function brake(AWind: Wind): void
	{
		//сели, теперь нужно затормозить
		dblAcceleration = (dblSpeed > FType.TaxiingSpeed) ? DBL_BRAKING: 0;
		dblVelocity = (FAltitude > 0) ? DBL_LANDING_DESCENT : 0;
	}

	protected function control(AWind: Wind, ACloudDensity: int): Boolean
	{
		switch (FState)
		{
			case AircraftState.Arriving:
				arrive();
				break;

			case AircraftState.Undirected:
				flyUndirected();
				break;
				
			case AircraftState.Directed:
				flyDirected(AWind);
				break;

			case AircraftState.Approaching:
				approach(AWind, ACloudDensity);
				break;
				
			case AircraftState.Landing:
				land(AWind, ACloudDensity);	
				break;
							
			case AircraftState.PreparingToTakeoff:
				prepareToTakeoff()
				break;
				
			case AircraftState.ReadyToTakeoff:
				stayReadyToTakeoff();
				break;
				
			case AircraftState.TakingOff:
				takeoff(AWind);
				break;
				
			default: 
				nTurn = 0;
				return false;
		}
		
		return true;
	}

	protected function convertToGroundSpeed(ASpeed: Number, AWind: Wind)
	{
		return dblSpeed + Course.sub(AWind.Direction).cos() * AWind.Speed;	
	}

	protected function convertToInstrumentalSpeed(ASpeed: Number, AWind: Wind)
	{
		return dblSpeed - Course.sub(AWind.Direction).cos() * AWind.Speed;		
	}

	protected function declareLanded()
	{
		FTargetAirfield.free(this);
		FTargetAirfield = null;
		FState = AircraftState.PreparingToTakeoff;
		OnLanded.fireOnLanded(this);				
	}

	protected function examineGoAroundCause()
    {
		if (FState != AircraftState.Landing) return;
		
		if (dblMaxDownwindSpeed > DBL_CRITICAL_DOWNWIND)
			FGoAroundCause = DBL_GA_CAUSE_WIND;
		else if (nCloudDensityCounter > N_CRITICAL_CLOUD_DENSITY)
			FGoAroundCause = DBL_GA_CAUSE_CLOUDS;
		else
			FGoAroundCause = DBL_GA_CAUSE_UNKNOWN;
		trace("==============================");
		trace("dblFuel = " + dblFuel);
		trace("GA_CAUSE = " + FGoAroundCause);
		trace("FState = " + FState.StateName);
		trace("dblMaxDownwindSpeed = " + dblMaxDownwindSpeed);
		trace("nCloudDensityCounter = " + nCloudDensityCounter);
		nGoAroundFrameCounter = N_GA_FRAMES;
    }	

	protected function getTargetCourse(): Angle
	{
		return FTargetAirfield.Course;
	}

	protected function goAround(AWind: Wind): void
	{
		lossOfContact(AWind);
		freeAirfield();

		examineGoAroundCause();

		FState = AircraftState.Undirected;
	}

	protected function land(AWind: Wind, ACloudDensity: int): Boolean
	{
		//заход
		var is_over_airfield: Boolean = approach(AWind, ACloudDensity);
		
		//если мы уже над полосой
		if (is_over_airfield && FOccupiedGate != null)
		{
			nTurn = Course.getRotation(FTargetAirfield.ActiveCourse);
			
			if (FAltitude <= 0)
			{
				if (isFirstContact) 
				{
					touchdown(AWind);
				}
				return true;
			}
			else
			{
				//садимся							
				dblAcceleration = (dblSpeed > FType.TouchdownSpeed) ? FType.Deceleration: 0;
				dblVelocity = (FAltitude > 0) ? DBL_LANDING_DESCENT : 0;
			}
		}
		return false;
	}

	protected function lossOfContact(AWind: Wind)
	{
		isFirstContact = true;
		isFirstLossOfContact = false;
	}
	
	protected function navigateToAirfield(IsInLandingZone: Boolean, AWind: Wind): Boolean
	{
		return true;
	}

	protected function stayReadyToTakeoff(): Boolean
	{
		nTurn = 0;
		dblAcceleration = 0;
		if (FIsTakeoffPending)
		{
			//если полоса для старта не опеределена берем свободную в текущий момент
			var airfield: IAirfield = FTargetAirfield ? FTargetAirfield : FOccupiedGate.HostingAirfield;
			FIsOccupingAirfield = airfield.occupyToTakeoff(this);
			if (FIsOccupingAirfield)
			{
				FTargetAirfield = airfield;
				FState = AircraftState.TaxiingToAirfield;
				FOccupiedGate.free(this);
				FOccupiedGate = null;
				return true;
			}
		}
		return false;
	}

	protected function stop()
	{
		dblSpeed = 0;
		dblAcceleration = 0;
		nTurn = 0;
	}

	protected function takeoff(AWind: Wind): void
	{
		if (isFirstLossOfContact)
		{
			lossOfContact(AWind) //hook
		}
		
		dblVelocity = DBL_TAKEOFF_CLIMB;
		if (FTargetAirfield != null)
		{
			FTargetAirfield.free(this);
			FIsOccupingAirfield = false;				
			FTargetAirfield.Selected = false;
			FTargetAirfield = null;
			this.Selected = false;
		}
	}	
	
	protected function touchdown(AWind: Wind) 
	{
		FAltitude = 0;
		dblVelocity = 0;
		isFirstContact = false;
		isFirstLossOfContact = true;
	}
	
	//private methods

	private function arrive(): void
	{
		FTimeToArrive -= 1 / Core.N_FRAME_RATE;
		if (FTimeToArrive <= 0)
		{
			FState = AircraftState.Undirected;
			dblSpeed = FType.CruiseSpeed;
		}
	}

	private function calcLocation(AWind: Wind): void
	{
		//calc altitude
		FAltitude += dblVelocity / Core.N_FRAME_RATE;
		if (FAltitude < 0)
		{
			FAltitude = 0; 
			if (FState.IsComing && (!FTargetAirfield || !FTargetAirfield.inArea(Location)))
			{
					FCollided = true;
			}
		}

		//calc course
		Course.Radian += FType.TurnAngle.Radian * nTurn / Core.N_FRAME_RATE * ((Altitude == 0) ? 3 : 1);
		
		//calc position
		var x: Number = Course.sin() * dblSpeed / Core.N_FRAME_RATE;
		var y: Number = -Course.cos() * dblSpeed / Core.N_FRAME_RATE;
		
		if (FAltitude > 0)
		{
			x += AWind.Direction.sin() * AWind.Speed / Core.N_FRAME_RATE;
			y += -AWind.Direction.cos() * AWind.Speed / Core.N_FRAME_RATE;
		}
		
		Location.X += x;
		Location.Y += y;		
	}

	private function calcSpeeds(): void
	{
		dblSpeed += dblAcceleration / Core.N_FRAME_RATE;

		if (FState.IsComing && dblVelocity >= 0 && dblAcceleration >= 0) 
		{
			dblFuel -= DBL_FUEL_CONSUMPTION / Core.N_FRAME_RATE;
			if (dblFuel < 0)
			{
				dblFuel = 0;
			}
		}
		if (dblSpeed < 0) dblSpeed = 0;
		if (dblFuel == 0) dblVelocity = DBL_LANDING_DESCENT;
	}

	private function captureAirfield(): void
	{
		if (FTargetAirfield != null && !FIsOccupingAirfield)
		{
			FOccupiedGate = FTargetAirfield.occupyToLand(this);
			if (FOccupiedGate != null)
			{
				FIsOccupingAirfield = true;
				FPath.removeAll();
				FState = AircraftState.Landing;
			}
			else
				FIsOccupingAirfield = false;	
		}
	}

	private function checkNextWaypointAccessibility()
	{
		var pnt_dist: Point = this.Location.sub(FPath.get(0));
		var xy_dist: Number = Math.abs(pnt_dist.X) + Math.abs(pnt_dist.Y);
		if (xy_dist <= xyWaypointDistance) 
		{
			xyWaypointDistance = xy_dist;
			nWaypointMissTicks = 0;
			return false;
		}
		else
			return ++nWaypointMissTicks > N_MAX_WAYPOINT_MISS_TICKS;
	}

	private function flyDirected(AWind: Wind): void
	{
		dblAcceleration = (dblSpeed < FType.CruiseSpeed) ? FType.Acceleration: 0;
		dblVelocity = (FAltitude < DBL_NORMAL_ALTITUDE) ? DBL_TAKEOFF_CLIMB : 0;	
		if (FPath.Length > 0) //Выясняем, достижима ли текущая маршрутная точка
		{
			if (checkNextWaypointAccessibility())
			{
				FPath.shift();
				resetWaypointMissCounter();
			}
			
			manageReachedWaypoints();
		}
		if (isReadyToApproach()) //Проверяем возможность захода
		{
			FState = AircraftState.Approaching;
			dblMaxDownwindSpeed = 0; 
			nCloudDensityCounter = 0; 
			FPath.removeAll();
			return;
		}
		else 
			if (FTargetAirfield && FPath.Length == 0)
				goAround(AWind);
				
		if (FPath.Length == 0) //Если точек нет и нет ВПП, то переходим в ненаправленный режим
		{
			if (!FTargetAirfield)
			{
				FState = AircraftState.Undirected;
				return;
			}
		}
		else
		{
			var ang_target: Angle = Angle.direction(this.Location, Point(FPath.get(0)), {});			
			var ang_diff: Angle = ang_target.sub(Course);
			//turn to waypoint
			nTurn = (Math.abs(ang_diff.Radian) < ANG_TURN_ADMIS_ERROR.Radian) ? 0 : Instruments.sign(ang_diff.Radian);
		}
	}

	private function flyUndirected(): void
	{
		if (Location.X - rectAirport.Location.X < DBL_BOUNCE_BOUND)
		{
			if (Course.Radian >= -Math.PI/2 && Course.Radian < Math.PI/2)
				nTurn = 1;
			else if (Course.Radian < -Math.PI/2 || Course.Radian > Math.PI/2)
					nTurn = -1;
		}
		else if (rectAirport.Location.X + rectAirport.Extent.Width - Location.X < DBL_BOUNCE_BOUND)
		{
			if (Course.Radian < Math.PI/2 && Course.Radian > -Math.PI/2)
				nTurn = -1;
			else if (Course.Radian > Math.PI/2 || Course.Radian < -Math.PI/2)
				nTurn = 1;
		}						
		else if (Location.Y - rectAirport.Location.Y < DBL_BOUNCE_BOUND)
		{
			if (Course.Radian < 0)
				nTurn = -1;
			else if (Course.Radian > 0)
				nTurn = 1;
		}				
		else if (rectAirport.Location.Y + rectAirport.Extent.Height - Location.Y < DBL_BOUNCE_BOUND)
		{
			if (Course.Radian < 0)
				nTurn = 1;
			else if (Course.Radian > 0)
				nTurn = -1;
		}						
		else 
			nTurn = 0;
			
		dblAcceleration = (dblSpeed < FType.CruiseSpeed) ? FType.Acceleration : 0;
		dblVelocity = (FAltitude < DBL_NORMAL_ALTITUDE) ? DBL_TAKEOFF_CLIMB : 0;
	}

	private function freeAirfield()
	{
		if (FIsOccupingAirfield) 
		{
			FTargetAirfield.free(this);
			if (FOccupiedGate != null)
			{
				FOccupiedGate.free(this);
				FOccupiedGate = null;
			}
			FIsOccupingAirfield = false;
		}
		if (FTargetAirfield != null)
		{
			FTargetAirfield.Selected = false;
			FTargetAirfield = null;
		}
	}
			
	private function isOnCourse(AWaypoint: Point, ATargetCourse: Angle):Boolean
	{
		var o_dist: Object = {Distance: 0.0};
		var ang_target: Angle = Angle.direction(AWaypoint, FTargetAirfield.Location, o_dist);
		var ang_diff: Angle = ang_target.sub(ATargetCourse);
		return Math.abs(ang_diff.Radian) < DBL_ANG_COURSE / 2 || Math.abs(Math.abs(ang_diff.Radian) - Math.PI) < DBL_ANG_COURSE/ 2;
	}

	private function isReadyToApproach()
	{
		//Если не задана ВПП - заход делать некуда
		if (!FTargetAirfield || FPath.Length == 0) return false;
		
		//проверяем, не можем ли мы сделать заход
		var n_step: int = Math.floor(FPath.Length / N_COURSE_CHECK_POINTS);
		var is_on_course: Boolean = true;
		var ang_course: Angle = getTargetCourse();
  		for (var i: int = 0; is_on_course && i < N_COURSE_CHECK_POINTS; i++)
		{
			is_on_course &&= isOnCourse(Point(FPath.get(i * n_step)), ang_course);
		}
		
		return is_on_course; 
	}

	private function manageReachedWaypoints()
	{
		for (var i = Math.min(FPath.Length - 1, N_WAYPOINT_REACH_DEPTH); i >= 0; i--)
		{
			if (waypointReached(FPath.get(i)))
			{
				FPath.removeAt(0, i + 1);
				resetWaypointMissCounter();
				break;
			}
		}
	}

	private function prepareToTakeoff(): void
	{
		if (dblFuel < DBL_MAX_FUEL)
			dblFuel += DBL_FUELING_RATE / Core.N_FRAME_RATE;
		else
		{
			dblFuel = DBL_MAX_FUEL;
			FIsTakeoffPending = false;
			FState = AircraftState.ReadyToTakeoff;
		}
	}

	private function resetWaypointMissCounter()
	{
		nWaypointMissTicks = 0;
		xyWaypointDistance = Number.MAX_VALUE;					
	}
		
	private function waypointReached(waypoint: Point)
	{
		return (Math.abs(waypoint.X - this.Location.X) < DBL_WAYPOINT_REACH_DISTANCE 
			&& Math.abs(waypoint.Y - this.Location.Y) < DBL_WAYPOINT_REACH_DISTANCE);

	}

	//event handlers
	private function Points_OnAdd(AnEvent: Event):void 
	{
		//trace("    On add waypoint:");
		if (FTargetAirfield || FPath.Length > 0)
		{
			resetWaypointMissCounter();
			FState = AircraftState.Directed;
			//trace("        Aircraft state => Directed");
		}
	}

	private function Points_OnRemove(AnEvent: Event):void 
	{
		//trace("    On remove waypoint:");
		if (FState == AircraftState.Directed && !FTargetAirfield && FPath.Length == 0)
		{
			FState = AircraftState.Undirected;
			//trace("        Aircraft state => Undirected");			
		}
	}
}
}