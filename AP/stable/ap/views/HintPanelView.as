package ap.views {

///////////////////////////////////////////////////////////
//  HintPanelView.as
///////////////////////////////////////////////////////////

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextFormat;
import flash.utils.*;
import ap.basic.*;
import ap.enumerations.Colors;
import ap.input.*;
import ap.instrumental.*;

public class HintPanelView //static
{
//public fields & consts		

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
	static public var OnHidden: CustomDispatcher = new CustomDispatcher();
	static public var OnHiding: CustomDispatcher = new CustomDispatcher();
	static public var OnShown: CustomDispatcher = new CustomDispatcher();

//protected fields & consts

	//protected consts
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	static private const DBL_HINT_FONT_SIZE = 20;
	static private const DBL_SHOW_RATE: Number = 0.05;
	static private const N_FORCED_SHOW_PERIOD: uint = 1;
	static private const N_HIDDEN_PERIOD: uint = 4000;
	static private const N_SHOWN_PERIOD: uint = 30000;
	static private const CX_HINT_MARGIN: Number = 0.1; //of hint window size
	
	//panel states
	static private const STATE_HIDDEN: uint = 0;
	static private const STATE_SHOWING: uint = 1;
	static private const STATE_SHOWN: uint = 2;
	static private const STATE_HIDING: uint = 3;
	
	//property fields
	static private var FClipIds: Vector.<String> = new Vector.<String>();
	static private var FHints: Vector.<String> = new Vector.<String>();

	//other fields
	static private var dblShownPart: Number = 0;
	static private var nHintToShowIndex: int = 0;
	static private var nState: uint = STATE_HIDDEN;
	static private var rectTarget: Rect; 
	static private var timerHint: Timer = new Timer(100); 
//properties

	static public function get ClipIds (): Vector.<String>
	{
		return FClipIds;
	}

	static public function get Hints (): Vector.<String>
	{
		return FHints;
	}

	static public function get IsShown (): Boolean
	{
		return nState != STATE_HIDDEN;
	}

//methods
	//constructor
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
			var <#prefix_underscore_style#>: <#Type#>;
	}*/		
	
	//public methods
	static public function display()
	{
		Profiler.checkin("hint");
		try
		{
			if (nState == STATE_HIDDEN) return;
			
			var hp: HintPanel = new HintPanel();
			hp.HintTextField.text = FHints[nHintToShowIndex];
			hp.HintTextField.setTextFormat(new TextFormat("Arial", FrameBuilder.adaptToFrame(DBL_HINT_FONT_SIZE), Colors.White));
			ScreenManager.displayImage(hp, getHintPanelRect(), new Angle());
					
			var str_class_name: String = FClipIds[nHintToShowIndex];
			if (str_class_name != "")
			{
				var classClip: Class = getDefinitionByName(str_class_name) as Class;
				var clip: MovieClip = new classClip();
				var rect_panel: Rect = getHintPanelRect();
				
				ScreenManager.displayImage(
					clip, 
					new Rect(
						rect_panel.Location.add(new Point(rect_panel.Extent.Width*CX_HINT_MARGIN, hp.AnimationPlaceholder.y)), 
						FrameBuilder.adaptSizeToFrame(new Size(hp.AnimationPlaceholder.width, hp.AnimationPlaceholder.height))
					), 
					new Angle()
				);
			}
		}
		finally
		{
			Profiler.checkout("hint");
		}
	}

	//GameController use it on display mode change
	static public function hide(IsForcedHide: Boolean = false)
	{
		switch(nState)
		{
			case STATE_HIDDEN:
			case STATE_HIDING:
				return;
			default: 
				nState = STATE_SHOWN;
				controlState();
		}
	}

	static public function processEvent(AnEvent: Event): Boolean
	{
		if (AnEvent is MouseEvent && AnEvent.type == MouseEvent.CLICK)
		{
			var mouse_event: MouseEvent = MouseEvent(AnEvent);
			var point: Point = new Point(mouse_event.stageX, mouse_event.stageY);
			if (IsShown && isInside(point))
			{
				hide();
				return true;
			}
		}
		return false;
	}	

	static public function reset()
	{
		FHints.length = 0;
		FClipIds.length = 0;
		nHintToShowIndex = 0;
		dblShownPart = 0;
		nState = STATE_HIDING;
		controlState();
	}
	
	static public function show(IsForcedShow: Boolean = false)
	{
		if (nState != STATE_HIDDEN) return false;
		if (!IsForcedShow || nHintToShowIndex >= FHints.length) nHintToShowIndex = 0;
		
		rectTarget = FrameBuilder.FrameRect.clone();
		rectTarget.Extent.Height /= 2;
		rectTarget.Location.Y = rectTarget.Extent.Height;
		
		timerHint.addEventListener(TimerEvent.TIMER, Timer_OnTimer);
		timerHint.delay = IsForcedShow ? N_FORCED_SHOW_PERIOD : N_HIDDEN_PERIOD;
		timerHint.start();
		
		return true;
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods
	static private function controlState()
	{
		switch (nState)
		{
			case STATE_HIDDEN:
				if (nHintToShowIndex < FHints.length)
				{
					nState = STATE_SHOWING;
					timerHint.delay = 1000 / Core.N_FRAME_RATE;
				}
				else
					timerHint.stop();
				return;
			case STATE_SHOWING:
				dblShownPart += DBL_SHOW_RATE;
				if (dblShownPart >= 1)
				{
					dblShownPart = 1;
					nState = STATE_SHOWN;
					timerHint.delay = N_SHOWN_PERIOD;
					OnShown.fireOnShown();
				}
				break;
			case STATE_SHOWN:
				nState = STATE_HIDING;
				timerHint.delay = 1000 / Core.N_FRAME_RATE;
				OnHiding.fireOnHiding();
				break;
			case STATE_HIDING:
				dblShownPart -= DBL_SHOW_RATE;
				if (dblShownPart <= 0)
				{
					dblShownPart = 0;
					nState = STATE_HIDDEN;
					nHintToShowIndex++;
					timerHint.delay = N_HIDDEN_PERIOD;
					OnHidden.fireOnHidden();
				}
				break;
		}
	}
	
	static private function getHintPanelRect(): Rect
	{
		var dbl_frame_bottom: Number = FrameBuilder.FrameRect.Extent.Height;
		var rect: Rect = rectTarget.clone();
		rect.Location.Y = dbl_frame_bottom - (dbl_frame_bottom - rect.Location.Y) * dblShownPart;
		
		return rect;
	}
	
	static private function isInside(ALocation: Point): Boolean
	{
		var rect: Rect = getHintPanelRect();
		return rect.isInside(ALocation);
	}
	
	//event handlers
	static private function Timer_OnTimer(AnEvent: Event) 
	{
		controlState();
	}

}
}
