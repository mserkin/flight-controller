package ap.input {

///////////////////////////////////////////////////////////
//  Core.as
///////////////////////////////////////////////////////////

import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import ap.controllers.ControlDispatcher;
import ap.controllers.EditController;
import ap.enumerations.DisplayMode;
import ap.instrumental.Profiler;
import ap.instrumental.ScreenManager;
import ap.views.*;

public class Core //static
{
//public fields & private consts		

	//public private consts
	static public const N_FRAME_RATE: uint = 15;

	//public fields

	//events
	/*<#OnDelphiStyle#>: CustomDispatcher = new CustomDispatcher();*/

//protected fields & private consts

	//protected private consts
	/*protected private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & private consts

	//private consts	
	
	//property fields
	
	//other fields
	static private var blnPrevFrameAirportShown: Boolean = false;
	static private var isTimerSuspendPending = false;
	static private var stgStage: Stage;
	static private var timerMain: Timer;

//properties	

//methods
	//private constructor

	//public methods

	static public function resume()
	{
		timerMain.start();
	}
	
	static public function run(AStage: Stage) 
	{
		timerMain = new Timer(1000 / N_FRAME_RATE,0)
		
		suspend();
		
		timerMain.addEventListener(TimerEvent.TIMER, Timer_OnTimer);
		AStage.mouseChildren=false;
		AStage.doubleClickEnabled=true;		
		AStage.addEventListener(KeyboardEvent.KEY_UP, Stage_OnEvent);
		AStage.addEventListener(KeyboardEvent.KEY_DOWN, Stage_OnEvent);			
		AStage.addEventListener(MouseEvent.MOUSE_DOWN, Stage_OnEvent);
		AStage.addEventListener(MouseEvent.MOUSE_MOVE, Stage_OnEvent);
		AStage.addEventListener(MouseEvent.MOUSE_UP, Stage_OnEvent);
		AStage.addEventListener(MouseEvent.CLICK, Stage_OnEvent);
		AStage.addEventListener(MouseEvent.DOUBLE_CLICK, Stage_OnEvent);

		stgStage = AStage;
		
		resume();
	}
		
	static public function suspend()
	{
		timerMain.stop();
	}
	
	//protected methods

	/* protected private function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function createFrame()
	{
		Profiler.checkin("Computing");

		ControlDispatcher.run();

		Profiler.checkout("Computing");		

		FrameBuilder.buildFrame();
}	

	static private function dispatchEvent(AnEvent: Event)
	{
		if (!MenuView.processEvent(AnEvent))
			if (!HintPanelView.processEvent(AnEvent))
				if (!InfoPanelView.processEvent(AnEvent))
					if (!BannerView.processEvent(AnEvent))
						AirportView.processEvent(AnEvent);
								
		postprocess();
	}
						
	static private function postprocess()
	{
		if (ControlDispatcher.CurrentDisplayMode == DisplayMode.Edit)
		{
			if (EditController.getInstance().LevelConfig)
			{
				stgStage.mouseChildren = true;
				isTimerSuspendPending = true;				
			}
		}		
		if (!(EditController.getInstance().LevelConfig))
		{
			stgStage.mouseChildren = false;
			if (!HintPanelView.IsShown)
				resume();
		}
	}					
	//event handlers

	static private function Stage_OnEvent(AnEvent: Event) 
	{
		dispatchEvent(AnEvent);
	}
			
	static private function Timer_OnTimer(AnEvent: Event) 
	{
		createFrame();
		
		if (isTimerSuspendPending)
		{
			isTimerSuspendPending = false;
			suspend();
		}
	}
}
}