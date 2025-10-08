package ap.views {

///////////////////////////////////////////////////////////
//  AirfieldView.as
///////////////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.Event;
import ap.basic.*;
import ap.controllers.ControlDispatcher;
import ap.instrumental.Profiler;
import ap.instrumental.ScreenManager;
import ap.model.IAirfield;
import ap.model.Runway;

public class AirfieldView //static
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
	//*airfield graphic types
	static private const DBL_RUNWAY_APPROACH_LIGHTS_HEIGHT: Number = 45.0; //abs?
	static private const DBL_RUNWAY_APPROACH_LIGHTS_WIDTH: Number=21.0; //abs?
	static private const DBL_RUNWAY_WIND_LIGHTS_HEIGHT: Number = 4; //abs?
	static private const DBL_RUNWAY_WIND_LIGHTS_WIDTH: Number=10; //abs?
	static private const DBL_WIND_LIGHTS_REL_POS: Number = 0.9; //90% от длины ВПП
	
	//id графики in order of displaying
	static private const RW_GRAPHIC_FRAME: int = 0;
	static private const RW_GRAPHIC_SURFACE: int = 1;
	static private const RW_GRAPHIC_LIGHTS: int = 2;
	static private const RW_GRAPHIC_TYPE_COUNT: int = 3;
	
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
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods

	static public function display(AnAirfieldsVector: Vector.<IAirfield>) 
	{
		Profiler.checkin("airfields");
		for (var i: int = 0; i < RW_GRAPHIC_TYPE_COUNT; i++)
		{
			displayAirfieldGraphic(i, AnAirfieldsVector);
		}
		Profiler.checkout("airfields");
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function displayAirfieldGraphic(AGraphicType: int, AnAirfieldsVector: Vector.<IAirfield>)
	{
		for each (var airfield: IAirfield in AnAirfieldsVector) 
		{
			var rect_scr: Rect = FrameBuilder.convertToScreenRect(airfield.getRegion());
			var sp: Sprite;
			var ang_rotation: Angle = airfield.ActiveCourse;
			
			switch(AGraphicType)
			{
				case RW_GRAPHIC_FRAME:
					sp = getFrameImage(airfield);
					break;
				case RW_GRAPHIC_LIGHTS:
					if (airfield.IsRunway) {
						var dbl_hor_proj: Number = airfield.ActiveCourse.sin();
						var dbl_ver_proj: Number = airfield.ActiveCourse.cos();
						var rw: Runway = Runway(airfield);		
						if (airfield.Occupied) 
							//рисуем огни привода
							displayApproachLights(rw, rect_scr, dbl_hor_proj, dbl_ver_proj);
						if (rw.HasFreeGate)
						{
							displayWindLights(rw, +1, rect_scr, dbl_hor_proj, dbl_ver_proj);
							displayWindLights(rw, -1, rect_scr, dbl_hor_proj, dbl_ver_proj);    
						}
						sp = new RunwayMarkingImage();
					}
					else
					{
						sp = new HelipadMarkingImage();
					}
					break;
				case RW_GRAPHIC_SURFACE:
					sp = airfield.IsRunway ? new RunwaySurfaceImage() : new HelipadSurfaceImage();
					break;
			}
			ScreenManager.displayImage(sp, rect_scr, ang_rotation);
		}
	}

	static private function displayApproachLights(ARunway: Runway, ARunwayScreenRect: Rect, AHorProj: Number, AVertProj: Number)
	{
		var dbl_lights_dist: Number = ARunwayScreenRect.Extent.Height/2 
			+ ((ARunway.ActiveCourse.Radian == ARunway.Course.Radian) 
			? FrameBuilder.convertToScreenLength(ARunway.CourseLightsDistance) : FrameBuilder.convertToScreenLength(ARunway.BackCourseLightsDistance));
	
		ScreenManager.displayImage(
			new RunwayFrontLightsImage(), 
			new Rect(
				new Point(ARunwayScreenRect.Location.X - AHorProj*dbl_lights_dist, ARunwayScreenRect.Location.Y + AVertProj*dbl_lights_dist), 
				new Size(
					FrameBuilder.adaptToFrame(DBL_RUNWAY_APPROACH_LIGHTS_WIDTH), 
					FrameBuilder.adaptToFrame(DBL_RUNWAY_APPROACH_LIGHTS_HEIGHT))
			),
		   ARunway.ActiveCourse
		);
	}		
	
	static private function displayWindLights(ARunway: Runway, ASide: int, ARunwayScreenRect: Rect, AHorProj: Number, AVertProj: Number)
	{
		ScreenManager.displayImage(
			new RunwayWindLightsImage(),
			new Rect(
				new Point(
					ARunwayScreenRect.Location.X + AHorProj * ARunwayScreenRect.Extent.Height/2 * ASide * DBL_WIND_LIGHTS_REL_POS, 
					ARunwayScreenRect.Location.Y - AVertProj * ARunwayScreenRect.Extent.Height/2 * ASide * DBL_WIND_LIGHTS_REL_POS
				), 
				new Size(
					FrameBuilder.adaptToFrame(DBL_RUNWAY_WIND_LIGHTS_WIDTH), 
					FrameBuilder.adaptToFrame(DBL_RUNWAY_WIND_LIGHTS_HEIGHT)
				)
			),
			(ControlDispatcher.ActiveController.getControllerType() == 0) ? ARunway.UpwindCourse : ARunway.Course
		);
	}

	static private function getFrameImage(AnAirfield: IAirfield): Sprite
	{
		return	AnAirfield.Selected 
			? ((AnAirfield.IsRunway) ? new RunwayFrameSelectedImage() : new HelipadFrameSelectedImage()) 
			: ((AnAirfield.IsRunway) ? new RunwayFrameImage() : new HelipadFrameImage());
	}
	
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
