package ap.views {

///////////////////////////////////////////////////////////
//  AirportView.as
///////////////////////////////////////////////////////////

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import ap.basic.*;
import ap.basic.Size;
import ap.controllers.ControlDispatcher;
import ap.enumerations.Colors;
import ap.enumerations.Keys;
import ap.instrumental.Instruments;
import ap.instrumental.Profiler;
import ap.instrumental.ScreenManager;
import ap.model.Airport;
import ap.model.Cloud;
import ap.model.Gate;

public class AirportView //static
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
	static private const DBL_EDIT_GATE_SIZE: Number = 24; //abs?
	static private const DBL_GAME_GATE_SIZE: Number = 9.6; //abs?
	//static private const DBL_SNOW_SPEED: Number = 0.3;
	//static private const N_MAX_SNOW_SHIFT: Number = 2.5; //abs?
	
	//property fields

	//other fields
	static private var apAirport: Airport = null;
	//static private var dblSnowShift: Number = 0;
	static private var isGateIdsShown: Boolean = false;
//properties
/*
	public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}
*/
//methods

	//public methods

	static public function display(AnAirport: Airport, ToShowAircrafts: Boolean)
	{
		Profiler.checkin("airport");
		apAirport = AnAirport;
		
		displayAprons(AnAirport.Aprons);
		
		AirfieldView.display(AnAirport.Airfields);
		
		displayGates(AnAirport.Gates);
		
		if (ToShowAircrafts)
		{
			AircraftView.display(AnAirport.Aircrafts);
		}
		
		displayClouds(AnAirport.Clouds);
		Profiler.checkout("airport");
	}	

	static public function processEvent(AnEvent: Event): Boolean
	{
		if (AnEvent is MouseEvent)
		{
			var mouse_event: MouseEvent = MouseEvent(AnEvent);
			var point: Point = new Point(mouse_event.stageX, mouse_event.stageY);
			var pnt_airport_pos: Point = FrameBuilder.convertToModelPoint(point);
			processMouseEvent(mouse_event, pnt_airport_pos);

		}
		else if (AnEvent is KeyboardEvent)
		{
			processKeyboardEvent(KeyboardEvent(AnEvent));
		}

		return false;
	}	
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function displayAprons(AnApronsVector: Vector.<SelectableObject>) 
	{
		Profiler.checkin("aprons");
		//отображение апронов
		for each (var apron: SelectableObject in AnApronsVector)
		{
			ScreenManager.displayImage(apron.Selected ? new ApronSelectedImage() : new ApronImage(), FrameBuilder.convertToScreenRect(apron), apron.Course);
		}
		Profiler.checkout("aprons");
	}	

	static private function displayClouds(ACloudsVector: Vector.<Cloud>)
	{
		Profiler.checkin("clouds");
		for each (var cloud: Cloud in ACloudsVector)
		{		
			var rect_cloud: Rect = FrameBuilder.convertToScreenRect(cloud);
			var do_cloud: DisplayObject;
			switch(cloud.Density)
			{
				case 1: do_cloud = new CloudImage1(); break;
				case 2: do_cloud = new CloudImage2(); break;
				case 3: do_cloud = new CloudImage3(); break;
				case 4: do_cloud = new CloudImage4(); break;
			}
			ScreenManager.displayImage(do_cloud, rect_cloud, cloud.Course);		
			
			/*
			if (cloud.Density == Cloud.N_SNOW_CLOUD_DENSITY)
			{
				dblSnowShift += DBL_SNOW_SPEED;
				if (dblSnowShift > N_MAX_SNOW_SHIFT) dblSnowShift = 0;
				rect_cloud.Location.X += DBL_SNOW_SPEED * Instruments.randomSign();
				rect_cloud.Location.Y += dblSnowShift;
				ScreenManager.displayImage(new SnowImage(), rect_cloud, cloud.Course);		
			}
			*/
		}	
		Profiler.checkout("clouds");		
	}
	
	static private function displayGates(AGatesVector: Vector.<Gate>)
	{
		Profiler.checkin("gates");
		for each (var gate: Gate in AGatesVector)
		{
			var obj_gate_size: Object = {};
			var do_gate_image: DisplayObject = getGateImage(gate, obj_gate_size);
			var dbl_gate_img_size: Number = obj_gate_size.ImageSize;
					
			var rect_gate: Rect = FrameBuilder.convertToScreenRect(gate);
			rect_gate.Extent = new Size(dbl_gate_img_size, dbl_gate_img_size);
			ScreenManager.displayImage(do_gate_image, rect_gate, new Angle());		

			if (isGateIdsShown)
			{
				//отображение id гейта
				ScreenManager.displayText(gate.Id, new Rect(rect_gate.Location, new Size(-1, -1)), 
					FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_TINY), Colors.Blue);		
			}

		}
		Profiler.checkout("gates");		
	}
	
	static private function getGateImage(AGate: Gate, AnImageSizeObject: Object): DisplayObject
	{
		if (ControlDispatcher.ActiveController.getControllerType() == 1)
		{
			AnImageSizeObject.ImageSize = FrameBuilder.adaptToFrame(DBL_EDIT_GATE_SIZE);
			if (AGate.Selected) 
			{
				if (AGate.Free) 
				{
					return new GateFreeSelectedEditImage();
				} 
				else 
				{
					return new GateOccupiedSelectedEditImage();
				}
			} 
			else 
			{
				if (AGate.Free) 
				{
					return new GateFreeEditImage();
				} 
				else 
				{
					return new GateOccupiedEditImage();
				}
			}
		}
		else
		{
			AnImageSizeObject.ImageSize = FrameBuilder.adaptToFrame(DBL_GAME_GATE_SIZE);
			if (AGate.Free) 
			{
				return new GateFreeImage();
			} 
			else 
			{
				return new GateOccupiedImage();
			}
		}
	}	

	static private function processKeyboardEvent(AnEvent: KeyboardEvent)
	{
		switch(AnEvent.type)
		{
			case KeyboardEvent.KEY_DOWN:
				if (AnEvent.keyCode == Keys.O)
				{
					FrameBuilder.PerformanceCounterShown = true;
					return true;
				}
				break;
				
			case KeyboardEvent.KEY_UP:
				switch (AnEvent.keyCode)
				{
					case Keys.G:
						toggleGateIds();
						return true;
						
					case Keys.O:
						FrameBuilder.PerformanceCounterShown = false;
						return true;
						
					default:
						return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_AIRPORT_KEY_PRESSED, 
							{KeyCode: AnEvent.keyCode});
				}					
				break;
		}
	}
	
	static private function processMouseEvent(AnEvent: MouseEvent, APosition: Point)
	{
		switch(AnEvent.type)
		{
			case MouseEvent.CLICK:
				if (AnEvent.stageX > FrameBuilder.GameZoneRect.Extent.Width - 10 
					&& AnEvent.stageY > FrameBuilder.GameZoneRect.Extent.Height - 10)
				{
					return ControlDispatcher.dispatchViewEvent(
						ControlDispatcher.N_EDITOR_CORNER_CLICK);					
				}	
				break;
			case MouseEvent.DOUBLE_CLICK:
				return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_AIRPORT_DOUBLE_CLICK, 
					{Position: APosition});
				
			case MouseEvent.MOUSE_DOWN:
				return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_AIRPORT_MOUSE_DOWN, 
					{Position: APosition});

			case MouseEvent.MOUSE_MOVE:
				if (apAirport) 
				{
					var pnt_in_airport: Point = apAirport.moveToRect(APosition);
					return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_AIRPORT_MOUSE_MOVE, 
						{Position: pnt_in_airport});
				}
				break;
			case MouseEvent.MOUSE_UP:
				return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_AIRPORT_MOUSE_UP, 
					{Position: APosition});						
		}
	}
	
	static private function toggleGateIds()
	{
		isGateIdsShown = !isGateIdsShown;
	}
	
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
