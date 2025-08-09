package ap.controllers {

import ap.basic.*;
import ap.enumerations.Keys;
import ap.instrumental.Instruments;
import ap.model.Airport;
import ap.model.Gate;
import ap.model.IAirfield;
import ap.model.Runway;

public class EditController implements IController //Singleton
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
	private const DBL_AIRPORT_ZOOM_EXPANSION: Number = 200;
	private const DBL_INITIAL_APRON_HEIGHT: Number = 1200;
	private const DBL_INITIAL_APRON_WIDTH: Number = 3000;
	private const DBL_OBJECT_EXPANSION: Number = 100;	
	private const DBL_OBJECT_MOVE_DISTANCE: Number = 100;
	private const DBL_ROTATE_DEGREE: Number = 10;

	//property fields
	private var FLevelConfig: XML = null;

	//other fields
	private var apAirport: Airport;
	static private var controllerInstance: EditController;
	private var moSelectedObject: SelectableObject = null;
	private var nNewObjectType: int = 0; //0 - ВВП, 1 - апрон, 2 - гейт
	private var isSelectedNew: Boolean = false;

//properties

	public function get LevelConfig(): XML
    {
    	return FLevelConfig; 
    }
		
//methods
	//constructor
	//private constructors not supported by actionscript
	//use getInstance instead!	
   	public function EditController(AnAirport: Airport){
		apAirport = AnAirport;
	}

	//public methods

	public function getControllerType(): int 
	{
		return ControlDispatcher.N_EDIT_CONTROLLER;
	}
	
	static public function getInstance(AnAirport: Airport = null): EditController
	{
		if (!controllerInstance)
		{
			controllerInstance = new EditController(AnAirport);
		}
		return controllerInstance;
	}

	public function processDispatcherEvent(AType: int, AParamObj: Object = null): Boolean
	{
		switch (AType)
		{
			case ControlDispatcher.N_KEY_PRESSED:
				return processKeyPress(AParamObj.KeyCode);
		
			case ControlDispatcher.N_LEVEL_CONFIG_VISIBILITY: 
				if (!FLevelConfig)
				{
					FLevelConfig = generateLevelXML();
				}
				else
				{
					ControlDispatcher.ActiveController = GameController.getInstance();
					FLevelConfig = null;
				}
				return true;
				
			case ControlDispatcher.N_OBJECT_ACTIVATE:
				return select(AParamObj.Position, true);			
		
			case ControlDispatcher.N_OBJECT_INFO:
				return traceObjectInfo();										

			case ControlDispatcher.N_OBJECT_SELECT:
				return select(AParamObj.Position, false);			
		}
		return false;
	}
	
	public function run(): void {} 
	
	public function resizeAirport(IsExpanding: Boolean)
	{
		apAirport.resize(
			new Point(
				apAirport.Location.X + (IsExpanding ? -1 : +1) * DBL_AIRPORT_ZOOM_EXPANSION / 2, 
				apAirport.Location.Y + (IsExpanding ? -1 : +1) * DBL_AIRPORT_ZOOM_EXPANSION / 2
			), 
			new Size(
				apAirport.Extent.Width + (IsExpanding ? +1 : -1) * DBL_AIRPORT_ZOOM_EXPANSION, 
				apAirport.Extent.Height + (IsExpanding ? +1 : -1) * DBL_AIRPORT_ZOOM_EXPANSION
			)
		);
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	private function deleteObject()
	{
		if (!moSelectedObject) return;

		if (moSelectedObject is Runway)
		{
				apAirport.Airfields.splice(apAirport.Airfields.indexOf(moSelectedObject), 1);
		}
		else if (moSelectedObject is Gate)
		{
			for each (var airfield: IAirfield in apAirport.Airfields)
			{
				airfield.Gates.splice(airfield.Gates.indexOf(moSelectedObject), 1);
			}
			apAirport.Gates.splice(apAirport.Gates.indexOf(moSelectedObject), 1);
		}
		else
		{
			apAirport.Aprons.splice(apAirport.Aprons.indexOf(moSelectedObject), 1);
		}
		moSelectedObject = null;
		isSelectedNew = false;
	}

	private function detectClickedAirfield(APoint:Point)
	{
		for each (var airfield: IAirfield in apAirport.Airfields)
		{
			if (!airfield.inArea(APoint)) continue;
			
			return airfield;
		}		
		return null;
	}
	
	private function detectClickedApron(APoint:Point)
	{
		for each (var apron: SelectableObject in apAirport.Aprons)
		{
			if (!apron.inArea(APoint)) continue;
			
			return apron;
		}
		return null;
	}
	
	private function detectClickedGate(APoint:Point)
	{
		for each (var gate: Gate in apAirport.Gates)
		{
			if (!gate.inArea(APoint)) continue;

			return gate;
		}
		return null;
	}

	private function generateLevelXML(): XML
	{
		return apAirport.makeLevelXML();
	}
	
	private function moveObject(ACX: Number, ACY: Number)
	{
		if (!moSelectedObject) return;
		
		moSelectedObject.Location.X += ACX*DBL_OBJECT_MOVE_DISTANCE;
		moSelectedObject.Location.Y += ACY*DBL_OBJECT_MOVE_DISTANCE;
	}

	private function newApron()
	{
		moSelectedObject = new SelectableObject(new Point(0, 0), new Size(DBL_INITIAL_APRON_WIDTH, DBL_INITIAL_APRON_HEIGHT), new Angle());  
		apAirport.Aprons.push(moSelectedObject);
	}

	private function newGate()
	{
		moSelectedObject = new Gate(Instruments.intRandom(), new Point(0, 0), true);
		apAirport.Gates.push(moSelectedObject);
		for each (var airfield: IAirfield in apAirport.Airfields)
		{
			airfield.Gates.push(moSelectedObject);
		}				
	}

	private function newObject()
	{
		if (isSelectedNew)
		{
			var obj_sel = moSelectedObject;
			
			deleteObject();
			
			if (obj_sel is Runway)
				newGate();
			else if (obj_sel is Gate)
				newApron();
			else 
				newRunway();
		}
		if (!obj_sel)
			newRunway();
		
		moSelectedObject.Selected = true;
		isSelectedNew = true;
	}

	private function newRunway()
	{
		var runway: Runway = new Runway(null, apAirport);
		for each (var gate: Gate in apAirport.Gates)
		{
			gate.associate(runway);
			runway.Gates.push(gate);
		}
		apAirport.Airfields.push(runway);			
		moSelectedObject = runway;		
	}	

	private function processKeyPress(AKey: uint): Boolean
	{
		switch (AKey)
		{
			case Keys.INSERT:
				newObject();	
				break;
			case Keys.DELETE:
				deleteObject();	
				break;			
			case Keys.ARROW_DOWN:
				moveObject(0, +1);			
				break;
			case Keys.ARROW_LEFT:
				moveObject(-1, 0);			
				break;		
			case Keys.ARROW_RIGHT:
				moveObject(+1, 0);			
				break;		
			case Keys.ARROW_UP:
				moveObject(0, -1);			
				break;
			case Keys.TAB:
				toggleObject();		
				break;		
			case Keys.A:
				resizeObject(-1, 0);
				break;
			case Keys.D:
				resizeObject(+1, 0);
				break;
			case Keys.S:
				resizeObject(0, -1);		
				break;					
			case Keys.W:
				resizeObject(0, +1);
				break;			
			case Keys.X:
				resizeAirport(true);
				break;		
			case Keys.Z:
				resizeAirport(false);
				break;				
			case Keys.BROCKET_LEFT:
				rotateObject(false);					
				break;		
			case Keys.BROCKET_RIGHT:
				rotateObject(true);					
				break;
			default:
				return false;
		}
		return true;
	}	
	
	private function resizeObject(ACX: Number, ACY: Number)
	{
		if (!moSelectedObject) return;
		
		if (!(moSelectedObject is Gate) && !(moSelectedObject is Runway))
			moSelectedObject.Extent.Width += ACX*DBL_OBJECT_EXPANSION;
		if (!(moSelectedObject is Gate))
			moSelectedObject.Extent.Height += ACY*DBL_OBJECT_EXPANSION;
	}
	
	private function rotateObject(IsClockwise: Boolean)
	{
		moSelectedObject.Course.Degree += IsClockwise ? DBL_ROTATE_DEGREE : -DBL_ROTATE_DEGREE;
	}
	
    private function select(APoint:Point, IsDoubleClicked: Boolean): void
    {
		if (moSelectedObject)
		{
			moSelectedObject.Selected = false;
			moSelectedObject = null;
			isSelectedNew = false;			
		}

		moSelectedObject = detectClickedAirfield(APoint);
		if (!moSelectedObject) moSelectedObject = detectClickedGate(APoint);
		if (!moSelectedObject) moSelectedObject = detectClickedApron(APoint);
		
		if (moSelectedObject)
			moSelectedObject.Selected = true;
    }
    
    private function toggleObject()
	{
		if (!moSelectedObject || !(moSelectedObject is Gate)) return;

		var gate: Gate = Gate(moSelectedObject);
		if (gate.Free)
			gate.occupy();
		else
			gate.free(null);
	}
	
	private function traceObjectInfo()
	{
		if (moSelectedObject)
		{
			trace(moSelectedObject);
			return true;
		}
		
		return false;
	}

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
