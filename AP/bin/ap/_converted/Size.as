package ap.basic {

///////////////////////////////////////////////////////////
//  Rect.as
///////////////////////////////////////////////////////////

import ap.instrumental.Instruments;

public class Size
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
    public var FHeight: Number;
    public var FWidth: Number;

	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	public function get Height(): Number
	{
		return FHeight;
	}
	
	public function set Height(AHeight: Number)
	{
		FHeight = AHeight;
	}
	
	public function get Width(): Number
	{
		return FWidth;
	}
	
	public function set Width(AHeight: Number)
	{
		FWidth = AHeight;
	}
	
//methods
	//constructor
    public function Size(AWidth: Number = 0, AHeight: Number = 0)
    {
		FWidth = AWidth;
		FHeight = AHeight;
    }
	
	//public methods

    public function clone(): Size
    {
		return new Size(FWidth, FHeight);				
    }

    public function scale(AScaleFactor: Number)
    {
		return new Size(FWidth*AScaleFactor, FHeight*AScaleFactor);				
    }
	
    public function toString(AnIndent: int = 0): String
    {
		var str_indent = Instruments.stringOfChar("\t", AnIndent);
		var str_indent_plus = Instruments.stringOfChar("\t", AnIndent + 1);		
		return str_indent + "[Size]\n" 
			+ str_indent + "{\n"
			+ str_indent_plus + "Width=" + FWidth + "\n"
			+ str_indent_plus + "Height=" + FHeight + "\n"
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