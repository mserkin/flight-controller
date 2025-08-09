package ap.basic {

///////////////////////////////////////////////////////////
//  Region.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments;

//Rect с Location в центре, повернутый на угол Rotation
public class Region extends Rect 
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
	private var FRotation: Angle;    
	
	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties
	public override function get Center(): Point
	{
		return this.Location.clone();
	}
	
	public override function get CornerPoints(): Vector.<Point>
	{
		var apnt: Vector.<Point> = new Vector.<Point>(4, true);
		for (var i_height: int = -1; i_height <= 1; i_height+=2)
		{
			for (var i_width: int = -1; i_width <= 1; i_width+=2)	
			{
				var pnt_corner: Point = new Point(Extent.Width/2*i_width, Extent.Height/2*i_height); 
				//var ang_fix: Angle = new Angle(pnt_corner.Theta.Radian - Math.PI / 2 * i_width); 
				pnt_corner.Theta = pnt_corner.Theta.add(FRotation);
				pnt_corner.X += Location.X;
				pnt_corner.Y += Location.Y;
				apnt[(i_width + 1)/2 + i_height + 1] = pnt_corner;
			}
		}
		return apnt;
	}

	public function get Rotation(): Angle
    {
    	return FRotation;
    }

//methods
	//constructor
	public function Region(ALocation: Point = null, ASize: Size = null, ARotation: Angle = null)
	{
		if (!ALocation) ALocation = new Point();
		if (!ASize) ASize = new Size();
		if (!ARotation) ARotation = new Angle();
		
		super(ALocation, ASize);
		FRotation = ARotation;		
	}

	//public methods
	
	public function cloneRegion(): Region
    {
		return new Region(Location.clone(), Extent.clone(), FRotation.clone());
    }	
	
	public function inArea(APoint:Point)
    {
		var point: Point =  APoint.sub(this.Location);
		var ang_theta: Angle = point.Theta;
		point.Theta = ang_theta.sub(Rotation);
		return Math.abs(point.Y) < this.Extent.Height / 2 && Math.abs(point.X) < this.Extent.Width / 2;
	}

	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		return str_indent + "[Region]\n"
			+ str_indent + "{\n"
			+ super.toString(AnIndent + 1) 
			+ str_indent_plus + "Rotation=\n" + FRotation.toString(AnIndent + 2)
			+ str_indent + "}\n";	
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