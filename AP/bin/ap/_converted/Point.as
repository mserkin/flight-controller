package ap.basic {
///////////////////////////////////////////////////////////
//  Point.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments;

public class Point
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
	public var FX: Number;
	public var FY: Number;

	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties	
	public function get Radius(): Number
	{
		return Math.sqrt(FX*FX + FY*FY);
	}		

	public function set Radius(AValue: Number)
	{
		fromPolar(AValue, this.Theta);
	}		
	
	public function get Theta(): Angle
	{
		if (FY == 0) 
			return new Angle(Math.PI/2 * Instruments.sign(FX), Angle.RADIAN);
		else
		{
			var ang_theta: Angle = Angle.arctg(-FX/FY);
			if (FY > 0)
			{
				ang_theta.dec(Angle.PI);
			}
			return ang_theta;
		}
	}

	public function set Theta(AValue: Angle)
	{
		fromPolar(this.Radius, AValue);
	}	

	public function get X(): Number
	{
		return FX;
	}		

	public function set X(AValue: Number)
	{
		FX = AValue;
	}		

	public function get Y(): Number
	{
		return FY;
	}		

	public function set Y(AValue: Number)
	{
		FY = AValue;
	}			

//methods
	//constructor
	public function Point(AnX: Number = 0, AnY: Number = 0)
	{
		FX = AnX;
		FY = AnY;
	}

	//public methods
	
    public function add(APoint: Point): Point
    {
		return new Point(FX + APoint.X, FY + APoint.Y);
    }

	public function clone(): Point
	{
		return new Point(FX, FY);
	}

	public function fromPolar(ARadius: Number, ATheta: Angle)
	{
		FX = ARadius * ATheta.sin();
		FY = -ARadius * ATheta.cos();
	}
		
    public function sub(APoint: Point): Point
    {
		return new Point(FX - APoint.X, FY - APoint.Y);
    }
	
    public function toString(AnIndent: int = 0): String
    {
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		return str_indent + "[Point]\n" 
			+ str_indent + "{\n"
			+ Instruments.stringOfChar("\t", AnIndent + 1) + "X=" + FX + "\n"
			+ Instruments.stringOfChar("\t", AnIndent + 1) + "Y=" + FY + "\n"
			+ str_indent + "}\n";
    }	
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}