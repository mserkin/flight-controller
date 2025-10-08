package ap.views {

///////////////////////////////////////////////////////////
//  AircraftView.as
///////////////////////////////////////////////////////////
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import ap.basic.*;
import ap.enumerations.*;
import ap.input.*;
import ap.instrumental.*;
import ap.model.Aircraft;

public class AircraftView //static
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
	static private const DBL_AIRCRAFT_ALT_SCALE: Number = 0.25;
	static private const DBL_AIRCRAFT_SHADOW_BASE_SHIFT: Number = 1;
	static private const DBL_AIRCRAFT_SHADOW_SHIFT: Number = 8;
	static private const DBL_APPROAICHING_MARK_HEIGHT: Number = 40;
	static private const DBL_APPROAICHING_MARK_WIDTH: Number = 30;
	static private const DBL_BALLOON_HEIGHT: Number = 30; 
	static private const DBL_BALLOON_WIDTH: Number = 35; 
	static private const DBL_CRITICAL_FUEL_LEVEL: Number = 0.2;
	static private const DBL_GAMEZONE_MARGIN: Number = 5;
	static private const DBL_GAUGE_HEIGHT: Number = 3.125;
	static private const DBL_GAUGE_WIDTH: Number = 15.0;
	static private const DBL_LIGHT_IMG_HEIGHT: Number = 46.5;
	static private const DBL_NORMAL_LEAVING: Number = 50;
	static private const N_BLINK_MIN_PERIOD: Number = 1;
	static private const N_BLINK_MAX_PERIOD: Number = 12;
	
	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	//static private var nFrameCounter: int = 0;
	static private var pslArrivalMarks: PeriodicStateList = new PeriodicStateList();
	static private var pslGaugeStates: PeriodicStateList = new PeriodicStateList();
//properties
	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/
//methods
	//public methods
	static public function display(AnAircraftsVector: Vector.<Aircraft>) 
	{	
		pslGaugeStates.tick();
		pslArrivalMarks.tick();
		Profiler.checkin("aircrafts");
		var aircrafts_vector: Vector.<Aircraft> = AnAircraftsVector.sort(compareAltitude);
		for each(var aircraft: Aircraft in aircrafts_vector) 
		{
			var pnt_scr: Point = FrameBuilder.convertToScreenPoint(aircraft.Location);	
			switch(aircraft.State)
			{
				case AircraftState.Arriving:
					displayArrivalMark(aircraft, pnt_scr);
					break;
					
				case AircraftState.Directed:
				case AircraftState.Approaching:
				case AircraftState.Landing:					
					displayPath(aircraft);
					break;
			}
		}
		for each(var craft: Aircraft in aircrafts_vector)
		{
			if (craft.State == AircraftState.Arriving) continue;
			var rect_aircraft: Rect = FrameBuilder.convertToScreenRect(craft);
			if (FrameBuilder.FrameRect.isInside(rect_aircraft.Location) || aircraft.State == AircraftState.TakingOff)
			{
				//отображение самолета
				displayAircraft(craft, rect_aircraft);
			}
			else 
			{
				//отображение стрелки
				displayArrivalMark(craft, rect_aircraft.Location);
			}	
		}
		Profiler.checkout("aircrafts");
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods
	
	static private function calcBlinkPeriod(AnAircraft: Aircraft, AScreenPosition: Point, AnArrowPosition: Point): int
	{
		var dbl_rate: Number;
		if (AnAircraft.State == AircraftState.Arriving) {
			dbl_rate = AnAircraft.TimeToArrive/(Aircraft.DBL_ARRIVAL_PERIOD/2); 
		}
		else {
			dbl_rate = Math.max(Math.abs(AScreenPosition.X - AnArrowPosition.X), 
				Math.abs(AScreenPosition.Y - AnArrowPosition.Y))/DBL_NORMAL_LEAVING;
		}
		return int(Math.ceil(N_BLINK_MIN_PERIOD + dbl_rate*(N_BLINK_MAX_PERIOD - N_BLINK_MIN_PERIOD)));		
	}
	
	static private function compareAltitude(AnAircraft1: Aircraft, AnAircraft2: Aircraft): Number
	{
		return Instruments.sign(AnAircraft1.Altitude - AnAircraft2.Altitude);
	}
	
	static private function createAircraftFrameImage(AnAircraft: Aircraft): Sprite
	{
		if (AnAircraft.Collided) 
		{
			switch(AnAircraft.Type)
			{
				case AircraftType.Copter:
					return new CopterCollidedImage();
				case AircraftType.Propeller:
					return new PropellerCollidedImage();
				case AircraftType.Liner:
					return new LinerCollidedImage();
				case AircraftType.Supersonic:
					return new SupersonicCollidedImage();
			}
		} 
		else if (AnAircraft.Selected) 
		{
			switch(AnAircraft.Type)
			{
				case AircraftType.Copter:
					return new CopterSelectedImage();
				case AircraftType.Propeller:
					return new PropellerSelectedImage();
				case AircraftType.Liner:
					return new LinerSelectedImage();
				case AircraftType.Supersonic:
					return new SupersonicSelectedImage();
			}
		}
		return null;
	}
	
	static private function createAircraftImage(AnAircraft: Aircraft): Sprite
	{
		switch (AnAircraft.State) {
			case AircraftState.Undirected :
				switch(AnAircraft.Type)
				{
					case AircraftType.Copter:
						return new CopterUndirectedImage();					
					case AircraftType.Propeller:
						return new PropellerUndirectedImage();
					case AircraftType.Liner:
						return new LinerUndirectedImage();
					case AircraftType.Supersonic:
						return new SupersonicUndirectedImage();
				}
			case AircraftState.TaxiingToAirfield :
			case AircraftState.ReadyToTakeoff :
			case AircraftState.TakingOff :
				switch(AnAircraft.Type)		
				{
					case AircraftType.Copter:
						return new CopterDepartingImage();
					case AircraftType.Propeller:
						return new PropellerDepartingImage();
					case AircraftType.Liner:
						return new LinerDepartingImage();
					case AircraftType.Supersonic:
						return new SupersonicDepartingImage();
				}
			case AircraftState.PreparingToTakeoff :
				if (AnAircraft.Type == AircraftType.Copter) 
					return new CopterParkedImage();
				//no break!
			default :
				switch(AnAircraft.Type)		
				{
					case AircraftType.Copter:
						return new CopterDirectedImage();
					case AircraftType.Propeller:
						return new PropellerDirectedImage();
					case AircraftType.Liner:
						return new LinerDirectedImage();
					case AircraftType.Supersonic:
						return new SupersonicDirectedImage();
				}
		}
		return null;
	}
	
	static private function createAircraftShadowImage(AnAircraft: Aircraft): Sprite
	{
		switch(AnAircraft.Type)
		{
			case AircraftType.Copter:
				return new CopterShadowImage();
			case AircraftType.Propeller:
				return new PropellerShadowImage();
			case AircraftType.Liner:
				return new LinerShadowImage();
			case AircraftType.Supersonic:
				return new SupersonicShadowImage();
		}
		return null;
	}

	static private function displayAircraft(AnAircraft: Aircraft, AnAircraftScreenRect: Rect) 
	{
		//отображения тени
		Profiler.checkin("shadows");
		displayAircraftShadow(AnAircraft, AnAircraftScreenRect);
		Profiler.checkout("shadows");
		//отображение света фар
		Profiler.checkin("headlights");
		displayHeadlight(AnAircraft, AnAircraftScreenRect);
		Profiler.checkout("headlights");
		//отображение самого самолета
		Profiler.checkin("bodies");
		displayAircraftBody(AnAircraft, AnAircraftScreenRect);
		Profiler.checkout("bodies");
		//отображение градусника
		Profiler.checkin("gauges");	
		displayGauge(AnAircraft, AnAircraftScreenRect);
		Profiler.checkout("gauges");	
		//отображение балуна
		Profiler.checkin("balloons");	
		displayBalloon(AnAircraft, AnAircraftScreenRect);
		Profiler.checkout("balloons");	
	}
	
	static private function displayAircraftBody(AnAircraft: Aircraft, AnAircraftScreenRect: Rect) 
	{
		//отображение самолета
		var sp_aircraft: Sprite = createAircraftImage(AnAircraft);
	
		var dbl_koef: Number = (1 + (AnAircraft.Altitude - Aircraft.DBL_NORMAL_ALTITUDE) / Aircraft.DBL_NORMAL_ALTITUDE * DBL_AIRCRAFT_ALT_SCALE);
		AnAircraftScreenRect.Extent = new Size(AnAircraft.Extent.Width / FrameBuilder.Zoom * dbl_koef, AnAircraft.Extent.Height / FrameBuilder.Zoom * dbl_koef);
		ScreenManager.displayImage(sp_aircraft, AnAircraftScreenRect, AnAircraft.Course);
	
		//отображение окантовки самолета
		var sp_fr_aircraft: Sprite = createAircraftFrameImage(AnAircraft);
	
		if (sp_fr_aircraft!=null) {
			ScreenManager.displayImage(sp_fr_aircraft, AnAircraftScreenRect, AnAircraft.Course);
		}
	}
	
	static private function displayAircraftShadow(AnAircraft: Aircraft, AnAircraftScreenRect: Rect) 
	{
		if (AnAircraft.Altitude===0) {
			return;
		}
	
		var sp_shadow: Sprite = createAircraftShadowImage(AnAircraft);
		
		var dbl_shift: Number = FrameBuilder.adaptToFrame(DBL_AIRCRAFT_SHADOW_BASE_SHIFT + 
			DBL_AIRCRAFT_SHADOW_SHIFT * (1 + (AnAircraft.Altitude - Aircraft.DBL_NORMAL_ALTITUDE)/Aircraft.DBL_NORMAL_ALTITUDE));
		var dbl_src_aircraft_size = AnAircraft.Extent.Width/FrameBuilder.Zoom;		
		var dbl_koef: Number = (1 + (AnAircraft.Altitude - Aircraft.DBL_NORMAL_ALTITUDE) / Aircraft.DBL_NORMAL_ALTITUDE * DBL_AIRCRAFT_ALT_SCALE);
		var rect_shadow: Rect = new Rect(
			new Point(AnAircraftScreenRect.Location.X + dbl_shift, AnAircraftScreenRect.Location.Y + dbl_shift),
			new Size(dbl_src_aircraft_size * dbl_koef, dbl_src_aircraft_size * dbl_koef)
		);
	
		ScreenManager.displayImage(sp_shadow, rect_shadow, AnAircraft.Course);
	}
	
	static private function displayArrivalMark(AnAircraft: Aircraft, AScreenPosition: Point) 
	{
		var angle: Angle = Angle.direction(new Point(0.0), AnAircraft.Location);
		var rect_game_zone: Rect = FrameBuilder.GameZoneRect.clone();
		rect_game_zone.Location.X += DBL_GAMEZONE_MARGIN;
		rect_game_zone.Location.Y += DBL_GAMEZONE_MARGIN;
		rect_game_zone.Extent.Width -= 2*DBL_GAMEZONE_MARGIN;
		rect_game_zone.Extent.Height -= 2*DBL_GAMEZONE_MARGIN;
		
		var pnt_arrow_pos: Point = rect_game_zone.moveToRect(AScreenPosition);
		
		if (AnAircraft.TimeToArrive < Aircraft.DBL_ARRIVAL_PERIOD/2)
		{
			var n_blink_period = calcBlinkPeriod(AnAircraft, AScreenPosition, pnt_arrow_pos);
			if (!pslArrivalMarks.getState(AnAircraft, n_blink_period)) return;
		}
		
		ScreenManager.displayImage(
			new ApproachingMarkImage(), 
			new Rect(
				pnt_arrow_pos,
				new Size(
					FrameBuilder.adaptToFrame(DBL_APPROAICHING_MARK_WIDTH), 
					FrameBuilder.adaptToFrame(DBL_APPROAICHING_MARK_HEIGHT)
				)
			), 
			angle
		);
	}
	
	static private function displayBalloon(AnAircraft: Aircraft, AnAircraftScreenRect: Rect) 
	{
		var do_balloon: DisplayObject;
		switch (AnAircraft.GoAroundCause)
		{	
			case Aircraft.DBL_GA_CAUSE_NONE: 
				return;
			case Aircraft.DBL_GA_CAUSE_WIND:
				do_balloon = new StrongWindBalloonImage();
				break;
			case Aircraft.DBL_GA_CAUSE_CLOUDS:
				do_balloon = new CloudBalloonImage();
				break;			
			default:
				do_balloon = new ShortRunwayBalloonImage();
				break;			
		}
		
		var rect_balloon: Rect = new Rect(
			new Point(AnAircraftScreenRect.Location.X, AnAircraftScreenRect.Location.Y),
			new Size(
				FrameBuilder.adaptToFrame(DBL_BALLOON_WIDTH), 
				FrameBuilder.adaptToFrame(DBL_BALLOON_HEIGHT)
			)
		);
		ScreenManager.displayImage(do_balloon, rect_balloon, new Angle());
	}

	static private function displayGauge(AnAircraft: Aircraft, AnAircraftScreenRect: Rect) 
	{
		if (AnAircraft.State==AircraftState.ReadyToTakeoff&&! AnAircraft.IsTakeoffPending) return;
		
		if (AnAircraft.Fuel < DBL_CRITICAL_FUEL_LEVEL && AnAircraft.State.IsComing)
		{
			var n_blink_period: int = new int(AnAircraft.Fuel * Core.N_FRAME_RATE / DBL_CRITICAL_FUEL_LEVEL);
			if (!pslGaugeStates.getState(AnAircraft, n_blink_period)) return;
		}
		//отображение градусника 
		var ang_0: Angle = new Angle();
	
		//отображаем красный фон
		var sp_red: Sprite = new FuelGaugeRedSegmentImage();
		var dbl_koef: Number = 1 + (AnAircraft.Altitude - Aircraft.DBL_NORMAL_ALTITUDE) / Aircraft.DBL_NORMAL_ALTITUDE * DBL_AIRCRAFT_ALT_SCALE;
		var rect_gauge: Rect = new Rect(
			new Point(AnAircraftScreenRect.Location.X + AnAircraftScreenRect.Extent.Width, AnAircraftScreenRect.Location.Y - AnAircraftScreenRect.Extent.Height / 1.5),
			new Size(
				FrameBuilder.adaptToFrame(DBL_GAUGE_WIDTH) * dbl_koef, 
				FrameBuilder.adaptToFrame(DBL_GAUGE_HEIGHT) * dbl_koef
			)
		);
		ScreenManager.displayImage(sp_red, rect_gauge, ang_0);
	
		//отображам зеленый сегмент
		var sp_green: Sprite = new FuelGaugeGreenSegmentImage();
		var rect_gauge_green: Rect = rect_gauge.clone();
		rect_gauge_green.Extent.Width *= AnAircraft.Fuel;
	
		ScreenManager.displayImage(sp_green, rect_gauge_green, ang_0);
	
		//отображам рамку градусника
		//var mc_frame: MovieClip = new FuelGaugeFrameImage();
		//ScreenManager.displayImage(mc_frame, rect_gauge, ang_0);
	}
		
	static private function displayHeadlight(AnAircraft: Aircraft, AnAircraftScreenRect: Rect) 
	{
		if (AnAircraft.IsOccupingAirfield && (AnAircraft.State == AircraftState.Landing || AnAircraft.State == AircraftState.TakingOff)) {
			//отображение света фары
			var sp_light: Sprite = new AircraftHeadlightImage();
			var dbl_koef: Number = (1 + (AnAircraft.Altitude - Aircraft.DBL_NORMAL_ALTITUDE) / Aircraft.DBL_NORMAL_ALTITUDE * DBL_AIRCRAFT_ALT_SCALE);
			AnAircraftScreenRect.Extent = new Size(
				AnAircraft.Extent.Width / FrameBuilder.Zoom * dbl_koef, 
				FrameBuilder.adaptToFrame(DBL_LIGHT_IMG_HEIGHT) * dbl_koef
			);
			ScreenManager.displayImage(sp_light, AnAircraftScreenRect, AnAircraft.Course);
		}
	}
	
	static public function displayPath(AnAircraft: Aircraft)
	{
		Profiler.checkin("paths");
		var vpntPath: Vector.<Point> = new Vector.<Point>();
		vpntPath.push(FrameBuilder.convertToScreenPoint(AnAircraft.Location));
		
		for (var i: int = 0; i < AnAircraft.Path.Length; i++)
		{
			vpntPath.push(FrameBuilder.convertToScreenPoint(AnAircraft.Path.get(i)));
		}
		
		if (AnAircraft.TargetAirfield)
		{
			vpntPath.push(FrameBuilder.convertToScreenPoint(AnAircraft.TargetAirfield.Location));
		}

		ScreenManager.drawLine(vpntPath, AnAircraft.Selected ? Colors.Selection : Colors.Gray, (AnAircraft.Path.Length > 0) ? 1 : 0.5); 
		Profiler.checkout("paths");
	}	
	
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
