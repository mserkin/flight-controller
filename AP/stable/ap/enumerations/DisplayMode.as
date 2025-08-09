package ap.enumerations {
public class DisplayMode //enum
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
	static public const N_NORMAL_PAUSE: int = 48;
	static public const N_LONG_PAUSE: int = 100;	
	static const AN_PAUSE: Array = new Array(0, 0, 0, 0, 0, N_NORMAL_PAUSE, N_NORMAL_PAUSE, 0, 0, 0, N_LONG_PAUSE);
	static const ABLN_AIRPORT_SHOWN: Array = new Array(true, false, false, false, false, true, true, false, false, true, false);
	static const ABLN_BANNER_SHOWN: Array = new Array(false, true, true, true, true, false, false, false, false, false, true);	
	static const ABLN_MENU_SHOWN: Array = new Array(false, false, false, false, false, false, false, true, true, false, false);
	static const ABLN_SPLASH_SCREEN: Array = new Array(false, false, false, false, false, false, false, false, false, false, true);
	static const AN_TITLE_COLORS: Array = new Array(null, Colors.Red, Colors.Green, Colors.White, Colors.Blue, null, null, Colors.Blue, Colors.Blue, null, Colors.Blue);
	static const ASTR_NAMES: Array = new Array("Play", "LevelFailedBanner", "LevelCompleteBanner", "LevelStartBanner ", "AboutBanner" , "CrashPause", "MissionCompletePause", "BoxMenu", "LevelMenu", "Edit", "SplashScreen");
	static const ASTR_TITLES: Array = new Array(null, "Mission failed", "Level completed", "Level ", "Admiro" , null, null, null, null, null, null);
		
	//property fields
	//modes
    static private var FPlay: DisplayMode = new DisplayMode(0);
	static private var FLevelFailedBanner: DisplayMode = new DisplayMode(1);
	static private var FLevelCompleteBanner: DisplayMode = new DisplayMode(2);	
	static private var FLevelStartBanner: DisplayMode = new DisplayMode(3);	
	static private var FAboutBanner: DisplayMode = new DisplayMode(4);
    static private var FCrashPause: DisplayMode = new DisplayMode(5);	
	static private var FMissionCompletePause: DisplayMode = new DisplayMode(6);
	static private var FBoxMenu: DisplayMode = new DisplayMode(7);	
	static private var FLevelMenu: DisplayMode = new DisplayMode(8);	
	static private var FEdit: DisplayMode = new DisplayMode(9);
	static private var FSplashScreen: DisplayMode = new DisplayMode(10);
	
	private var FIndex: int;
	
	//other fields
	/*private var <#FDelphiStyle#>: <#Type#>;*/
	/*private var <#prefixCamelStyle#>: <#Type#>;*/
	
//properties

    static public function get AboutBanner(): DisplayMode
    {
    	return FAboutBanner;
    }

	public function get AirportShown(): Boolean
    {
    	return Boolean(ABLN_AIRPORT_SHOWN[FIndex]);
    }

	public function get BannerShown(): Boolean
    {
    	return Boolean(ABLN_BANNER_SHOWN[FIndex]);
    }	
	
    static public function get BoxMenu(): DisplayMode
    {
    	return FBoxMenu;
    }		
	
    public function get Color(): int
    {
		return AN_TITLE_COLORS[FIndex];
    }
	
	static public function get CrashPause(): DisplayMode
    {
    	return FCrashPause;
    }

	static public function get Edit(): DisplayMode
    {
    	return FEdit;
    }	
	
    public function get Index(): int
    {
    	return FIndex;
    }

	public function get IsSplashScreen(): Boolean
    {
    	return Boolean(ABLN_SPLASH_SCREEN[FIndex]);
    }		

	static public function get LevelCompleteBanner(): DisplayMode
    {
    	return FLevelCompleteBanner;
    }

    static public function get LevelFailedBanner(): DisplayMode
    {
    	return FLevelFailedBanner;
    }	

    static public function get LevelMenu(): DisplayMode
    {
    	return FLevelMenu;
    }	
	
    static public function get LevelStartBanner(): DisplayMode
    {
    	return FLevelStartBanner;
    }

	public function get MenuShown(): Boolean
    {
    	return Boolean(ABLN_MENU_SHOWN[FIndex]);
    }		
	
	static public function get MissionCompletePause(): DisplayMode
    {
    	return FMissionCompletePause;
    }
	
	public function get Pause(): Number
    {
    	return AN_PAUSE[FIndex];
    }
	
    static public function get Play(): DisplayMode
    {
    	return FPlay;
    }

    static public function get SplashScreen(): DisplayMode
    {
    	return FSplashScreen;
    }

    public function get Title(): String
    {
    	return ASTR_TITLES[FIndex];
    }

	public function get toString(): String
    {
    	return ASTR_NAMES[FIndex];
    }
	
//methods
	//constructor
	public function DisplayMode(AnIndex: int)
	{
		FIndex = AnIndex;
	}

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