package ap.enumerations {
public class Colors //static, enum
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
	static const N_COLOR_BLACK: int = 0x000000;
	static const N_COLOR_BLUE: int = 0x0000FF;
	static const N_COLOR_BROWN: int = 0x938F0D;
	static const N_COLOR_GRAY: int = 0xAAAAAA;
	static const N_COLOR_GREEN: int = 0x00FF00;
	static const N_COLOR_RED: int = 0xFF0000;
	static const N_COLOR_SELECTION: int = 0xF29200;	
	static const N_COLOR_YELLOW: int = 0xF2F200;
	static const N_COLOR_WHITE: int = 0xFFFFFF;
	

	//property fields

	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	static public function get Black(): int
    {
    	return N_COLOR_BLACK;
    }

	static public function get Blue(): int
    {
    	return N_COLOR_BLUE;
    }
	
	static public function get Brown(): int
    {
    	return N_COLOR_BROWN;
    }
	
    static public function get Gray(): int
    {
    	return N_COLOR_GRAY;
    }
	
    static public function get Green(): int
    {
    	return N_COLOR_GREEN;
    }

    static public function get Red(): int
    {
    	return N_COLOR_RED;
    }
	
    static public function get Selection(): int
    {
    	return N_COLOR_SELECTION;
    }
	
    static public function get Yellow(): int
    {
    	return N_COLOR_YELLOW;
    }

    static public function get White(): int
    {
    	return N_COLOR_WHITE;
    }
	
//methods
	//constructor
	
	//public methods

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