package ap.controllers {

///////////////////////////////////////////////////////////
//  MenuController.as
///////////////////////////////////////////////////////////

import ap.enumerations.DisplayMode;
import ap.model.Airport;

public class MenuController implements IController //singleton
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
	private var FThumbnailModels: Vector.<Airport>;
			
	//other fields
	static private var controllerInstance: MenuController;
	
//properties

	public function get ThumbnailModels():Vector.<Airport>
	{
		return FThumbnailModels;
	}

//methods
	//constructor
	//private constructors not supported by actionscript
	//use getInstance instead!	
	public function MenuController ()
	{
		loadThumbnailModels();
	}		

	//public methods
	
	public function getControllerType(): int 
	{
		return ControlDispatcher.N_MENU_CONTROLLER;
	}	
	
	static public function getInstance(): MenuController
	{
		if (!controllerInstance)
		{
			controllerInstance = new MenuController();
		}
		return controllerInstance;
	}
		
	public function processDispatcherEvent(AType: int, AParamObj: Object = null): Boolean
	{
		switch (AType)
		{
			case ControlDispatcher.N_BACK_TO_BOXES:
				ControlDispatcher.CurrentDisplayMode = DisplayMode.BoxMenu;
				return true;
				
			case ControlDispatcher.N_BOX_OPEN:
				if (!AParamObj.IsBoxLocked)
				{
					ControlDispatcher.CurrentDisplayMode = DisplayMode.LevelMenu; 
					GameProgress.selectSpecifiedLevel(AParamObj.OpeningLevel);
					return true;
				}
				break;											
		}
		
		return false;
	}
	
	public function run(): void
    {
	}
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	private function loadThumbnailModels()
	{
		FThumbnailModels = new Vector.<Airport>(GameProgress.N_LEVEL_COUNT, true);
		for (var i: int = 1; i <= GameProgress.N_LEVEL_COUNT; i++)
		{
			var ap_model: Airport = new Airport(true);
			FThumbnailModels[i-1] = ap_model;
			ap_model.loadLevel("levels/Level" + i.toString() + ".xml");		
		}
	}

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
