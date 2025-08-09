///////////////////////////////////////////////////////////
//  Runway.as
///////////////////////////////////////////////////////////

package ap.model 
{

import ap.basic.*;
import ap.instrumental.Instruments;

public class Runway extends SelectableObject implements IAirfield
{
//public fields & consts		

	//public consts  

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
	private const DBL_DEFAULT_LENGTH: Number = 4000;
	private const DBL_LANDING_ZONE_WIDTH_RATIO = 0.7;
	private const DBL_WIDTH: Number = 700;
	
	//property fields
	private var FActiveCourse: Angle;
	private var FBackCourseLightsDistance: Number = 0;
	private var FCourseLightsDistance: Number = 0;
	private var FGates: Vector.<Gate> = new Vector.<Gate>();
	private var FOccupiedBy: Aircraft;
	private var FUpwindCourse: Angle;	
	
	//other fields
	private var angWindDirection: Angle;
	
//properties

	public function get ActiveCourse(): Angle
	{
		return FActiveCourse;
	}

	public function get BackCourseLightsDistance(): Number
	{
		return FBackCourseLightsDistance;
	}

	public function get CourseLightsDistance(): Number
	{
		return FCourseLightsDistance;
	}
	
	public function get HasFreeGate(): Boolean
	{
		for (var i: int = 0; i < FGates.length; i++)
		{
			if (FGates[i].Free)
				return true;
		}		
		return false;
	}

	public function get Gates(): Vector.<Gate>
	{
		return FGates;
	}
	
	public function get IsRunway(): Boolean
	{
		return true;
	}	
	
	public function get Length(): Number
	{
		return Extent.Height;
	}

	public function get Occupied(): Boolean
	{
		return (FOccupiedBy != null);
	}
	
	public function get OccupiedBy(): Aircraft
	{
		return FOccupiedBy;
	}		

	public function get UpwindCourse(): Angle
	{
		return FUpwindCourse;
	}
	
	public function get Width(): Number
	{
		return Extent.Width;
	}

//methods
	//constructor
	public function Runway(AnXml: XML, AnAirport: Airport)
	{
		var x: int = 0;
		var y: int = 0;
		var cy_length: int = DBL_DEFAULT_LENGTH;
		var ang_course: Angle = new Angle();
		
		if (AnXml)
		{
			x = AnXml.@x;
			y = AnXml.@y;
			cy_length = AnXml.@length;
			ang_course.Degree = AnXml.@course;
			var dbl_course_lights_dist: Number = AnXml.@courseLights;
			var dbl_backcourse_lights_dist: Number = AnXml.@backcourseLights;
			if (dbl_course_lights_dist) FCourseLightsDistance = AnXml.@courseLights;
			if (dbl_backcourse_lights_dist) FBackCourseLightsDistance = AnXml.@backcourseLights;
					
			loadGatesFromXml(AnXml.gates[0], AnAirport);
		}
		
		super(new Point(x, y), new Size(DBL_WIDTH, cy_length), ang_course);
		
		FActiveCourse = Course;
	}

	//public methods

	public function exchangeGate(AGate: Gate, ALocation: Point): Gate
	{
		var dbl_min_dist: Number = Number.MAX_VALUE;
		var gt_nearest: Gate;
		for each(var gate: Gate in FGates)
		{
			if (!gate.Free && gate != AGate) continue;
			
			var pnt_rel: Point = ALocation.sub(gate.Location);
			var dbl_dist: Number = Math.max(Math.abs(pnt_rel.X), Math.abs(pnt_rel.Y));
			if (dbl_dist < dbl_min_dist)
			{
				dbl_min_dist = dbl_dist;
				gt_nearest = gate;
			}
		}
		
		if (gt_nearest && gt_nearest != AGate) 
		{
			AGate.free(null);
			gt_nearest.occupy();
			return gt_nearest;
		}
		else
			return AGate;
	}

	public function free(AnAircraft: Aircraft): void
	{
		if (AnAircraft == FOccupiedBy)
			FOccupiedBy = null;
	}

	public function getDistanceToCenterline(APoint: Point)
	{
		var point: Point =  APoint.sub(this.Location);
		var ang_theta: Angle = point.Theta;
		point.Theta = ang_theta.sub(Course);
		return Math.abs(point.X);
	}
		
	public function getRegion(): Region
	{
		return Region(this);
	}	
	
	public function inLandingZone(APoint: Point): Boolean
	{
		var mo_landing_zone: SelectableObject =  cloneObject();
		mo_landing_zone.Extent.Width *= DBL_LANDING_ZONE_WIDTH_RATIO;
		return mo_landing_zone.inArea(APoint);
	}		
		
	public function occupyToLand(AnAircraft:Aircraft): Gate
	{
		if (FOccupiedBy != null) return null;
		
		var gate: Gate = null;
		
		for each (var gt: Gate in FGates)
		{
			if (gt.Free) 
			{
				gate = gt;
				break;
			}
		}

		if (gate != null)
		{
			gate.occupy();
			FOccupiedBy = AnAircraft;
			FActiveCourse = chooseRunwayCourse(Angle.direction(AnAircraft.Location, this.Location, {}));
			//trace('!!!FActiveCourse=' + FActiveCourse.Degree);
		}
		return gate;
	}

	public function occupyToTakeoff(AnAircraft: Aircraft): Boolean
	{
		if (FOccupiedBy != null) return false;
		
		FOccupiedBy = AnAircraft;
		FActiveCourse = FUpwindCourse;
		return true;
	}

	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);		
		return str_indent + "[Runway]\n" 
			+ super.toString(AnIndent + 1) 
			+ str_indent_plus + "ActiveCoure=" + FActiveCourse + "\n"
			+ str_indent_plus + "FOccupiedBy=" + FOccupiedBy + "\n"
			+ str_indent + "}\n";	
	}

	public override function toXml(AnXmlNode: XML)
	{
		super.toXml(AnXmlNode);
		
		AnXmlNode.@length = Extent.Height;
			
		var xml_gates: XML = new XML('<gates></gates>');
		AnXmlNode.appendChild(xml_gates);
			
		for each (var gate: Gate in Gates)
		{
			var xml_gate: XML = new XML('<gate></gate>');
			xml_gates.appendChild(xml_gate);
			xml_gate.@ref = gate.Id;
		}
	}

	public function updateWind(AWindDirection: Angle)
	{
		angWindDirection = AWindDirection;
		FUpwindCourse = chooseRunwayCourse(angWindDirection.sub(Angle.PI));	
	}
		
	//protected methods

	//private methods
	
	private function chooseRunwayCourse(AReferenceCourse: Angle)
	{
		var ang_course: Angle = this.Course.clone();
		if (AReferenceCourse.sub(ang_course).abs().Radian > Math.PI / 2)
		{
			ang_course.dec(Angle.PI);								
		}
		return ang_course;
	}	
	
	private function loadGatesFromXml(AGatesNode: XML, AnAirport: Airport)
	{
		for each (var xml_gate: XML in AGatesNode.gate)
		{
			var str_id: String = xml_gate.@ref;

			var gate: Gate = AnAirport.findGate(str_id);
			
			if (gate)
			{
				gate.associate(this);
				FGates.push(gate);
			}
		}
	}
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
