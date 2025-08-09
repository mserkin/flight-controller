package ap.basic {

///////////////////////////////////////////////////////////
//  Rect.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments;

public class Rect extends Object
{
//public fields & consts		

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields

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
	private var FExtent: Size;
	private var FLocation: Point;

	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	public function get Center(): Point 
	{
		return new Point(FLocation.X + FExtent.Width / 2, FLocation.Y + FExtent.Height / 2);
	}
	
	public function get CornerPoints(): Vector.<Point>
	{
		var apnt: Vector.<Point> = new Vector.<Point>(4, true);
		for (var i_height: int = 0; i_height <= 1; i_height++)
		{
			for (var i_width: int = 0; i_width <= 1; i_width++)	
			{
				var pnt_corner: Point = new Point(Location.X + Extent.Width*i_width, 
					Location.Y + Extent.Height*i_height); 
				apnt[i_width + i_height*2] = pnt_corner;
			}
		}
		return apnt;
	}

    public function get Extent(): Size
    {
    	return FExtent;
    }

	public function set Extent(AValue: Size)
    {
   		FExtent = AValue.clone();
    }
	
    public function get Location(): Point
    {
    	return FLocation;
    }
	
	public function set Location(AValue: Point)
    {
   		FLocation = AValue.clone();
    }
	
//methods
	//constructor
    public function Rect(ALocation: Point = null, AnExtent: Size = null)
    {
		if (!ALocation) ALocation = new Point();
		this.Location = ALocation;
		if (!AnExtent) AnExtent = new Size();
		this.Extent = AnExtent;
    }	

	//public methods
	
	public function clone(): Rect
    {
		return new Rect(FLocation.clone(), FExtent.clone());
    }
	
	public function isInside(APoint: Point): Boolean
	{
		return ((APoint.X > FLocation.X) && (APoint.X < FLocation.X + FExtent.Width) && (APoint.Y > FLocation.Y) && (APoint.Y < FLocation.Y + FExtent.Height));
	}
	
	public function moveToRect(APoint: Point): Point
	{
		var pnt_result: Point = new Point();
		pnt_result.X = (APoint.X < FLocation.X) ? FLocation.X : 
			((APoint.X > FLocation.X + FExtent.Width) ? FLocation.X + FExtent.Width : APoint.X);
		pnt_result.Y = (APoint.Y < FLocation.Y) ? FLocation.Y : 
			((APoint.Y > FLocation.Y + FExtent.Height) ? FLocation.Y + FExtent.Height : APoint.Y);
		return pnt_result;
	}

    public function toString(AnIndent: int = 0): String
    {
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		return str_indent + "[Rect]\n"
			+ str_indent + "{\n"
			+ str_indent_plus + "Extent=\n" 
			+ FExtent.toString(AnIndent + 2)
			+ str_indent_plus + "Location=\n" 
			+ FLocation.toString(AnIndent + 2)
			+ str_indent + "}\n";	
	}
	
	public function toXml(AnXmlNode: XML)
	{
		AnXmlNode.@x = Location.X;
		AnXmlNode.@y = Location.Y;
		AnXmlNode.@width = Extent.Width;
		AnXmlNode.@height = Extent.Height;
	}	
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

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