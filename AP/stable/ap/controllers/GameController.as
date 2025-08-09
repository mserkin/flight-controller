package ap.controllers {

///////////////////////////////////////////////////////////
//  GameController.as
///////////////////////////////////////////////////////////

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import ap.basic.*;
import ap.enumerations.*;
import ap.input.*;
import ap.instrumental.*;
import ap.model.*;
import ap.views.FrameBuilder;
import ap.views.HintPanelView;

public class GameController implements IController //Singleton
{
//public fields & consts		

	//public const
	
	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	//public var OnGameStarted: CustomDispatcher = keynew CustomDispatcher();

//protected fields & consts

	//protected consts`
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#FDelphiStyle#>: <#Type#>,*/

	//other protected fields
	/*protected var <#FDelphiStyle#>: <#Type#>;*/
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	private const DBL_CLOSE_ARRIVAL: Number = 1000;
	private const DBL_CLOUD_QUANTITY_RATE: Number = 0.001;
	private const DBL_LEAVE_BOUND: Number = -300;
	private const DBL_MAX_CLOUD_LENGTH: Number = 10000;
	private const DBL_MAX_CLOUD_RATIO: Number = 2;	
	private const DBL_MAX_CLOUD_WIDTH: Number = 8000;
	private const DBL_MAX_SIMULATION_RATE: Number = 3; //frames per frame
	private const DBL_MIN_CLOUD_LENGTH: Number = 2000;
	private const DBL_MIN_CLOUD_SPEED: Number = 30;
	private const DBL_MIN_CLOUD_WIDTH: Number = 4000;
	private const DBL_MIN_FUEL: Number = 0.3; 
	private const DBL_MIN_SIMULATION_RATE: Number = 1; //frames per frame
	private const DBL_NORMAL_WIND_SPEED: Number = 40;
	private const DBL_RUNWAY_CAPTURE_ZONE: Number = 0.75;
	private const DBL_RUNWAY_RELEASE_DISTANCE = 1.3; //lengths of the runway
	private const N_FULL_TANK_POINTS = 1000; 
	private const N_MAX_ACTIVE_AIRCRAFT_COUNT: int = 13;
	private const N_MIN_ACTIVE_AIRCRAFT_COUNT: int = 3;
	private const N_MIN_EMIT_INTERVAL: int = 128; //frames
	private const N_SIMULSTION_ACCELERATION: int = 3; //times
	private const N_WAYPOINT_CREATION_TIMEOUT = 50; //milliseconds between waypoint creation

	//property fields
	private var FLandingsDone: int;
	private var FLandingsToDo: int;
	private var FSimulationRate: Number = 1;	

	//other fields
	private var apAirport: Airport;		
	static private var controllerInstance: GameController;
	private var dblCopterRate: Number;
	private var dblLinerRate: Number;
	private var dblPropRate: Number;
	private var dblTrafficIntensity: Number;		
	private var dtWaypointCreated: Date;
	private var isCreatingPath: Boolean = false;
	private var isLoadingLevel: Boolean = false;
	private var isNewPath: Boolean;
	private var nEmitInterval: int = 0; //frames	
    private var plSelectedAircraft: Aircraft;
    private var rwSelectedAirfield: IAirfield;
	private var ulLoader: URLLoader;	

//properties

	public function get LandingsDone(): int
    {
    	return FLandingsDone;
    }

	public function get LandingsToDo(): int
    {
    	return FLandingsToDo;
    }
	
	public function get ShiftProgress(): int
    {
    	return int(FLandingsDone * 100 / FLandingsToDo);
    }

    public function get SimulationRate(): Number
    {
    	return FSimulationRate;
    }

//methods
	//constructor 
	//private constructors not supported by actionscript
	//use getInstance instead!
	
   	public function GameController(AnAirport: Airport)
	{
		apAirport = AnAirport;
		apAirport.OnLevelLoaded.addEventListener(CustomDispatcher.ON_LEVEL_LOADED, Airport_OnLevelLoaded);
		apAirport.OnGateLoaded.addEventListener(CustomDispatcher.ON_GATE_LOADED, Airport_OnGateLoaded);

		FrameBuilder.BeforeRescale.addEventListener(CustomDispatcher.BEFORE_RESCALE, FrameBuilder_BeforeRescale);

		HintPanelView.OnHiding.addEventListener(CustomDispatcher.ON_HIDING, HintPanelView_OnHiding);
		HintPanelView.OnShown.addEventListener(CustomDispatcher.ON_SHOWN, HintPanelView_OnShown);
	}

	//public methods

	public function fixAirportRect(AHorZoom: Number, AVertZoom: Number): void
    {
		apAirport.fixAirportRect(AHorZoom, AVertZoom);
	}

	public function getControllerType(): int 
	{
		return ControlDispatcher.N_GAME_CONTROLLER;
	}

	static public function getInstance(AnAirport: Airport = null): GameController
	{
		if (!controllerInstance)
		{
			controllerInstance = new GameController(AnAirport);
		}
		return controllerInstance;
	}

	public function processDispatcherEvent(AType: int, AParamObj: Object = null): Boolean
	{
		switch (AType)
		{
			case ControlDispatcher.N_FAST_SIMULATION:
				if (SimulationRate == 1) 
					accelerate();
				else 
					decelerate();
				return true;
				
			case ControlDispatcher.N_NEXT_LEVEL:
				nextLevel();
				return true;	

			case ControlDispatcher.N_PATH_FINISH:
				return finishPath(AParamObj.Position);
				
			case ControlDispatcher.N_PATH_CONTINUE:
				return continuePath(AParamObj.Position);
				
			case ControlDispatcher.N_PAUSE_SIMULATION:
				if (SimulationRate > 0) 
					pause();
				else 
					resume();
				return true;
				
			case ControlDispatcher.N_START_LEVEL:
				startLevel();
				return true;	

			case ControlDispatcher.N_OBJECT_ACTIVATE:
				select(AParamObj.Position, true);
				return true;
				
			case ControlDispatcher.N_OBJECT_INFO:
				return traceObjectInfo();
				
			case ControlDispatcher.N_OBJECT_SELECT:
				select(AParamObj.Position, false);
				return true;

			case ControlDispatcher.N_SHOW_HINTS:
				if (HintPanelView.IsShown)
					return HintPanelView.hide(true);
				else
					return HintPanelView.show(true);

			case ControlDispatcher.N_PLAY_LEVEL:
				playLevel();
				return true;	
		}
		return false;
	}

	public function run(): void
    {
		var n_frames: int = int(FSimulationRate);
		
		for (var j = 0; j < n_frames; j++)
		{
			if (ControlDispatcher.CurrentDisplayMode == DisplayMode.Play)
			{
				detectCollisions();
			}
			
			if (ControlDispatcher.CurrentDisplayMode != DisplayMode.Play) return;
				
			apAirport.updateWind();
			
			for each (var airfield: IAirfield in apAirport.Airfields)
			{
				airfield.updateWind(apAirport.CurrentWind.Direction);
			}
			
			controlAircraftQuantity(moveAircrafts());
			controlClouds();
		}
    }

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods
	private function accelerate(): void
	{
		FSimulationRate = Math.min(FSimulationRate*N_SIMULSTION_ACCELERATION, DBL_MAX_SIMULATION_RATE);
	}

	private function addWaypoint(AnAircraft: Aircraft, APosition: Point)
	{
		if (isNewPath)
		{			
			AnAircraft.Path.removeAll();
			AnAircraft.TargetAirfield = null;
			isNewPath =  false;
		}
		
		//проверяем на принадлежность ВВП
		for each (var airfield: IAirfield in apAirport.Airfields)
		{
			if (checkAirfieldCapture(airfield, APosition, AnAircraft)) return;
		}
			
		AnAircraft.Path.append(APosition);
		dtWaypointCreated = new Date(); 
		
		//отрыв пути от ВПП
		if (AnAircraft.TargetAirfield)
		{
			var obj_dist2: Object = {Distance: 0};
			Angle.direction(airfield.Location, APosition, obj_dist2);
			if (obj_dist2.Distance > AnAircraft.TargetAirfield.Length * DBL_RUNWAY_RELEASE_DISTANCE)
			{
				AnAircraft.TargetAirfield = null;					
				deselect(false);								
			}
		}
	}
	
	private function checkAirfieldCapture(AnAirfield: IAirfield, APosition: Point, AnAircraft: Aircraft): Boolean
	{
		if (Instruments.xor(AnAircraft.Type == AircraftType.Copter, AnAirfield is Runway) && AnAirfield.inArea(APosition))
		{
			var to_capture: Boolean = false;
			if (AnAirfield.IsRunway)
			{
				var obj_dist: Object = {Distance: 0};
				Angle.direction(AnAirfield.Location, APosition, obj_dist);
				to_capture = (obj_dist.Distance / (AnAirfield.Length / 2) > DBL_RUNWAY_CAPTURE_ZONE);
			}
			
			//захват ВПП
			if (!AnAirfield.IsRunway || to_capture)
			{
				AnAircraft.TargetAirfield = AnAirfield;
				deselect(false);					
				selectAirfield(AnAirfield);
				return true;
			}
		}
		return false;
	}
	
	private function continuePath(APosition: Point): Boolean
    {
		if (isCreatingPath)
		{
			var dt_current_time: Date = new Date();

			if (dt_current_time.valueOf() - dtWaypointCreated.valueOf() > N_WAYPOINT_CREATION_TIMEOUT)
			{
				addWaypoint(plSelectedAircraft, APosition);
			}
			return true;
		}
		
		return false;
	}
	
	private function controlAircraftQuantity(AnAircraftQuantity: int)
	{
		++nEmitInterval;
			
		if (FLandingsDone + AnAircraftQuantity < FLandingsToDo)
		{
			if (AnAircraftQuantity < N_MIN_ACTIVE_AIRCRAFT_COUNT)
			{
				nEmitInterval = N_MIN_EMIT_INTERVAL;
				emitAircrafts(false);
			}
			else
			{
				if (Math.random() < dblTrafficIntensity && AnAircraftQuantity < N_MAX_ACTIVE_AIRCRAFT_COUNT)
					emitAircrafts(true); 
			}
		}
	}

	private function controlClouds()
	{
		if (apAirport.CurrentWind.Speed > DBL_MIN_CLOUD_SPEED && Math.random() < apAirport.CloudProbability)
		{
			emitCloud();
		}
		
		for (var i: int; i < apAirport.Clouds.length; i++)
		{
			var cloud: Cloud = apAirport.Clouds[i];
			cloud.move(apAirport.CurrentWind);
			if (isCloudLeft(cloud))
			{
				apAirport.Clouds.splice(i, 1);
			}
		}
	}		

	private function createAircraft(AType: AircraftType, ALocation:Point, ACourse:Angle, AnAirportRect: Rect, AState:AircraftState, AFuelResidue: Number, AGate: Gate = null): Aircraft
	{
		if (AType == AircraftType.Copter)
			return new Copter(AType, ALocation, ACourse, AnAirportRect, AState, AFuelResidue, AGate);
		else
			return new Plane(AType, ALocation, ACourse, AnAirportRect, AState, AFuelResidue, AGate);
	}

	private function decelerate(): void
	{
		FSimulationRate = Math.max(FSimulationRate/N_SIMULSTION_ACCELERATION, DBL_MIN_SIMULATION_RATE);
	}
	
	private function deselect(DeselectAircraft: Boolean = true, DeselectAirfield: Boolean = true)
	{
		if (DeselectAircraft)
		{
			if (plSelectedAircraft != null) { plSelectedAircraft.Selected = false; plSelectedAircraft = null; }
		}
		
		if(DeselectAirfield)
		{
			if (rwSelectedAirfield != null) { rwSelectedAirfield.Selected = false; rwSelectedAirfield = null; }
		}
	}

	private function detectCloseArrivals(ALocation: Point)
	{
		for each(var aircraft: Aircraft in apAirport.Aircrafts)
		{
			if (Math.abs(aircraft.Location.X - ALocation.X) < DBL_CLOSE_ARRIVAL 
				|| Math.abs(aircraft.Location.Y - ALocation.Y) < DBL_CLOSE_ARRIVAL)
			{
				return true;
			}
		}
		return false;
	}
	
	private function detectCollisions()
	{
		for (var i: int = 0; i < apAirport.Aircrafts.length; i++)
		{
			for (var j: int = i + 1; j < apAirport.Aircrafts.length; j++)
			{
				if (apAirport.Aircrafts[i].checkCollision(apAirport.Aircrafts[j]))
					ControlDispatcher.CurrentDisplayMode = DisplayMode.CrashPause;
			}
		}		
	}
	
	private function emitAircrafts(IsArriving: Boolean)
	{
		if (nEmitInterval < N_MIN_EMIT_INTERVAL || FLandingsDone == FLandingsToDo) return;
		
		var mo_place: SelectableObject = null;
		var i: int = 0;
		do 
		{
			mo_place = getRandomBoundaryPosition(new Angle(Math.random()*360 - 180, Angle.DEGREE));		
		}
		while (detectCloseArrivals(mo_place.Location) && ++i < 20);		
		if (!mo_place) return;

		var dbl_wind_koef: Number = 1 + (apAirport.CurrentWind.MaximalSpeed - DBL_NORMAL_WIND_SPEED) 
			/ (apAirport.CurrentWind.DBL_MAX_WIND_SPEED - DBL_NORMAL_WIND_SPEED);
		if (dbl_wind_koef < 1) dbl_wind_koef = 1;
		var aircraft: Aircraft = createAircraft(pickAircraftType(), mo_place.Location, mo_place.Course, apAirport, 
			IsArriving ? AircraftState.Arriving : AircraftState.Undirected, 
			Math.random()*(1 - DBL_MIN_FUEL*dbl_wind_koef) + DBL_MIN_FUEL*dbl_wind_koef);
		
		
		aircraft.OnLanded.addEventListener(CustomDispatcher.ON_LANDED, Aircraft_OnLanded);

		apAirport.Aircrafts.push(aircraft);
				
		nEmitInterval = 0;
	}

	private function emitCloud(OnBoundaryOnly: Boolean = true)
	{
		var dbl_len: Number = Math.max(Math.random()*DBL_MAX_CLOUD_LENGTH, DBL_MIN_CLOUD_LENGTH);
		var dbl_width: Number = Math.max(Math.random()*DBL_MAX_CLOUD_WIDTH, DBL_MIN_CLOUD_WIDTH);
		var n_density: int = int(Math.floor(Math.random()*Cloud.N_MAX_DENSITY*apAirport.CloudProbability/Cloud.N_AVG_PROBABILITY)) + 1;
		var dbl_ratio: Number =  dbl_len / dbl_width;
		if (dbl_ratio < 1)
		{
			var dbl_swap: Number = dbl_len;
			dbl_len = dbl_width;
			dbl_width = dbl_swap;
			dbl_ratio = 1 / dbl_ratio;
		}
		if (dbl_ratio > DBL_MAX_CLOUD_RATIO) dbl_width = dbl_len / DBL_MAX_CLOUD_RATIO;

		var pnt_location: Point;
		if (OnBoundaryOnly)
		{
			pnt_location = getRandomBoundaryPosition(apAirport.CurrentWind.Direction).Location;
		}
		else
		{
			pnt_location = new Point(apAirport.Location.X + apAirport.Extent.Width*Math.random(), apAirport.Location.Y + apAirport.Extent.Height*Math.random());
		}
		
		apAirport.Clouds.push(new Cloud(pnt_location, new Size(dbl_width, dbl_len), 
			new Angle(Math.random()*360 - 180, Angle.DEGREE), n_density));
	}
	
	private function finishPath(APosition: Point): Boolean
    {			
		if (isCreatingPath)
		{
			addWaypoint(plSelectedAircraft, APosition);
			isCreatingPath = false;
			return true;
		}
		
		return false;
	}
	
	private function getCloudDensity(AnAircraft: Aircraft): int
	{
		var n_clouds: int = 0;
		for each (var cloud: Cloud in apAirport.Clouds)
		{
			var pnt_diff: Point = cloud.Location.sub(AnAircraft.Location);
			if ((Math.max(Math.abs(pnt_diff.X), Math.abs(pnt_diff.Y)) <= Math.max(cloud.Extent.Width/2, cloud.Extent.Height/2))
				&& cloud.inArea(AnAircraft.Location))
			{
				n_clouds += cloud.Density;
			}
		}
		return n_clouds;
	}
		
	private function getRandomBoundaryPosition(ACourse: Angle): SelectableObject
	{		
		var dbl_angle: Number = ACourse.Degree;
		var dbl_x_var: Number = (dbl_angle > 45 && dbl_angle <= 135) ? 0 : ((dbl_angle < -45 && dbl_angle > -135) ? 1 : Math.random());
		var dbl_y_var: Number = (dbl_angle > 45 && dbl_angle <= 135 || dbl_angle < -45 && dbl_angle > -135) ? Math.random()
			: ((dbl_angle >= -45 && dbl_angle <= 45) ? 1 : 0);
		
		var x: Number = apAirport.Location.X + apAirport.Extent.Width*dbl_x_var;
		var y: Number = apAirport.Location.Y + apAirport.Extent.Height*dbl_y_var; 
		return new SelectableObject(new Point(x, y), new Size(0, 0), ACourse);		
	}
	
	private function initLevel()
	{
		apAirport.Airfields.length = 0;
		apAirport.Aircrafts.length = 0;
		apAirport.Aprons.length = 0;
		apAirport.Gates.length = 0;
		apAirport.Clouds.length = 0;
		FSimulationRate = 1;
		FLandingsDone = 0;
	}

	private function isCloudLeft(ACloud: Cloud): Boolean
	{
		//если центр облака ушел
		if (apAirport.isInside(ACloud.Location)) return false;

		//смотрим ушли ли угловые точки
		var apnt: Vector.<Point> = ACloud.CornerPoints;
		for (var i = 0; i < apnt.length; i++)
		{
			if (apAirport.isInside(apnt[i]))
			{
				return false;
			}				
		}
		return true;
	}	
		
	private function loadLevel()
    {
		var strFile: String = "levels/Level" + GameProgress.Level.toString() + ".xml";
		ulLoader = new URLLoader();
		var urlr_file: URLRequest = new URLRequest(strFile);
		try {
			ulLoader.addEventListener(Event.COMPLETE, URLLoader_OnComplete);			
			ulLoader.load(urlr_file);
		} 
		catch (error:Error) 
		{
			trace("  Unable to load file " + strFile);
		}		
    }

	private function loadLevelCont()
	{
		var xml_doc: XML = new XML(ulLoader.data);
		ulLoader.close();

		var xml_airport: XML = xml_doc.airport[0];
		if (!xml_airport)
		{
			trace("Failed to load level: airport tag not found.");
			return;
		}
		
		FLandingsToDo = xml_doc.@targetLandings;
		dblTrafficIntensity = xml_airport.@traffic;
		dblCopterRate = xml_airport.@copterRate;
		dblPropRate = xml_airport.@propRate;
		dblLinerRate = xml_airport.@linerRate;		
		
		HintPanelView.Hints.length = 0;
		HintPanelView.ClipIds.length = 0;
		for each (var xml_hint: XML in xml_doc.hints.hint)
		{
			HintPanelView.Hints.push(xml_hint);
			HintPanelView.ClipIds.push(xml_hint.@clipId);
		}
		apAirport.loadLevel("levels/Level" + GameProgress.Level.toString() + ".xml");		
	}

	private function moveAircrafts(): int
    {
		var n_aircrafts_count: int = 0;
		for (var i: int = 0; i < apAirport.Aircrafts.length; i++)
		{
			var aircraft: Aircraft = apAirport.Aircrafts[i];
			//проверяем попадание в облако
			aircraft.move(apAirport.CurrentWind, getCloudDensity(aircraft));
			
			if (aircraft.State == AircraftState.TakingOff
				&& (
					aircraft.Location.X - apAirport.Location.X < DBL_LEAVE_BOUND 
					|| apAirport.Location.X + apAirport.Extent.Width - aircraft.Location.X < DBL_LEAVE_BOUND 
					|| aircraft.Location.Y - apAirport.Location.Y < DBL_LEAVE_BOUND 
					|| apAirport.Location.Y + apAirport.Extent.Height - aircraft.Location.Y < DBL_LEAVE_BOUND
				)
			)
			{
				apAirport.Aircrafts.splice(i, 1);
			}
			else
				if (aircraft.State.IsComing || aircraft.State == AircraftState.TaxiingToGate || aircraft.State == AircraftState.Arriving)
					n_aircrafts_count++;
		}
		return n_aircrafts_count;
	}	

	private function nextLevel(): void
    {
		GameProgress.nextLevel();
		initLevel();		
	}

	private function pause(): void
	{
		FSimulationRate = 0;
	}

	private function pickAircraftType(CanPickCopter: Boolean = true): AircraftType
	{
		var dbl_random: Number = Math.random();
		if (CanPickCopter && dbl_random < dblCopterRate)
			return AircraftType.Copter;		
		if (dbl_random < dblCopterRate + dblPropRate)
			return AircraftType.Propeller;
		else if (dbl_random < dblCopterRate + dblPropRate + dblLinerRate)
			return AircraftType.Liner;
		else
			return AircraftType.Supersonic;
	}

	private function playLevel()
	{
		if (isLoadingLevel) return;
		isLoadingLevel = true;
		
		initLevel();
		loadLevel();
	}	

	private function prepareGameStart()
    {
		ControlDispatcher.CurrentDisplayMode = DisplayMode.Play;
				
		for(var i: int = 0; i < apAirport.CloudProbability / DBL_CLOUD_QUANTITY_RATE; i++)
			emitCloud(false);
		
		HintPanelView.show();
		
		isLoadingLevel = false;
	}

	private function resume(): void
	{
		FSimulationRate = 1;
	}

    private function select(APoint:Point, IsDoubleClicked: Boolean): void
    {
		for each(var aircraft: Aircraft in apAirport.Aircrafts)
		{
			if (!aircraft.inArea(APoint) || aircraft.State == AircraftState.TakingOff) continue;

			if (!IsDoubleClicked && aircraft.State.IsComing)
			{
				isNewPath = true;
				isCreatingPath = true;
				dtWaypointCreated = new Date();
			}
			
			selectAircraft(aircraft);
			
			if (IsDoubleClicked)
				aircraft.depart();
			
			return;
		}
		
		if (plSelectedAircraft == null) return;
		
		for each (var airfield: IAirfield in apAirport.Airfields)
		{
			if (!airfield.inArea(APoint)) continue;
			
			selectAirfield(airfield);
			return;
		}		
    }

	private function selectAircraft(AnAircraft: Aircraft): void
	{
		deselect(true, true);
		
		AnAircraft.Selected = true;					
		plSelectedAircraft = AnAircraft;
		
		if (plSelectedAircraft.TargetAirfield != null && AnAircraft.State == AircraftState.Directed || AnAircraft.State == AircraftState.Landing)
			selectAirfield(plSelectedAircraft.TargetAirfield);
	}

	private function selectAirfield(AnAirfield: IAirfield): void
	{
		//Если самолет на земле, то не направляем его на ВВП если: самолет уже покинул гейт или гейт не относится к этой полосе		 
		if (!plSelectedAircraft.State.IsComing && (!plSelectedAircraft.OccupiedGate || !plSelectedAircraft.OccupiedGate.isHostedBy(AnAirfield))) return;

		deselect(false, true);		
							
		AnAirfield.Selected = true;					
		rwSelectedAirfield = AnAirfield;
		
		plSelectedAircraft.TargetAirfield = AnAirfield;		
	}

	private function startLevel()
	{
		initLevel();
		ControlDispatcher.CurrentDisplayMode = DisplayMode.LevelStartBanner;
	}
	
	private function traceObjectInfo(): Boolean
	{
		var is_traced: Boolean = false;
		if (plSelectedAircraft)
		{
			trace(plSelectedAircraft);
			is_traced = true;
		}
		if (rwSelectedAirfield)
		{
			trace(rwSelectedAirfield);
			is_traced = true;			
		}
		
		return is_traced;
	}	
	
	//event handlers
	private function Airport_OnGateLoaded(AnEvent: Event): void
	{
		var gate: Gate = Gate(ObjectEvent(AnEvent).SourceObject)
		if (!gate.Free)
		{
			var aircraft: Aircraft = createAircraft((gate is Helipad) ? AircraftType.Copter : pickAircraftType(false),
				gate.Location, new Angle(), apAirport, AircraftState.PreparingToTakeoff, Math.random(), gate);
			
			apAirport.Aircrafts.push(aircraft);
		}
	}	
	
	private function Airport_OnLevelLoaded(AnEvent: Event):void {
		prepareGameStart();
	}

	private function FrameBuilder_BeforeRescale(AnEvent: Event):void {
		fixAirportRect(apAirport.Extent.Width / FrameBuilder.GameZoneRect.Extent.Width, apAirport.Extent.Height / FrameBuilder.GameZoneRect.Extent.Height);	
	}

	private function Aircraft_OnLanded(AnEvent: ObjectEvent):void 
	{
		++FLandingsDone;
		GameProgress.addPoints(int((AnEvent.SourceObject as Aircraft).Fuel*N_FULL_TANK_POINTS));
	}

	private function HintPanelView_OnHiding(AnEvent: Event):void 
	{
		Core.resume();
	}
	
	private function HintPanelView_OnShown(AnEvent: Event):void 
	{
		Core.suspend();
	}	

	private function URLLoader_OnComplete(AnEvent: Event): void
	{
		loadLevelCont();
	}	
}
}