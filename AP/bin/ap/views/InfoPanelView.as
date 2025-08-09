package ap.views {

///////////////////////////////////////////////////////////
//  InfoPanelView.as
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
import ap.input.Core;
import ap.instrumental.Profiler;
import ap.instrumental.ScreenManager;
import ap.model.Airport;

public class InfoPanelView //static
{
//public fields & consts		

	//public consts

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
	//зависимые константы - порядок важен
	static private const DBL_WIND_ARROW_HEIGHT: Number = DBL_WIND_INDICATOR_SIZE*0.6;  
	static private const DBL_WIND_ARROW_WIDTH: Number = DBL_WIND_ARROW_HEIGHT
	static private const DBL_WIND_INDICATOR_SIZE: Number = 20;
	static private const SZ_WIND_INDICATOR: Size = new Size(DBL_WIND_INDICATOR_SIZE, DBL_WIND_INDICATOR_SIZE);
	
	//event handling 
	static private const TO_HANDLE_CLICK: int = 1;
	static private const TO_HANDLE_PAINT: int = 2;
	static private const TO_HANDLE_TOGGLE: int = 4;

	//toolbar item indices
	static private const N_BUTTON_INDEX_LEVEL_NUMBER: int = 0;
	static private const N_BUTTON_INDEX_WIND_INDICATOR: int = 1;
	static private const N_BUTTON_INDEX_PROGRESS: int = 2;
	static private const N_BUTTON_INDEX_POINTS: int = 3;
	static private const N_BUTTON_INDEX_FAST_PLAY: int = 4;
	static private const N_BUTTON_INDEX_PAUSE_PLAY: int = 5;
	static private const N_BUTTON_INDEX_RESTART: int = 6;
	static private const N_BUTTON_INDEX_HINT: int = 7;
	static private const N_BUTTON_INDEX_BACK_TO_MENU: int = 8;
	static private const N_BUTTON_INDEX_INFO: int = 9;		
	
	//in order of depedance
	static private const nPlayOnly: int = DisplayMode.Play.Id;
	static private const AN_DISPLAY_MODES: Array = new Array(nPlayOnly, nPlayOnly, nPlayOnly, nPlayOnly, nPlayOnly,
		nPlayOnly, nPlayOnly, nPlayOnly, DisplayMode.Play.Id | DisplayMode.LevelMenu.Id, DisplayMode.BoxMenu.Id);
	static private const N_TOOLBAR_ITEMS_NUMBER: int = 10;
	static private const ATBI_ITEMS: Array = new Array(N_TOOLBAR_ITEMS_NUMBER);
	static private const SZ_BUTTON: Size = new Size(20, 20);
	static private const SZ_LEVEL_NUMBER_LABEL: Size = new Size(70, 20);
	static private const SZ_POINTS_LABEL: Size = new Size(120, 20);
	static private const SZ_PROGRESS_INDICATOR: Size = new Size(60, 20);
	static private const ASZ_SIZES: Array = new Array(SZ_LEVEL_NUMBER_LABEL, SZ_WIND_INDICATOR, SZ_PROGRESS_INDICATOR,
		SZ_POINTS_LABEL, SZ_BUTTON, SZ_BUTTON, SZ_BUTTON, SZ_BUTTON, SZ_BUTTON, SZ_BUTTON);
	
	//other toolbar items' properties
	static private const ADBL_GRAVITY_VALUES: Array = new Array(int.MAX_VALUE, 0, 0, int.MIN_VALUE, int.MAX_VALUE, 
		int.MAX_VALUE - 1, 0, int.MIN_VALUE + 1, int.MIN_VALUE, 0);
	static private const AN_HANDLED_EVENTS: Array = new Array(TO_HANDLE_PAINT, TO_HANDLE_PAINT, TO_HANDLE_PAINT, 
		TO_HANDLE_PAINT, TO_HANDLE_TOGGLE, TO_HANDLE_TOGGLE, TO_HANDLE_CLICK, TO_HANDLE_CLICK, TO_HANDLE_CLICK, 
		TO_HANDLE_CLICK);
	static private const AN_ITEMS_ALIGNMENT: Array = new Array(ToolBar.ALIGNMENT_LEFT, ToolBar.ALIGNMENT_CENTER,
		ToolBar.ALIGNMENT_LEFT, ToolBar.ALIGNMENT_LEFT, ToolBar.ALIGNMENT_RIGHT, ToolBar.ALIGNMENT_RIGHT, 
		ToolBar.ALIGNMENT_RIGHT, ToolBar.ALIGNMENT_RIGHT, ToolBar.ALIGNMENT_RIGHT, ToolBar.ALIGNMENT_RIGHT);
	static private const ASP_NORMAL_IMAGES: Array = new Array(null, null, null, null, new ButtonNormalFastImage(), 
		new ButtonNormalPauseImage(), new ButtonNormalRestartLevelImage(), new ButtonNormalHintImage(), 
		new ButtonNormalBackToMenuImage(), new ButtonNormalInfoImage());
	static private const ASP_PRESSED_IMAGES: Array = new Array(null, null, null, null, new ButtonPressedFastImage(),
		new ButtonPressedPauseImage(), new ButtonPressedRestartLevelImage(), new ButtonPressedHintImage(), 
		new ButtonPressedBackToMenuImage(), new ButtonPressedInfoImage());
	
	//остальные константы
	static private const CY_OP_PADDING: Number = 2.0; //вертикальные поля 
	static private const DBL_TOOLBAR_HORIZONTAL_MARGIN: Number = 0.01; //of toolbar width
	static private const DBL_TOOLBAR_VERTICAL_MARGIN: Number = 0.05; //of toolbar height 

	static private const Y_TITLE_LEVEL_NUMBER:int = 0;
	static private const Y_TITLE_POINTS_NUMBER:int = 0;

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	static private var apAirport: Airport = null;
	static private var lastDisplayMode: DisplayMode = null;	
	static private var toolBar: ToolBar = null;

//properties

//methods
	//public methods

	static public function display(AnAirport: Airport) 
	{
		apAirport = AnAirport;
			
		//панель
		ScreenManager.displayImage(new InfoPanelImage(), 
			FrameBuilder.InfoPanelRect, new Angle());
		
		displayToolBar();
	}	

	static public function processEvent(AnEvent: Event): Boolean
	{
		if (AnEvent.type == Core.DISPLAY_MODE_CHANGE)
		{
			uncheckButton(ATBI_ITEMS[N_BUTTON_INDEX_FAST_PLAY]);
			uncheckButton(ATBI_ITEMS[N_BUTTON_INDEX_PAUSE_PLAY]);
		}
		
		if (!toolBar) return false;
		return toolBar.processEvent(AnEvent);
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function addButtons()
	{
		for (var i: int = 0; i < N_TOOLBAR_ITEMS_NUMBER; i++)
		{
			if ((ControlDispatcher.CurrentDisplayMode.Id & AN_DISPLAY_MODES[i]) == 0) continue;
			ATBI_ITEMS[i] = addToolBarItem(ATBI_ITEMS[i], ASZ_SIZES[i], AN_HANDLED_EVENTS[i], 
				AN_ITEMS_ALIGNMENT[i], ADBL_GRAVITY_VALUES[i], ASP_NORMAL_IMAGES[i], ASP_PRESSED_IMAGES[i]);
		}
	
		if (HintPanelView.Hints.length == 0) toolBar.removeItem(ATBI_ITEMS[N_BUTTON_INDEX_HINT]);
	}

	static private function addToolBarItem(AToolBarItem: ToolBarItem, ASize: Size, 
		AHandledEvents: int = TO_HANDLE_CLICK, AnAlignment: int = 0, AGravity: Number = 0,
		ANormalImage: Sprite = null, APressedImage: Sprite = null): ToolBarItem
	{
		if (!AToolBarItem) {
			if ((AHandledEvents & TO_HANDLE_TOGGLE) != 0) {
				var tbtb: ToolBarToggleButton;
				tbtb = new ToolBarToggleButton(ASize.clone(), AnAlignment, AGravity, ANormalImage, APressedImage);
				tbtb.OnToggle.addEventListener(ToolBarEventDispatcher.ON_TOGGLE, toolBarToggleButton_OnToggle);
				AToolBarItem = tbtb;
			}
			else {
				AToolBarItem = new ToolBarItem(ASize.clone(), AnAlignment, AGravity, ANormalImage, APressedImage);
			}
			
			if ((AHandledEvents & TO_HANDLE_CLICK) != 0)
				AToolBarItem.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					

			if ((AHandledEvents & TO_HANDLE_PAINT) != 0)
				AToolBarItem.OnPaint.addEventListener(ToolBarEventDispatcher.ON_PAINT, toolBarItem_OnPaint);													
		}
		toolBar.addItem(AToolBarItem);
		return AToolBarItem;
	}
	
	static private function controlButtonsState()
	{
		if (ControlDispatcher.CurrentDisplayMode != DisplayMode.Play) return;

		ATBI_ITEMS[N_BUTTON_INDEX_HINT].Pressed = HintPanelView.IsShown;
	}

	static private function createToolBar()
	{	
		var rect_info_panel: Rect = FrameBuilder.InfoPanelRect;
		var pnt_margins: Point = new Point(rect_info_panel.Extent.Width*DBL_TOOLBAR_HORIZONTAL_MARGIN, 
			rect_info_panel.Extent.Height*DBL_TOOLBAR_VERTICAL_MARGIN);
		var sz_tool_bar = new Size(rect_info_panel.Extent.Width - pnt_margins.X*2,
			rect_info_panel.Extent.Height - pnt_margins.Y*2);
		
		toolBar = new ToolBar(
			rect_info_panel.Location.add(pnt_margins), 
			sz_tool_bar
		);
	}		

	static private function displayLevelNumber(ADisplayRect: Rect)
	{
		ADisplayRect.Location.Y = ADisplayRect.Location.Y + FrameBuilder.adaptToFrame(Y_TITLE_LEVEL_NUMBER);
		ADisplayRect.Extent = new Size(-1, -1);
		ScreenManager.displayText("Level " + GameProgress.Level.toString(), ADisplayRect,
			FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_SMALL), Colors.Brown);
	}	

	static private function displayPoints(ADisplayRect: Rect)
	{
		ADisplayRect.Location.Y = ADisplayRect.Location.Y + FrameBuilder.adaptToFrame(Y_TITLE_POINTS_NUMBER);
		ADisplayRect.Extent = new Size(-1, -1);
		ScreenManager.displayText("Points: " + GameProgress.Points.toString(), ADisplayRect,
			FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_SMALL), Colors.Brown);	
	}

	static private function displayProgressWidget(ADisplayRect: Rect)
	{
		//звездочки
		var sp_progress: Sprite = new ProgressImage();
//		var cy_padding: Number = FrameBuilder.adaptToFrame(CY_OP_PADDING);
		ADisplayRect.Location.Y = ADisplayRect.Location.Y /*+ cy_padding*/ + ADisplayRect.Extent.Height / 2;
//		ADisplayRect.Extent.Height = ADisplayRect.Extent.Height - cy_padding*2;
		var dbl_zoom: Number = ADisplayRect.Extent.Height / sp_progress.height;
		ADisplayRect.Extent.Width = sp_progress.width * dbl_zoom;

		//заполнитель
		var rect_filler: Rect = ADisplayRect.clone();
		var sp_filler: Sprite = new ProgressFillerImage();
		var gc: GameController = GameController.getInstance();
		rect_filler.Extent.Width = sp_filler.width * dbl_zoom * gc.LandingsDone / gc.LandingsToDo;

		ScreenManager.displayImage(sp_filler, rect_filler);
		ScreenManager.displayImage(sp_progress, ADisplayRect);
	}

	static private function displayToolBar()
	{
		var dm_current_mode: DisplayMode = ControlDispatcher.CurrentDisplayMode;
		if (dm_current_mode != lastDisplayMode) {
			lastDisplayMode = dm_current_mode;
			if (!toolBar) createToolBar();
			toolBar.removeAllItems();

			if (ControlDispatcher.CurrentDisplayMode.AirportShown && ControlDispatcher.CurrentDisplayMode != DisplayMode.Edit
				|| ControlDispatcher.CurrentDisplayMode == DisplayMode.LevelMenu
				|| ControlDispatcher.CurrentDisplayMode == DisplayMode.BoxMenu)
			{
				addButtons();
			}
		}
		controlButtonsState();
		toolBar.display();
	}	

	static private function displayWindIndicatorWidget(ADisplayRect: Rect)
	{
		var sp_frame: Sprite = new WindIndicatorFrameImage();
		var sp_arrow: Sprite = new WindIndicatorArrowImage();
		var sp_filler: Sprite = new WindIndicatorFillerImage();

		ADisplayRect.Location.X = ADisplayRect.Location.X + ADisplayRect.Extent.Width/2;
		ADisplayRect.Location.Y = ADisplayRect.Location.Y + ADisplayRect.Extent.Height/2;
		//displaying frame
		//var dbl_wind_indi_size: Number = FrameBuilder.adaptToFrame(DBL_WIND_INDICATOR_SIZE);
		var dbl_zoom: Number = ADisplayRect.Extent.Height / DBL_WIND_INDICATOR_SIZE;
		
		ScreenManager.displayImage(sp_frame, ADisplayRect);

		//dispalying wind arrow
		var cy_arrow = DBL_WIND_ARROW_HEIGHT * dbl_zoom;

		ADisplayRect.Extent.Height = cy_arrow; //* ratio
		ADisplayRect.Extent.Width = DBL_WIND_ARROW_WIDTH * dbl_zoom; //* ratio
		ADisplayRect.Location.X -= cy_arrow / 2 * apAirport.CurrentWind.Direction.sin();
		ADisplayRect.Location.Y += cy_arrow / 2 * apAirport.CurrentWind.Direction.cos();
		ScreenManager.displayImage(sp_arrow, ADisplayRect, apAirport.CurrentWind.Direction);

		//displaying undispaled sector :)
		var ratio: Number =  (apAirport.CurrentWind.DBL_MAX_WIND_SPEED - apAirport.CurrentWind.Speed)
			/apAirport.CurrentWind.DBL_MAX_WIND_SPEED;
		ADisplayRect.Extent.Height = (cy_arrow - 1) * ratio;
		ADisplayRect.Extent.Width = (DBL_WIND_ARROW_WIDTH - FrameBuilder.adaptToFrame(2))*dbl_zoom;
		ScreenManager.displayImage(sp_filler, ADisplayRect, apAirport.CurrentWind.Direction);
	}

	//event handlers

	static private function toolBarItem_OnClick(AnEvent: ObjectEvent): void
	{
		var tbi_source: ToolBarItem = ToolBarItem(AnEvent.SourceObject);
		switch (tbi_source)
		{
			case ATBI_ITEMS[N_BUTTON_INDEX_BACK_TO_MENU]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_MENU_CLICK);
			break;
			case ATBI_ITEMS[N_BUTTON_INDEX_HINT]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_HINT_CLICK);
			break;

			case ATBI_ITEMS[N_BUTTON_INDEX_INFO]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_INFO_CLICK);
			break;

			case ATBI_ITEMS[N_BUTTON_INDEX_RESTART]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_RESTART_CLICK);
			break;
		}
	}

	static private function toolBarItem_OnPaint(AnEvent: ObjectEvent): void
	{
		var tbi_source: ToolBarItem = ToolBarItem(AnEvent.SourceObject);
		var rect_tbi: Rect = tbi_source.clone();
		rect_tbi.Location = rect_tbi.Location.add(toolBar.Location);
		switch (tbi_source)
		{
			case ATBI_ITEMS[N_BUTTON_INDEX_LEVEL_NUMBER]:
				displayLevelNumber(rect_tbi);
			break;
			case ATBI_ITEMS[N_BUTTON_INDEX_POINTS]:
				displayPoints(rect_tbi);
			break;
			case ATBI_ITEMS[N_BUTTON_INDEX_PROGRESS]:
				displayProgressWidget(rect_tbi);
			break;
			case ATBI_ITEMS[N_BUTTON_INDEX_WIND_INDICATOR]:
				displayWindIndicatorWidget(rect_tbi);
			break;
		}
	}

	static private function toolBarToggleButton_OnToggle(AnEvent: ObjectEvent): void
	{
		var tbtb_source: ToolBarToggleButton = ToolBarToggleButton(AnEvent.SourceObject);
		switch(tbtb_source) {
			case ATBI_ITEMS[N_BUTTON_INDEX_FAST_PLAY]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_FAST_SIM_CLICK, 
					{FastMode: tbtb_source.Checked});
			break;	
			case ATBI_ITEMS[N_BUTTON_INDEX_PAUSE_PLAY]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_PAUSE_SIM_CLICK,
					{PauseMode: tbtb_source.Checked});
			break;			
		}
	}
	
	static private function uncheckButton(obj_button: Object)
	{
		if (!obj_button) return;
		var tbtb: ToolBarToggleButton = ToolBarToggleButton(obj_button);
		tbtb.Checked = false;
	}
}
}
