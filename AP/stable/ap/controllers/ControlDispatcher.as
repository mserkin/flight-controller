package ap.controllers {

///////////////////////////////////////////////////////////
//  ControlDispatcher.as
///////////////////////////////////////////////////////////

import ap.enumerations.DisplayMode;
import ap.enumerations.Keys;
import ap.views.HintPanelView;

public class ControlDispatcher //static
{
//public fields & consts		

	//public consts
		//controller types
		static public const N_GAME_CONTROLLER: int = 0;
		static public const N_EDIT_CONTROLLER: int = 1;
		static public const N_MENU_CONTROLLER: int = 2;
		
		//incoming view event types
		static public const N_AIRPORT_DOUBLE_CLICK: int = 7;
		static public const N_AIRPORT_KEY_PRESSED: int = 8;
		static public const N_AIRPORT_MOUSE_DOWN: int = 9;
		static public const N_AIRPORT_MOUSE_MOVE: int = 10;
		static public const N_AIRPORT_MOUSE_UP: int = 11;		
		static public const N_BANNER_BACK_CLICK: int = 14;
		static public const N_BANNER_SKIP_LEVEL_CLICK: int = 17;
		static public const N_BANNER_RESTART_CLICK: int = 16;
		static public const N_BANNER_START_CLICK: int = 15;
		static public const N_EDITOR_CORNER_CLICK: int = 6;
		static public const N_INFO_PANEL_FAST_SIM_CLICK: int = 4;
		static public const N_INFO_PANEL_HINT_CLICK: int = 12;
		static public const N_INFO_PANEL_INFO_CLICK: int = 18;
		static public const N_INFO_PANEL_MENU_CLICK: int = 2;
		static public const N_INFO_PANEL_PAUSE_SIM_CLICK: int = 3;
		static public const N_INFO_PANEL_RESTART_CLICK: int = 5;
		static public const N_MENU_BACK_CLICK: int = 1;		
		static public const N_MENU_BOX_SELECT: int = 0;
		static public const N_MENU_LEVEL_SELECT: int = 13;		
		static public const N_PAUSE_SIMULATION: int = 5;		

		//outcoming dispatcher event types
		static public const N_BACK_TO_BOXES: int = 2;
		static public const N_BOX_OPEN: int = 1;
		static public const N_FAST_SIMULATION: int = 4;
		static public const N_KEY_PRESSED: int = 13;
		static public const N_LEVEL_CONFIG_VISIBILITY: int = 7;
		static public const N_LEVEL_START: int = 0;
		static public const N_NEXT_LEVEL: int = 15;
		static public const N_OBJECT_ACTIVATE: int = 8;
		static public const N_OBJECT_INFO: int = 9;
		static public const N_OBJECT_SELECT: int = 10;
		static public const N_PATH_CONTINUE: int = 11;
		static public const N_PATH_FINISH: int = 12;
		static public const N_RESERVED1: int = 16;		
		static public const N_RESERVED2: int = 3;
		static public const N_SHOW_HINTS: int = 14;
		static public const N_START_LEVEL: int = 6;
		static public const N_PLAY_LEVEL: int = 17;
		
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
	static private var FActiveController: IController = null;
	static private var FDisplayMode: DisplayMode;	
	
	//other fields
	static private var nTitlePause: int = 0; //frames

//properties

	static public function get ActiveController(): IController
	{
		return FActiveController;
	}

	static public function set ActiveController(AValue: IController)
	{
		FActiveController = AValue;
	}	

	static public function get CurrentDisplayMode(): DisplayMode
    {
    	return FDisplayMode;
    }	

	static public function set CurrentDisplayMode(ADisplayMode: DisplayMode)
	{
		if (FDisplayMode == ADisplayMode) return;
		
		if (nTitlePause == 0)
		{
			FDisplayMode = ADisplayMode;
			
			if(FDisplayMode != DisplayMode.Play) {
				HintPanelView.reset();
			}
			
			nTitlePause = FDisplayMode.Pause;
		}
	}		

//methods
	//constructor - static, no instantiation!
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods
	static public function dispatchViewEvent(AType: int, AParamObj: Object = null): Boolean
	{
		switch (AType)
		{
			case N_AIRPORT_DOUBLE_CLICK:
				return FActiveController.processDispatcherEvent(N_OBJECT_ACTIVATE, AParamObj);
				
			case N_AIRPORT_MOUSE_DOWN:
				if (CurrentDisplayMode.AirportShown)
					return FActiveController.processDispatcherEvent(N_OBJECT_SELECT, AParamObj);
				else
				{
					nTitlePause = 0;
					controlDisplayMode();
					return true;
				}

			case N_AIRPORT_MOUSE_MOVE:
				if (CurrentDisplayMode == DisplayMode.Play)
				{
					return GameController.getInstance().processDispatcherEvent(N_PATH_CONTINUE, AParamObj);
				}
				break;

			case N_AIRPORT_MOUSE_UP:
				if (CurrentDisplayMode == DisplayMode.Play)
				{
					return FActiveController.processDispatcherEvent(N_PATH_FINISH, AParamObj);
				}
				break;

			case N_AIRPORT_KEY_PRESSED:
				if (AParamObj.KeyCode == Keys.I)
					return FActiveController.processDispatcherEvent(N_OBJECT_INFO);
				else
					return FActiveController.processDispatcherEvent(N_KEY_PRESSED, AParamObj);
				break;

			case N_BANNER_BACK_CLICK:
				CurrentDisplayMode = DisplayMode.LevelMenu;
				FActiveController = MenuController.getInstance();								
				break;

			case N_BANNER_SKIP_LEVEL_CLICK:			
				GameController.getInstance().processDispatcherEvent(N_NEXT_LEVEL, null);
				//fall to next case
				
			case N_BANNER_RESTART_CLICK:
				GameController.getInstance().processDispatcherEvent(N_START_LEVEL, null);
				FActiveController = GameController.getInstance();
				break;

			case N_BANNER_START_CLICK:
				GameController.getInstance().processDispatcherEvent(N_PLAY_LEVEL, null);
				FActiveController = GameController.getInstance();
				break;
				
			case N_EDITOR_CORNER_CLICK:
				switch (CurrentDisplayMode)
				{
					case DisplayMode.Play:
						FActiveController = EditController.getInstance();
						return true;
						
					case DisplayMode.Edit:
						return FActiveController.processDispatcherEvent(N_LEVEL_CONFIG_VISIBILITY);
				}
				break;
				
			case N_INFO_PANEL_MENU_CLICK:
				switch (CurrentDisplayMode)
				{
					case DisplayMode.LevelMenu:
						return FActiveController.processDispatcherEvent(N_BACK_TO_BOXES);
					case DisplayMode.Play:
					case DisplayMode.CrashPause:
						nTitlePause = 0;
						GameProgress.acceptLevelResult(GameController.getInstance().ShiftProgress);
						CurrentDisplayMode = DisplayMode.LevelFailedBanner;
				}
				break;
				
			case N_INFO_PANEL_FAST_SIM_CLICK:	
				if (CurrentDisplayMode == DisplayMode.Play)
				{
					return FActiveController.processDispatcherEvent(N_FAST_SIMULATION);				
				}
				break;

			case N_INFO_PANEL_HINT_CLICK:
				if (CurrentDisplayMode == DisplayMode.Play)
				{
					return FActiveController.processDispatcherEvent(N_SHOW_HINTS);				
				}
				break;

			case N_INFO_PANEL_INFO_CLICK:
				CurrentDisplayMode = DisplayMode.AboutBanner;
				break;
				
			case N_INFO_PANEL_PAUSE_SIM_CLICK:	
				if (CurrentDisplayMode == DisplayMode.Play)
				{
					return FActiveController.processDispatcherEvent(N_PAUSE_SIMULATION);				
				}
				break;

			case N_INFO_PANEL_RESTART_CLICK:	
				if (CurrentDisplayMode == DisplayMode.Play)
				{
					GameProgress.acceptLevelResult(GameController.getInstance().ShiftProgress);
					return FActiveController.processDispatcherEvent(N_START_LEVEL);				
				}
				break;
				
			case N_MENU_BOX_SELECT:
				return FActiveController.processDispatcherEvent(N_BOX_OPEN, AParamObj);
				
			case N_MENU_LEVEL_SELECT:	
				if (AParamObj.LevelNumber > 0)
				{
					GameProgress.selectSpecifiedLevel(AParamObj.LevelNumber);
					FActiveController = GameController.getInstance();
					return FActiveController.processDispatcherEvent(N_START_LEVEL);
				}
				break;
		}
		return false;
	}

	static public function run()
	{
		controlDisplayMode();
		FActiveController.run();
	}

	//private methods

	static private function controlDisplayMode()
	{
		if (--nTitlePause <= 0)
		{
			nTitlePause = 0;
			switch (CurrentDisplayMode)
			{
				case DisplayMode.SplashScreen:
					CurrentDisplayMode = DisplayMode.BoxMenu;
					FActiveController = MenuController.getInstance();
					break;

				case DisplayMode.CrashPause:
					GameProgress.acceptLevelResult(GameController.getInstance().ShiftProgress);
					CurrentDisplayMode = DisplayMode.LevelFailedBanner;
					FActiveController = GameController.getInstance();
					break;					
/*				case DisplayMode.LevelCompleteBanner: 
					if (GameProgress.Complete)
					{
						CurrentDisplayMode = DisplayMode.AboutBanner;
						FActiveController = GameController.getInstance();
					}
					break;
				case DisplayMode.AboutBanner: 
					GameProgress.reset();
					CurrentDisplayMode = DisplayMode.LevelMenu;
					FActiveController = MenuController.getInstance();					
					break;
					*/
				case DisplayMode.MissionCompletePause:
					CurrentDisplayMode = GameProgress.IsLastBox && GameProgress.BoxPassed ? 
						DisplayMode.AboutBanner 
						: DisplayMode.LevelCompleteBanner;
					FActiveController = GameController.getInstance();
					break;										
				case DisplayMode.Play:
					if (GameController.getInstance().ShiftProgress >= 100)
					{
						GameProgress.acceptLevelResult(100);					
						CurrentDisplayMode = DisplayMode.MissionCompletePause;
						FActiveController = GameController.getInstance();
					}
					break;
			}
		}
	}

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
