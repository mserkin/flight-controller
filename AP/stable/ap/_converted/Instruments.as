 package ap.instrumental {

public class Instruments //static
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
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//methods
	//constructor
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods

	public static function distDiff(AnX1: Number, AnX2: Number, APerimeter: Number): Number
	{
		var dbl_dist: Number = AnX1 - AnX2;
		
		if (Math.abs(dbl_dist) <= APerimeter / 2)
			return dbl_dist;
		else
			if (dbl_dist > 0)
				return dbl_dist - APerimeter;
			else 
				return dbl_dist + APerimeter;
	}

	public static function intRandom(AMaxValue: int = int.MAX_VALUE)
	{
		return Math.floor(Math.random() * (AMaxValue + 1.0))
	}

	public static function randomSign(): int
	{
		return intRandom(3) - 1;  
	}

	public static function sign(AValue: Number): int
	{
		return AValue > 0 ? +1 : (AValue < 0 ? -1 : 0);
	}
	
	public static function str2Bool(AStr: String): Boolean
	{
		if (AStr.toUpperCase() === "TRUE")
			return true;
		else
			return false;
	}

	public static function stringOfChar(AChar: String, ACount: Number)
	{
		var str_result: String = "", str_char: String = AChar.charAt(0);
		for (var i: int = 1; i <= ACount; i++)
			str_result += str_char;
		return str_result;
	}
	
	public static function xor(ABool1: Boolean, ABool2: Boolean): Boolean
	{
		return (ABool1 != ABool2);
	}
	
	//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/

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