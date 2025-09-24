package ap.configuration {

///////////////////////////////////////////////////////////
//  Starter.as
///////////////////////////////////////////////////////////

import ap.controllers.*;
import ap.enumerations.DisplayMode;
import ap.input.Core;
import ap.instrumental.ScreenManager;
import ap.model.Airport;
import ap.views.FrameBuilder;
import flash.display.Stage;

public class Starter
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
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	/*private var <#prefixCamelStyle#>: <#Type#>;*/

//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;
	}*/

//methods
	//constructor
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods

	static public function start(AStage: Stage)
	{
		ScreenManager.init(AStage);
		
		var ap_airport: Airport = new Airport();
		trace("Executed!!!");
				
		FrameBuilder.init(ap_airport);

		ControlDispatcher.CurrentDisplayMode = DisplayMode.SplashScreen;
		MenuController.getInstance();
		ControlDispatcher.ActiveController = GameController.getInstance(ap_airport);
		EditController.getInstance(ap_airport);
		
		Core.run(AStage);
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
