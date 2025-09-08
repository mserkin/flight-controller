package ap.basic {
///////////////////////////////////////////////////////////
//  Angle.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments;

public class Angle
{
//public fields & consts		

	//public consts
	static public const DEGREE: int = 1;
	static public const RADIAN: int = 0;

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
	private const DBL_ROTATION_ERROR: Number = Math.PI /  90;

	//property fields
    private var FValue: Number = 0; //radians

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/
	
//properties

    public function get Degree(): Number
    {
    	return FValue / Math.PI * 180;
    }

    public function set Degree(AValue:Number)
    {
		this.Radian = AValue / 180 * Math.PI;
    }

	static public function get PI(): Angle
	{
		return new Angle(Math.PI, RADIAN);
	}

    public function get Radian(): Number
    {
    	return FValue;
    }

	public function set Radian(AValue:Number)
    {
		FValue = AValue;
		normalize();
    }
	
//methods
	//constructor
	function Angle(AValue: Number = 0, AUnit: int = RADIAN)
	{
		switch(AUnit)
		{
			case RADIAN: 
				Radian = AValue;
				break;
			case DEGREE:
				Degree = AValue;
				break;
			default:
				throw new Error("Illegal unit:" + AUnit.toString());
		}
	} 

	//public methods
    public function abs(AnAngle:Angle): Angle
    {
		return new Angle(Math.abs(this.Radian), RADIAN);
    }
	
    public function add(AnAngle:Angle): Angle
    {
		return new Angle(this.Radian + AnAngle.Radian, RADIAN);
    }

	static public function arcsin(AValue: Number): Angle
	{
		return new Angle(Math.asin(AValue), RADIAN);
	}

	static public function arctg(AValue: Number): Angle
	{
		return new Angle(Math.atan(AValue), RADIAN);
	}

    public function clone(): Angle
	{
		return new Angle(FValue, RADIAN); 
	}

    public function cos(): Number
    {
		return Math.cos(FValue);
    }

    public function dec(AnAngle:Angle): void
    {
		this.Radian -= AnAngle.Radian;
    }
	
	static public function direction (APointFrom: Point, APointTo: Point, ADistanceObj: Object = null)
	{
		var x_diff: Number = (APointTo.X - APointFrom.X);		
		var y_diff: Number = -(APointTo.Y - APointFrom.Y);
		var dbl_dist: Number = Math.sqrt(x_diff*x_diff + y_diff*y_diff);
		var ang_target: Angle = Angle.arcsin(x_diff/dbl_dist);  	
		if (y_diff < 0) ang_target.Radian = Math.PI - ang_target.Radian;
		
		if (ADistanceObj)
			ADistanceObj.Distance = dbl_dist;
			
		return ang_target;
	}

	//в какую сторону нужно врущаться с текущего угла в AnAngle 
	//1 - по часовой (в сторону увеличения угла)
	//-1 - против часовой (в сторону уменьшения угла)
	//0 - поворот не требуется
	public function getRotation(AnAngle:Angle): int
	{
		var dbl_ang: Number = normalizeAngleValue(AnAngle.Radian - this.Radian);
		if (Math.abs(dbl_ang) < DBL_ROTATION_ERROR)
			return 0;
		else
			return (dbl_ang > 0) ? 1 : ((dbl_ang < 0) ? -1 : 0);
	}
	
    public function inc(AnAngle:Angle): void
    {
		this.Radian += AnAngle.Radian;
    }

    public function sin(): Number
    {
		return Math.sin(FValue);
    }

    public function sub(AnAngle:Angle): Angle
    {
		return new Angle(this.Radian - AnAngle.Radian, RADIAN);
    }
	
	public function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);
		
		return str_indent + "[Angle]\n" 
			+ str_indent + "{\n"
			+ str_indent_plus + "Degree=" + Degree + "\n"
			+ str_indent_plus + "Radian=" + Radian + "\n"
			+ str_indent + "}\n";	
	}	
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	private function normalize()
	{
		FValue = normalizeAngleValue(FValue);
	}
	
	private function normalizeAngleValue(AValue: Number): Number
	{
		var n_sign: int = Instruments.sign(AValue);
		AValue -= Math.floor(Math.abs(AValue / (2 * Math.PI))) * 2 * Math.PI * n_sign;
		if (Math.abs(AValue) >  Math.PI)
			AValue = (2 * Math.PI - Math.abs(AValue)) * n_sign * -1;
		return AValue;
	}	

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}