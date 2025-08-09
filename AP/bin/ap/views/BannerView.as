package ap.views {

///////////////////////////////////////////////////////////
//  BannerView.as
///////////////////////////////////////////////////////////

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import ap.basic.*;
import ap.controllers.ControlDispatcher;
import ap.controllers.GameController;
import ap.controllers.GameProgress;
import ap.enumerations.Colors;
import ap.enumerations.DisplayMode;
import ap.instrumental.Profiler;
import ap.instrumental.ScreenManager;

public class BannerView //static!
{
//public fields & consts		

	//public consts
	

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
	static private const DBL_BANNER_WIDTH: Number = 390;
	static private const DBL_BANNER_HEIGHT: Number = 240;
	static private const DBL_BOX_SPACING: Number = 0.15; //15% of button size
	static private const DBL_PROGRESS_HEIGHT = 0.2; //of banner height
	static private const DBL_TOOLBAR_HORIZONTAL_MARGIN: Number = 1 / 12; //of banner width
	static private const DBL_TOOLBAR_VERTICAL_MARGIN: Number = 1 / 12; //of banner height
	static private const DBL_TOOLBAR_HEIGHT: Number = 1 / 3; //of banner height

	static private const STR_AUTHOR_NAME: String = "Programmed by Mikhail Serkin";
	static private const STR_AUTHOR_EMAIL: String = "Email: Mikhail.Serkin@gmail.com";
	static private const STR_GAME_NAME: String = "Mad Skies";
	static private const STR_LANDED: String = "Planes landed: ";
	static private const STR_POINTS: String = "Points: ";
	static private const STR_THE_END: String = "The End!";
	static private const SZ_BUTTON_SIZE: Size = new Size(50, 50);
	static private const Y_AUTHOR_EMAIL: Number = 0.5; //of banner height
	static private const Y_AUTHOR_NAME: Number = 0.4; //of banner height
	static private const Y_GAME_NAME: Number = 0.3; //of banner height
	static private const Y_LANDED: Number = 0.3; //of banner height
	static private const Y_POINTS: Number = 0.2; //of banner height
	static private const Y_PROGRESS: Number = 0.45; //of banner height
	static private const Y_THE_END: Number = 0.25; //of banner height
	static private const Y_TITLE: Number = 0.1; //of banner height

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields

	static	private var isInitialized: Boolean = false;
	static	private var lastDisplayMode: DisplayMode = null;
	static	private var rectBanner: Rect;
	static	private var tbiBackToMenu;	
	static	private var tbiOpennedBox;
	static	private var tbiRestart;
	static	private var tbiStart;
	static	private var toolBar: ToolBar = null;

//properties

	/*public function get <#DelphiStyle#> ():<#Type#>
	{
		return ...;	}*/

//methods
	//constructor
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods
	
	static public function display() 
	{
		if (ControlDispatcher.ActiveController.getControllerType() == 1 || ControlDispatcher.CurrentDisplayMode.AirportShown) return;
		Profiler.checkin("banner");
	
		rectBanner = displayBannerBackground();
		
		if (!ControlDispatcher.CurrentDisplayMode.IsSplashScreen) {
			var str_title: String = ControlDispatcher.CurrentDisplayMode.Title;
			if (ControlDispatcher.CurrentDisplayMode == DisplayMode.LevelStartBanner) {
				str_title += GameProgress.Level;
			}
			printTitle(str_title, ControlDispatcher.CurrentDisplayMode.Color);
			
			displayToolBar();
			
			switch (ControlDispatcher.CurrentDisplayMode)
			{
				case DisplayMode.LevelFailedBanner:
				case DisplayMode.LevelCompleteBanner:
					displayLevelStats();
					break;
				case DisplayMode.AboutBanner:				
					displayGameInfo();
					break;
			}
			
			displayProgress();
		}
		Profiler.checkout("banner");
	}

	static public function processEvent(AnEvent: Event): Boolean
	{
		switch (ControlDispatcher.CurrentDisplayMode)
		{
			case DisplayMode.AboutBanner:
			case DisplayMode.LevelStartBanner:
			case DisplayMode.LevelFailedBanner:
			case DisplayMode.LevelCompleteBanner:
				if (toolBar) return toolBar.processEvent(AnEvent);

			default: return false;
		}
	}	

	/*public function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function addBackToMenuButton(IsSoleButton: Boolean)
	{
		if (!tbiBackToMenu)
		{
			tbiBackToMenu = new ToolBarItem(SZ_BUTTON_SIZE.clone(), 0, int.MIN_VALUE, 
				new BannerBackToMenuNormalImage(), new BannerBackToMenuPressedImage());
			tbiBackToMenu.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
		}
		tbiBackToMenu.Alignment = IsSoleButton ? ToolBar.ALIGNMENT_CENTER : ToolBar.ALIGNMENT_LEFT;
		toolBar.addItem(tbiBackToMenu);
	}
	
	static private function addBoxButton()
	{
		if (!tbiOpennedBox)
		{
			tbiOpennedBox = new ToolBarItem(SZ_BUTTON_SIZE.clone(), ToolBar.ALIGNMENT_CENTER);
			tbiOpennedBox.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
			tbiOpennedBox.OnPaint.addEventListener(ToolBarEventDispatcher.ON_PAINT, toolBarItem_OnPaint);
		}
		toolBar.addItem(tbiOpennedBox);
	}
	
	static private function addButtons(ShowStartButton: Boolean, ShowRestartButton: Boolean, ShowNewlyOpenedBox: Boolean = true)
	{
		addBackToMenuButton(!(ShowStartButton || ShowRestartButton || ShowNewlyOpenedBox));
		if (ShowRestartButton) addRestartButton();
		
		if (GameProgress.NewlyOpenedBox >= 0 && ShowNewlyOpenedBox >= 0 && ControlDispatcher.CurrentDisplayMode != DisplayMode.AboutBanner
				&& (ControlDispatcher.CurrentDisplayMode != DisplayMode.LevelStartBanner 
				|| ControlDispatcher.CurrentDisplayMode == DisplayMode.LevelStartBanner && GameProgress.Box != GameProgress.NewlyOpenedBox)) {
				addBoxButton();
		}
		
		if (ShowStartButton) {
			var n_current_level_box: int = GameProgress.getBoxForLevel(GameProgress.Level);
			var n_next_level_box: int = GameProgress.getBoxForLevel(GameProgress.Level + 1);
			if (ControlDispatcher.CurrentDisplayMode != DisplayMode.AboutBanner 
				&& (ControlDispatcher.CurrentDisplayMode != DisplayMode.LevelCompleteBanner
					&& ControlDispatcher.CurrentDisplayMode != DisplayMode.LevelFailedBanner
					|| n_next_level_box == n_current_level_box 
					|| GameProgress.getBoxProgress(n_current_level_box) >= 1))
			{
				addStartLevelButton();
			}
		}
	}
	
	static private function addRestartButton()
	{
		if (!tbiRestart)
		{
			tbiRestart = new ToolBarItem(SZ_BUTTON_SIZE.clone(), ToolBar.ALIGNMENT_CENTER, 10,
				new BannerRestartNormalImage(), new BannerRestartPressedImage());
			tbiRestart.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
		}
		toolBar.addItem(tbiRestart);
	}
	
	static private function addStartLevelButton()
	{
		if (!tbiStart)
		{
			tbiStart = new ToolBarItem(SZ_BUTTON_SIZE.clone(), ToolBar.ALIGNMENT_RIGHT, int.MAX_VALUE,
				new BannerStartNormalImage(), new BannerStartPressedImage());
			tbiStart.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
		}
		toolBar.addItem(tbiStart);
	}
		
	static private function createToolBar()
	{	
		var sz_margins = new Size(rectBanner.Extent.Width*DBL_TOOLBAR_HORIZONTAL_MARGIN, 
			rectBanner.Extent.Height*DBL_TOOLBAR_VERTICAL_MARGIN);
		var sz_tool_bar = new Size(rectBanner.Extent.Width - sz_margins.Width*2,
			rectBanner.Extent.Height*DBL_TOOLBAR_HEIGHT);
		
		toolBar = new ToolBar(
			rectBanner.Location.add(
				new Point(sz_margins.Width, 
					rectBanner.Extent.Height - sz_tool_bar.Height - sz_margins.Height)),
			sz_tool_bar
		);
	}	
		
	static private function displayBox(ABoxNumber: int, ARect: Rect)
	{
		MenuView.displayBoxIcon(true, ABoxNumber, ARect);
	}
		
	static private function displayBannerBackground(): Rect
	{
		var sp_background: Sprite;
		var rect_bg: Rect = new Rect(new Point(), FrameBuilder.adaptSizeToFrame(new Size(DBL_BANNER_WIDTH, DBL_BANNER_HEIGHT)));		
		switch (ControlDispatcher.CurrentDisplayMode)
		{
			case DisplayMode.AboutBanner:
				sp_background = new AboutBannerImage();
				break;
			case DisplayMode.LevelStartBanner:
				sp_background = new MissionStartBannerImage();
				break;
			case DisplayMode.LevelFailedBanner:
				sp_background = new MissionFailedBannerImage();
				break;				
			case DisplayMode.LevelCompleteBanner:
				sp_background = new MissionCompletedBannerImage();
				break;
			case DisplayMode.SplashScreen:
				sp_background = new SplashScreenBannerImage();
				rect_bg = FrameBuilder.fitToFrame(new Rect(new Point(), new Size(sp_background.width, sp_background.height)));
				break;				
			default: sp_background = new BannerBackToMenuNormalImage();
		}	
		
		var rect_result: Rect = FrameBuilder.centerInFrame(rect_bg);
		ScreenManager.displayImage(sp_background, rect_result);
		return rect_result;
	}

	static private function displayGameInfo() {
		var gc: GameController = GameController.getInstance();
		var pnt: Point = rectBanner.Center;
		var rgn: Region = new Region(pnt, new Size(-1, -1));
		
		rgn.Location.Y = rectBanner.Location.Y + rectBanner.Extent.Height*Y_THE_END;
		
		if (GameProgress.IsLastBox && GameProgress.BoxPassed) {
			ScreenManager.displayText(STR_THE_END, rgn, FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_LARGE), Colors.Brown);
		}
		rgn.Location.Y = rectBanner.Location.Y + rectBanner.Extent.Height*Y_GAME_NAME;
		ScreenManager.displayText(STR_GAME_NAME, rgn, FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_LARGE), 0x00AAFF);		

		rgn.Location.Y = rectBanner.Location.Y + rectBanner.Extent.Height*Y_AUTHOR_NAME;
		ScreenManager.displayText(STR_AUTHOR_NAME, rgn, FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_SMALL));		

		rgn.Location.Y = rectBanner.Location.Y + rectBanner.Extent.Height*Y_AUTHOR_EMAIL;
		ScreenManager.displayText(STR_AUTHOR_EMAIL, rgn, FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_SMALL));					
	}
	
	static private function displayLevelStats()
	{
		var gc: GameController = GameController.getInstance();
		var pnt: Point = rectBanner.Center;
		pnt.Y = rectBanner.Location.Y + rectBanner.Extent.Height*Y_LANDED;
		
		ScreenManager.displayText(
			STR_LANDED + gc.LandingsDone + " / " + gc.LandingsToDo, 
			new Region(pnt, new Size(-1, -1)), 
			FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_MEDIUM),
			Colors.Yellow
		);

		pnt.Y = rectBanner.Location.Y + rectBanner.Extent.Height*Y_POINTS;
		ScreenManager.displayText(
			STR_POINTS + GameProgress.Points, 
			new Region(pnt, new Size(-1, -1)), 
			FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_SMALL)
		);	
	}

	static private function displayProgress()
	{
		var sp_progress: Sprite;
		switch (ControlDispatcher.CurrentDisplayMode)
		{
			case DisplayMode.LevelCompleteBanner:
				sp_progress = new BannerProgressCompletedImage();
				break;
			case DisplayMode.LevelFailedBanner:
				sp_progress = new BannerProgressFailedImage();
				break;
			default: return;
		}
		
		var cy_size: Number = rectBanner.Extent.Height * DBL_PROGRESS_HEIGHT;
		var dbl_zoom: Number = cy_size / sp_progress.height;
		var cx_size_progress: Number = sp_progress.width * dbl_zoom;
		var x_progress: Number = rectBanner.Location.X + rectBanner.Extent.Width/2 - cx_size_progress/2;
		var y_progress: Number = rectBanner.Location.Y + rectBanner.Extent.Height*Y_PROGRESS;
		
		var rect_progress: Rect = new Rect(new Point(x_progress, y_progress), new Size(cx_size_progress, cy_size));
		
		var sp_filler: Sprite = new BannerProgressFillerImage();
		var cx_size_filler: Number = sp_filler.width * dbl_zoom;
		var gc: GameController = GameController.getInstance();
			
		var rect_filler: Rect = new Rect(
			new Point(x_progress, y_progress), 
			new Size(gc.LandingsDone / gc.LandingsToDo * cx_size_filler, cy_size)
		);
		ScreenManager.displayImage(sp_filler, rect_filler, new Angle());
		ScreenManager.displayImage(sp_progress, rect_progress, new Angle());
	}	
	
	static private function displayToolBar()
	{
		var dm_current_mode: DisplayMode = ControlDispatcher.CurrentDisplayMode;
		if (dm_current_mode != lastDisplayMode) {
			lastDisplayMode = dm_current_mode;
			if (!toolBar) createToolBar();
			toolBar.removeAllItems();
			switch (dm_current_mode)
			{
				case DisplayMode.LevelFailedBanner:
					addButtons(true, true);
					break;
				case DisplayMode.LevelCompleteBanner:
					addButtons(true, true);
					break;
				case DisplayMode.LevelStartBanner:
					addButtons(true, false);
					break;
				case DisplayMode.AboutBanner:
					addButtons(false, false, false);
					break;
			}
		}
		toolBar.display();
	}
	
	static private function printTitle(AText: String, AColor: int)
	{
		if (!AText) return;
		
		ScreenManager.displayText(
			AText, 
			new Region(
				new Point(
					rectBanner.Location.X + rectBanner.Extent.Width/2,
					rectBanner.Location.Y + rectBanner.Extent.Height*Y_TITLE
				), 
				new Size(-1, -1)
			), 
			FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_LARGE), 
			AColor
		);
	}

	//event handlers

	static private function toolBarItem_OnClick(AnEvent:  ObjectEvent): void
	{
		switch(AnEvent.SourceObject) {
			case tbiBackToMenu:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_BANNER_BACK_CLICK);	
				break;
			case tbiRestart:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_BANNER_RESTART_CLICK);
				break;
				
			case tbiStart:
				if (ControlDispatcher.CurrentDisplayMode == DisplayMode.LevelStartBanner)
				{
					ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_BANNER_START_CLICK);
				}
				else
				{
					ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_BANNER_SKIP_LEVEL_CLICK);
				}				
				break;
				
			case tbiOpennedBox:
				GameProgress.selectSpecifiedLevel(GameProgress.getFirstLevelForBox(GameProgress.NewlyOpenedBox));
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_BANNER_BACK_CLICK);	
			break;	
		}
	}
	
	//event hanglers
	static private function toolBarItem_OnPaint(AnEvent: ObjectEvent): void
	{
		var tbi_source: ToolBarItem = ToolBarItem(AnEvent.SourceObject);
		var rect_tbi: Rect = tbi_source.clone();
		rect_tbi.Location = rect_tbi.Location.add(toolBar.Location);
		
		ScreenManager.displayImage(new BannerButtonFrameImage(), rect_tbi);
	
		var dbl_spacing_hor: Number = rect_tbi.Extent.Width * DBL_BOX_SPACING;
		var dbl_spacing_ver: Number = rect_tbi.Extent.Height * DBL_BOX_SPACING;
		
		rect_tbi.Extent.Width -= dbl_spacing_hor*2;
		rect_tbi.Extent.Height -= dbl_spacing_ver*2;
		rect_tbi.Location.X += dbl_spacing_hor;
		rect_tbi.Location.Y += dbl_spacing_ver;
		
		displayBox(GameProgress.NewlyOpenedBox, rect_tbi);
	}
}
}