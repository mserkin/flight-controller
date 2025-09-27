package ap.model {

///////////////////////////////////////////////////////////
//  Cloud.as
///////////////////////////////////////////////////////////

import ap.basic.*;
import ap.input.*;
import ap.instrumental.Instruments;

public class Cloud extends SelectableObject
{
//public fields & consts		

	//public consts
	static public const N_AVG_PROBABILITY: Number = 0.0015;
	static public const N_MAX_DENSITY: int = 4;
	static public const N_SNOW_CLOUD_DENSITY: int = 4;
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
	private const DBL_SIDE_SPEED: Number = 24;
	
	//property fields
	private var FDensity: int;
	
	//other fields

//properties
	public function get Density()
	{
		return FDensity;
	}
	
//methods
	//constructor
    public function Cloud(ALocation: Point, ASize: Size, AnAngle: Angle, ADensity: int)
    {
		FDensity = Math.min(ADensity, N_MAX_DENSITY);
		super(ALocation, ASize, AnAngle);
    }

	//public methods

    public override function inArea(APoint:Point)
    {
		return super.inArea(APoint);
	}

    public function move(AWind: Wind): void
    {
		Location.X += (AWind.HorizontalSpeed + Course.sin() * DBL_SIDE_SPEED) / Core.N_FRAME_RATE;
		Location.Y += (AWind.VerticalSpeed - Course.cos() * DBL_SIDE_SPEED) / Core.N_FRAME_RATE;
	}		
	
	public override function toString(AnIndent: int = 0): String
	{
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		
		return str_indent + "[Cloud]\n" 
			+ str_indent + "{\n"
			+ super.toString(AnIndent + 1)
			+ str_indent + "}\n";	
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