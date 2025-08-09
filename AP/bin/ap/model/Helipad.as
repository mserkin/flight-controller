package ap.model {

///////////////////////////////////////////////////////////
//  Helipad.as
///////////////////////////////////////////////////////////

import ap.basic.*;
import ap.instrumental.Instruments;

public class Helipad extends Gate implements IAirfield
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
	private const DBL_HELIPAD_LENGTH: Number = 1000;
	private const DBL_HELIPAD_WIDTH: Number = DBL_HELIPAD_LENGTH;

	//property fields
	private var FActiveCourse: Angle = new Angle(0, Angle.RADIAN);
	private var FOccupiedBy: Aircraft;
	
	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties
	public function get ActiveCourse(): Angle
	{
		return FActiveCourse;
	}

	public function get BackCourseLightsDistance(): Number {return -1};

	public function get CourseLightsDistance(): Number {return -1};
	
	public function get Gates(): Vector.<Gate>
	{
		var vector: Vector.<Gate> = new Vector.<Gate>(1);
		vector[0] = this;
		return (vector);
	}

	public function get IsRunway(): Boolean
	{
		return false;
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
		return null;
	}
	
	public function get Width(): Number
	{
		return Extent.Width;
	}

//methods
	//constructor
    public function Helipad(AnId: String, ALocation: Point, IsFree: Boolean)
    {
		super(AnId, ALocation, IsFree);
		Extent = new Size(DBL_HELIPAD_WIDTH, DBL_HELIPAD_LENGTH);
		associate(this);
    }

	//public methods

	public function exchangeGate(AGate: Gate, ALocation: Point): Gate
	{
		return AGate;
	}

	public override function free(AnAircraft: Aircraft): void
	{
		FOccupiedBy = null;
		super.free(AnAircraft);
	}

	static public function fromXml(AnXml: XML): Helipad
	{

		var obj_gate_props: Object = Gate.getGatePropsFromXml(AnXml);	
		return new Helipad(obj_gate_props.Id, obj_gate_props.Location, obj_gate_props.IsFree);
	}
	
	public function getRegion(): Region
	{
		return Region(this);
	}

	public override function isHostedBy(AnAirfield: IAirfield): Boolean
    {
		return this == AnAirfield;
    }

	public function inLandingZone(APoint: Point): Boolean
	{
		return inArea(APoint);
	}
	
	public function occupyToLand(AnAircraft: Aircraft): Gate
	{
		if (FOccupiedBy != null) return null;
		
		occupy();
		FOccupiedBy = AnAircraft;
		FActiveCourse = Angle.direction(AnAircraft.Location, this.Location, {});

		return this;
	}		
		
	public function occupyToTakeoff(AnAircraft: Aircraft): Boolean
	{
		if (FOccupiedBy != null && FOccupiedBy != AnAircraft) return false;
		
		FOccupiedBy = AnAircraft;
		return true;		
	}

	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		
		return str_indent + "[Helipad]\n" 
			+ str_indent + "{\n"
			+ super.toString(AnIndent + 1)
			+ str_indent_plus + "Id=" + Id + "\n"
			+ str_indent_plus + "Free=" + Free + "\n"
			+ str_indent + "}\n";	
	}

	public override function toXml(AnXmlNode: XML)
	{
		super.toXml(AnXmlNode);
	}	
	
	public function updateWind(AWindDirection: Angle)
	{
	}
	
	//protected methods

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