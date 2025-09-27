package ap.model {
///////////////////////////////////////////////////////////
//  Plane.as
/////////////////////////////////////////////////////////// 

import flash.events.Event;
import ap.basic.Angle;
import ap.basic.Point;
import ap.basic.Rect;
import ap.enumerations.AircraftState;
import ap.enumerations.AircraftType;

public class Plane extends Aircraft
{
//public fields & consts		

	//public consts
	public static const DBL_NORMAL_ALTITUDE: Number = 600; //m	

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	
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
	private const DBL_ALLOWABLE_APPROACH_ERROR: Number = Math.PI / 9; //rad
	private const DBL_ALLOWABLE_CENTERLINE_ERROR: Number = 200; //m
	private const DBL_ALLOWABLE_GATE_STOP_ERROR: Number = 150; //m
	private const DBL_ALLOWABLE_TURN_ERROR: Number = Math.PI / 18; //rad	
	private const DBL_COURSE_ERROR_DISTANCE: Number = 500; //m	

	//-подрежимы руления
	private const N_TAXI_SUBMODE_ENTRY: int = 0; 	//выезд на ВПП,
	private const N_TAXI_SUBMODE_DOWNWIND: int = 1; //движение по ВВП в сторону, обратную курсу
	private const N_TAXI_SUBMODE_U_TURN: int = 2;	//разворот на курс
	private const N_TAXI_SUBMODE_CENTERLINING: int = 3;	//выравнивание на центральную линию	

	//property fields

	//other fields
	private var isGateChanged: Boolean;
	private var nTaxiSubmode: int; 

//properties

	
//methods
	//constructor
    public function Plane(AType: AircraftType, ALocation:Point, ACourse:Angle, AnAirportRect: Rect, AState:AircraftState, AFuelResidue: Number, AGate: Gate = null)
    {
		super(AType, ALocation, ACourse, AnAirportRect, AState, AFuelResidue, AGate);
    }

	//public methods
	
	//protected methods

	protected override function approach(AWind: Wind, ACloudCount: int)
	{
		//проверяем хватит ли остатка ВПП для посадки
		if (!checkRunwayRemainder(AWind))
		{
			return false;
		}

		return super.approach(AWind, ACloudCount);
	}

	protected override function brake(AWind: Wind): void
	{
		super.brake(AWind);
		
		//затормозили - рулим
		if (dblSpeed <= FType.TaxiingSpeed) 
		{
			
			isGateChanged = false;
			FState = AircraftState.TaxiingToGate;
			FTargetAirfield.Selected = false;
		}
		else 
		{
			checkRunwayRemainder(AWind);
		}
	}	

	protected override function control(AWind: Wind, ACloudCount: int): Boolean
	{
		if (super.control(AWind, ACloudCount)) return true;
	
		switch (FState)
		{			
			case AircraftState.TaxiingToGate:
				taxiToGate();
				break;			
				
			case AircraftState.TaxiingToAirfield:
				taxiToTakeoff();
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
	
	protected override function land(AWind: Wind, ACloudDensity: int): Boolean
	{
		var is_landed: Boolean = super.land(AWind, ACloudDensity);
		if (is_landed)
		{
				brake(AWind);
		}

		return is_landed;
	}

	protected override function lossOfContact(AWind: Wind)
	{
		if (FAltitude <= 0) 
		{
			dblSpeed = super.convertToInstrumentalSpeed(dblSpeed, AWind);
		}
		super.lossOfContact(AWind);
	}	
	
	protected override function navigateToAirfield(IsInLandingZone: Boolean, AWind: Wind): Boolean
	{
		//заход: основной принцип следовать курсом равным азимуту на центр ВПП плюс еще внутрь на удвоенную разницу между курсом ВПП и 
		//азимутом на центр ВПП. Например: курс ВПП = 90грд. Азимут на центр = 80грд. Разница = 10грд. Следвать 80 - 10*2 = 60грд.
		//азимут на центр ВПП
		var obj_dist: Object = {Distance: 0.0};
		var ang_to_runway: Angle = Angle.direction(Location, FTargetAirfield.Location, obj_dist);		
		
		//здесь не работает ILS
		if (obj_dist.Distance < DBL_COURSE_ERROR_DISTANCE)
		{
			nTurn = Course.getRotation(getLandingCourse());
			return true;
		}
		else
		{			
			return alignLocalizer(ang_to_runway, IsInLandingZone, AWind);
		}	
	}

	protected override function stayReadyToTakeoff(): Boolean
	{
		var is_takeoff_allowed: Boolean = super.stayReadyToTakeoff();
		if(is_takeoff_allowed)
		{
			nTaxiSubmode = N_TAXI_SUBMODE_ENTRY;
		}

		return is_takeoff_allowed;
	}
	
	protected override function takeoff(AWind: Wind): void
	{
		//ехать с курсом ВПП
		nTurn = (FTargetAirfield == null) ? 0 : Course.getRotation(FTargetAirfield.ActiveCourse);
		//набирая скорость до нормальной
		dblAcceleration = (dblSpeed < FType.CruiseSpeed) ? FType.Acceleration : 0;
		//при скорости отрыва набирать высоту
		var dbl_instr_speed = (FAltitude > 0) ? dblSpeed : convertToInstrumentalSpeed(dblSpeed, AWind);			
		if (dbl_instr_speed > FType.LiftoffSpeed)
		{
			super.takeoff(AWind);
		}
	}	
	
	protected override function touchdown(AWind: Wind) 
	{
		dblSpeed = convertToGroundSpeed(dblSpeed, AWind);
		super.touchdown(AWind);		
	}	
	
	//private methods

	private function alignLocalizer(AnAngleToRunway: Angle, IsInLandingZone: Boolean, AWind: Wind)
	{
		//получаем посадочный курс
		var ang_rw_course: Angle = getLandingCourse();
		
		//угол между азимутом на ВПП и курсом ВПП
		var ang_diff2: Angle = AnAngleToRunway.sub(ang_rw_course);

		//Действие ILS
		AnAngleToRunway.inc(ang_diff2);
		AnAngleToRunway.inc(ang_diff2);
		
		//Уход на круг
		var dbl_abs_err: Number = Math.abs(ang_diff2.Radian);

		if ((dbl_abs_err > DBL_ALLOWABLE_APPROACH_ERROR) 
			&& !IsInLandingZone && FAltitude > 0)
		{
			goAround(AWind);
			return false;	
		}	
		else
		{
			nTurn = Course.getRotation(AnAngleToRunway);
			return true;
		}
	}
	
	private function checkRunwayRemainder(AWind: Wind)
	{
			//trace('checkRunwayRemainder()');
			//азимут на центр ВПП
			var obj_dist: Object = {Distance: 0.0};
			var ang_to_runway: Angle = Angle.direction(Location, FTargetAirfield.Location, obj_dist);
			//trace(' ang_to_runway='+ang_to_runway.Degree);
			//trace(' obj_dist.Distance='+obj_dist.Distance);			
			//получаем посадочный курс
			var ang_rw_course: Angle = getLandingCourse();
			//trace(' ang_rw_course='+ang_rw_course.Degree);
			//угол между азимутом на ВПП и курсом ВПП
			var ang_diff: Angle = ang_to_runway.sub(ang_rw_course);
			//trace(' ang_diff=' + ang_diff.Degree);
			//считаем остаток ВПП
			var dbl_rw_remainder = FTargetAirfield.Length / 2 + obj_dist.Distance * ((ang_diff.abs().Radian < Math.PI/2) ? +1 : -1);
			//trace(' dbl_rw_remainder='+dbl_rw_remainder);
			//получаем проекцию скорости ветра на курс
			var dbl_wind_proj: Number = AWind.Speed * AWind.Direction.sub(ang_rw_course).cos();
			//если полосы не хватает уходим на круг
			if (dbl_rw_remainder < FType.LandingRollLength * (dblSpeed + dbl_wind_proj - FType.TaxiingSpeed) / (FType.TouchdownSpeed - FType.TaxiingSpeed))
			{
				goAround(AWind);
				return false;
			}
			//trace('checkRunwayRemainder=true')

			return true;
	}

	public function getCourseAndDistance(AnAirfield: IAirfield, AResult: Object)
	{
		AResult.Course.Radian = AnAirfield.Course.Radian;
		var ang_from_aircraft: Angle = Angle.direction(Location, AnAirfield.Location, AResult);
		var ang_diff: Angle = ang_from_aircraft.sub(AnAirfield.Course);
		if (ang_diff.abs().Radian > Math.PI / 2)
                        AResult.Course.dec(Angle.PI);
		AResult.BackCourse = AResult.Course.sub(Angle.PI);
	}
	
	private function getCourseToCenterline(): Angle
	{
		//1. получаем азимут на ВПП
		//		берем азимут перпендикулярный курсу ВПП
		var ang_to_centerline: Angle = FTargetAirfield.Course.add(Angle.HalfPI);
		//      получаем курс на центр
		var obj_dist: Object = {Distance: 0.0};
		var ang_to_runway: Angle = Angle.direction(Location, FTargetAirfield.Location, obj_dist);
		//		считаем разницу между ними
		var ang_diff: Angle = ang_to_runway.sub(ang_to_centerline);
		//		если разница больше Пи/2 то берем встречный перпендикуляр
		if (ang_diff.abs().Radian > Math.PI/2)
		{
			ang_to_centerline.dec(Angle.PI);
		}
		return ang_to_centerline;
	}
	
	private function getLandingCourse(): Angle
	{
		//trace('getLandingCourse()');
		if (FState == AircraftState.Landing)
		{
			//trace('getLandingCourse='+FTargetAirfield.ActiveCourse.Degree);
			return FTargetAirfield.ActiveCourse;
		}
		else
		{
			var obj_rw_dir: Object = {Course: new Angle(), BackCourse: new Angle(), Distance: 0.0};
			getCourseAndDistance(FTargetAirfield, obj_rw_dir);
			//trace('getLandingCourse='+ obj_rw_dir.Course.Degree); 
			return obj_rw_dir.Course;
		}
	}
	
	private function taxiDownwind()
	{
		var obj_rw_dir2: Object = {Course: new Angle(), BackCourse: new Angle(), Distance: 0.0};
		getCourseAndDistance(FTargetAirfield, obj_rw_dir2);
		var dbl_run_dist = FTargetAirfield.Length / 2 
			+ obj_rw_dir2.Distance * ((obj_rw_dir2.Course.Radian == FTargetAirfield.ActiveCourse.Radian) ? +1 : -1);
		if (dbl_run_dist < FType.TakeoffRollLength)
		{
			nTurn = Course.getRotation(FTargetAirfield.ActiveCourse.sub(Angle.PI));						
		}
		else
		{
			nTaxiSubmode = N_TAXI_SUBMODE_U_TURN;
			taxiUTurn();
		}
	}
	
	private function taxiToCenterline()
	{
		if(Runway(FTargetAirfield).getDistanceToCenterline(Location) <= DBL_ALLOWABLE_CENTERLINE_ERROR)
		{
			FState = AircraftState.TakingOff;
			nTurn = 0;
		}
		else
		{
			nTurn = Course.getRotation(getCourseToCenterline());
		}
	}

	private function taxiToGate(): void
	{
		if (!isGateChanged)
		{
			FOccupiedGate = FTargetAirfield.exchangeGate(FOccupiedGate, this.Location);
			isGateChanged = true;
		}

		dblVelocity = 0;
		dblAcceleration = (dblSpeed > FType.TaxiingSpeed) ? DBL_BRAKING : 0;
		
		var obj_rw_dir: Object = {Course: new Angle(), BackCourse: new Angle(), Distance: 0.0};
		getCourseAndDistance(FTargetAirfield, obj_rw_dir);
		//получаем азимут на гейт и расстояние до него		
		var obj_dist: Object = {Distance: 0.0};
		var ang_to_gate: Angle = Angle.direction(Location, FOccupiedGate.Location, obj_dist);
		//смотрим угол между курсом к центру ВПП и азимутом на гейт
		var ang_diff: Angle = new Angle(Math.abs(obj_rw_dir.Course.sub(ang_to_gate).Radian), Angle.RADIAN);
		//если модуль угла почти Пи/2, поворачиваем на гейт
		if (ang_diff.sub(Angle.HalfPI).abs().Radian < DBL_ALLOWABLE_TURN_ERROR)
		{
			nTurn = Course.getRotation(ang_to_gate);
			//контроллируем расстояние до гейта, чтобы затормозить и сменить статус						
			if (obj_dist.Distance < DBL_ALLOWABLE_GATE_STOP_ERROR)
			{
				stop();
				declareLanded();
			}
		}
		else 
			if(Runway(FTargetAirfield).getDistanceToCenterline(Location) > DBL_ALLOWABLE_CENTERLINE_ERROR)
				nTurn = Course.getRotation(getCourseToCenterline());
			else
				//если угол меньше Пи/2 
				//то есть гейт находится по ходу к центру ВПП:
				//не доехали еще до гейта, но и не пробежали центр
				//или и проехали гейт и уже пробежали центр ВПП
				if (ang_diff.Radian < Math.PI / 2) 
					nTurn = Course.getRotation(obj_rw_dir.Course); //продолжаем движение по курсу ВПП
				else 
				{	
					//гейт находится по ходу от центра ВПП: 
					//проехали гейт и не пробежали еще центр ВПП
					//или пробежали центр, но не доехали еще до гейта
					nTurn = Course.getRotation(obj_rw_dir.BackCourse); //держим курс на курс обратный курсу ВПП
				}
	}

	private function taxiToRunway()
	{
		if (Runway(FTargetAirfield).getDistanceToCenterline(Location) > DBL_ALLOWABLE_CENTERLINE_ERROR)
		{
			nTurn = Course.getRotation(getCourseToCenterline());
		}
		else
		{
			nTaxiSubmode = N_TAXI_SUBMODE_DOWNWIND; 
			taxiDownwind();
		}
	}
	
	private function taxiToTakeoff(): void
	{
		dblAcceleration = (dblSpeed < FType.TaxiingSpeed) ? FType.Acceleration*2 : 0;

		switch(nTaxiSubmode)
		{
			case N_TAXI_SUBMODE_ENTRY:
				taxiToRunway();
				break;
			case N_TAXI_SUBMODE_DOWNWIND:
				taxiDownwind();
				break;
			case N_TAXI_SUBMODE_U_TURN:
				taxiUTurn();
				break;
			case N_TAXI_SUBMODE_CENTERLINING:
				taxiToCenterline();
				break;
		}
	}
	
	private function taxiUTurn()
	{
		var ang_diff = FTargetAirfield.ActiveCourse.sub(Course);
		if(Math.abs(ang_diff.Radian) > DBL_ALLOWABLE_TURN_ERROR)
		{
			nTurn = Course.getRotation(FTargetAirfield.ActiveCourse);
		}
		else
		{
			nTaxiSubmode = N_TAXI_SUBMODE_CENTERLINING;
			taxiToCenterline();
		}
	}

	//event handlers
	
}
}