package ap.basic {

///////////////////////////////////////////////////////////
//  SelectableObject.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments;

//Выделяемый Region с Location в центре
public class SelectableObject extends Region 
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
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/
	
	//property fields
    private var FSelected: Boolean = false;
	
	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	public function get Course(): Angle
    {
    	return this.Rotation;
    }

    public function get Selected(): Boolean
    {
    	return FSelected;
    }

    public function set Selected(IsSelected:Boolean)
    {
		FSelected = IsSelected;
    }

//methods
	//constructor
	public function SelectableObject(ALocation: Point, ASize: Size, ACourse:Angle)
	{
		super(ALocation, ASize, ACourse);	
	}

	//public methods
	
	public function cloneObject(): SelectableObject
    {
		var mo: SelectableObject = new SelectableObject(Location.clone(), Extent.clone(), Course.clone());
		mo.Selected = FSelected;
		return mo;
    }	
	
	static public function fromXml(AnXml: XML)
	{
		var x: int = AnXml.@x;
		var y: int = AnXml.@y;
		var cx: int = AnXml.@width;
		var cy: int = AnXml.@height;
		var n_course: int = AnXml.@course;

		return new SelectableObject(new Point(x, y), new Size(cx, cy), new Angle(n_course, Angle.DEGREE));
	}

	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		return str_indent + "[SelectableObject]\n"
			+ str_indent + "{\n"
			+ super.toString(AnIndent + 1) 
			+ str_indent_plus + "Course=\n" + Course.toString(AnIndent + 2)
			+ str_indent_plus + "Selected=" + FSelected + "\n"
			+ str_indent + "}\n";	
	}
	
	public override function toXml(AnXmlNode: XML)
	{
		super.toXml(AnXmlNode);
		AnXmlNode.@course = Course.Degree;
	}	

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