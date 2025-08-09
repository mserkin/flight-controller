package ap.model {

///////////////////////////////////////////////////////////
//  Gate.as
///////////////////////////////////////////////////////////

import ap.basic.*;
import ap.instrumental.Instruments;

public class Gate extends SelectableObject
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
	private const DBL_SELECT_RADIUS: Number = 400;

	//property fields
    private var FFree: Boolean;
    private var FId: String;	

	//other fields
	private var arwHostingAirfields: Vector.<IAirfield> = new Vector.<IAirfield>();
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

    public function get Free(): Boolean
    {
    	return FFree;
    }

    public function get HostingAirfield(): IAirfield
    {
		for each (var airfield: IAirfield in arwHostingAirfields)
		{
			if (!airfield.Occupied) return airfield; 
		}
    	return arwHostingAirfields[0];
    }

    public function get Id(): String
    {
    	return FId;
    }

//methods
	//constructor
    public function Gate(AnId: String, ALocation: Point, IsFree: Boolean)
    {
		super(ALocation, new Size(0, 0), new Angle());
		FId = AnId;
		FFree = IsFree;
    }

	//public methods

    public function associate(AHostingAirfield: IAirfield): void
    {
		arwHostingAirfields.push(AHostingAirfield);
	}

    public function free(AnAircraft: Aircraft): void
    {
		FFree = true;
    }
    
	static public function fromXml(AnXml: XML): Gate
	{
		var obj_gate_props: Object = getGatePropsFromXml(AnXml);	
		return new Gate(obj_gate_props.Id, obj_gate_props.Location, obj_gate_props.IsFree);
	}	
	
    public override function inArea(APoint:Point)
    {
		var point: Point = APoint.sub(Location);
		return point.Radius < DBL_SELECT_RADIUS;
	}
	
	public function isHostedBy(AnAirfield: IAirfield): Boolean
    {
		for each (var airfield: IAirfield in arwHostingAirfields)
			if (airfield == AnAirfield) return true;

		return false;
    }

    public function occupy(): Boolean
    {
		var is_free: Boolean = FFree;
		FFree = false;
		return is_free;
	}

	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		
		return str_indent + "[Gate]\n" 
			+ str_indent + "{\n"
			+ super.toString(AnIndent + 1)
			+ str_indent_plus + "Id=" + FId + "\n"
			+ str_indent_plus + "Free=" + FFree + "\n"
			+ str_indent + "}\n";	
	}

	public override function toXml(AnXmlNode: XML)
	{
		super.toXml(AnXmlNode);
		
		AnXmlNode.@free = FFree;
		AnXmlNode.@id = FId;
	}	

	//protected methods

	static protected function getGatePropsFromXml(AnXml: XML): Object
	{		
		var obj_props: Object = {Id: "", Location: new Point(0, 0), IsFree: true};
		obj_props.Id = AnXml.@id;					
		obj_props.Location.X = AnXml.@x;
		obj_props.Location.Y = AnXml.@y;
		var str_free: String = AnXml.@free;
		obj_props.IsFree = Instruments.str2Bool(str_free);
		return obj_props;
	}

	//private methods


	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}