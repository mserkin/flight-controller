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
	static private const DBL_WIND_INDICATOR_SIZE: Number = 20;
	static private const DBL_WIND_ARROW_HEIGHT: Number = DBL_WIND_INDICATOR_SIZE*0.6;  
	static private const DBL_WIND_ARROW_WIDTH: Number = DBL_WIND_ARROW_HEIGHT
	static private const SZ_WIND_INDICATOR: Size = new Size(DBL_WIND_INDICATOR_SIZE, DBL_WIND_INDICATOR_SIZE);

	//остальные константы
	static private const CY_OP_PADDING: Number = 2.0; //вертикальные поля 
	static private const DBL_TOOLBAR_HORIZONTAL_MARGIN: Number = 0.01; //of toolbar width
	static private const DBL_TOOLBAR_VERTICAL_MARGIN: Number = 0.05; //of toolbar height 
	static private const SZ_BUTTON: Size = new Size(20, 20);
	static private const SZ_LEVEL_NUMBER_LABEL: Size = new Size(70, 20);
	static private const SZ_POINTS_LABEL: Size = new Size(120, 20);
	static private const SZ_PROGRESS_INDICATOR: Size = new Size(60, 20);

	static private const Y_TITLE_LEVEL_NUMBER:int = 0;
	static private const Y_TITLE_POINTS_NUMBER:int = 0;

	//property fields
	/*private var <#FDelphiStyle#>: <#Type#>,*/

	//other fields
	static private var apAirport: Airport = null;
	static private var lastDisplayMode: DisplayMode = null;
	static private var tbiInfoButton: ToolBarItem;
	static private var tbiBackToMenuButton: ToolBarItem;	
	static private var tbiFastPlayButton: ToolBarItem;
	static private var tbiHintButton: ToolBarItem;
	static private var tbiLevelNumberLabel: ToolBarItem;
	static private var tbiPauseButton: ToolBarItem;
	static private var tbiPointsLabel: ToolBarItem;
	static private var tbiProgressWidget: ToolBarItem;
	static private var tbiRestartButton: ToolBarItem;
	static private var tbiWindIndicatorWidget: ToolBarItem;
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
		switch (ControlDispatcher.CurrentDisplayMode) {
			case DisplayMode.Play:
				//номер уровня
				if (!tbiLevelNumberLabel)
				{
					tbiLevelNumberLabel = new ToolBarItem(SZ_LEVEL_NUMBER_LABEL.clone(), ToolBar.ALIGNMENT_LEFT);
					tbiLevelNumberLabel.OnPaint.addEventListener(ToolBarEventDispatcher.ON_PAINT, toolBarItem_OnPaint);					
				}
				toolBar.addItem(tbiLevelNumberLabel);

				//индикатор ветра
				if (!tbiWindIndicatorWidget)
				{
					tbiWindIndicatorWidget = new ToolBarItem(SZ_WIND_INDICATOR.clone(), ToolBar.ALIGNMENT_CENTER);
					tbiWindIndicatorWidget.OnPaint.addEventListener(ToolBarEventDispatcher.ON_PAINT, toolBarItem_OnPaint);					
				}
				toolBar.addItem(tbiWindIndicatorWidget);

				//индикатор прогресса
				if (!tbiProgressWidget)
				{
					tbiProgressWidget = new ToolBarItem(SZ_PROGRESS_INDICATOR.clone(), ToolBar.ALIGNMENT_LEFT);
					tbiProgressWidget.OnPaint.addEventListener(ToolBarEventDispatcher.ON_PAINT, toolBarItem_OnPaint);					
				}
				toolBar.addItem(tbiProgressWidget);

				//очки
				if (!tbiPointsLabel)
				{
					tbiPointsLabel = new ToolBarItem(SZ_POINTS_LABEL.clone(), ToolBar.ALIGNMENT_LEFT);
					tbiPointsLabel.OnPaint.addEventListener(ToolBarEventDispatcher.ON_PAINT, toolBarItem_OnPaint);					
				}
				toolBar.addItem(tbiPointsLabel);			

				//кнопка перемотки
				if (!tbiFastPlayButton)
				{
					var btn_fast_normal: Sprite = new ButtonNormalFastImage();
					var btn_fast_pressed: Sprite = new ButtonPressedFastImage();
					tbiFastPlayButton = new ToolBarItem(SZ_BUTTON.clone(), ToolBar.ALIGNMENT_RIGHT, btn_fast_normal, btn_fast_pressed);
					tbiFastPlayButton.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
				}
				else tbiFastPlayButton.Pressed = false;
				toolBar.addItem(tbiFastPlayButton);

				//кнопка пayзы
				if (!tbiPauseButton)
				{
					var btn_pause_normal: Sprite = new ButtonNormalPauseImage();
					var btn_pause_pressed: Sprite = new ButtonPressedPauseImage();
					tbiPauseButton = new ToolBarItem(SZ_BUTTON.clone(), ToolBar.ALIGNMENT_RIGHT, btn_pause_normal, btn_pause_pressed);
					tbiPauseButton.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
				}
				else tbiPauseButton.Pressed = false;
				toolBar.addItem(tbiPauseButton);		

				//кнопка перезапуска уровня
				if (!tbiRestartButton)
				{
					tbiRestartButton = new ToolBarItem(SZ_BUTTON.clone(), ToolBar.ALIGNMENT_RIGHT, 
						new ButtonNormalRestartLevelImage(), new ButtonPressedRestartLevelImage());
					tbiRestartButton.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
				}
				toolBar.addItem(tbiRestartButton);

				//кнопка показа подсказок
				if (HintPanelView.Hints.length > 0)
				{
					if (!tbiHintButton)
					{
						tbiHintButton = new ToolBarItem(SZ_BUTTON.clone(), ToolBar.ALIGNMENT_RIGHT, 
							new ButtonNormalHintImage(), new ButtonPressedHintImage());
						tbiHintButton.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
					}
					toolBar.addItem(tbiHintButton);
				}
				//no break - go thru
			case DisplayMode.LevelMenu:				
				if (!tbiBackToMenuButton)
				{
					tbiBackToMenuButton = new ToolBarItem(SZ_BUTTON.clone(), ToolBar.ALIGNMENT_RIGHT, 
						new ButtonNormalBackToMenuImage(), new ButtonPressedBackToMenuImage());
					tbiBackToMenuButton.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
				}
				toolBar.addItem(tbiBackToMenuButton);			
				break;
			case DisplayMode.BoxMenu:
				if (!tbiInfoButton)
				{
					tbiInfoButton = new ToolBarItem(SZ_BUTTON.clone(), ToolBar.ALIGNMENT_RIGHT, 
						new ButtonNormalInfoImage(), new ButtonPressedInfoImage());
					tbiInfoButton.OnClick.addEventListener(ToolBarEventDispatcher.ON_CLICK, toolBarItem_OnClick);					
				}
				toolBar.addItem(tbiInfoButton);			
				break;			
		}
	}

	static private function controlButtonsState()
	{
		
		if (ControlDispatcher.CurrentDisplayMode != DisplayMode.Play) return;

		var dbl_sim_rate: Number = GameController.getInstance().SimulationRate;

		if (dbl_sim_rate > 1) {
			tbiFastPlayButton.Pressed = true;
		} 
		else if (dbl_sim_rate == 0) {
			tbiPauseButton.Pressed = true;
		}
		
		tbiHintButton.Pressed = HintPanelView.IsShown;
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
			case tbiBackToMenuButton:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_MENU_CLICK);
			break;
			case tbiFastPlayButton:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_FAST_SIM_CLICK);
			break;
			case tbiHintButton:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_HINT_CLICK);
			break;
			case tbiInfoButton:			
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_INFO_CLICK);
			break;
			case tbiPauseButton:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_PAUSE_SIM_CLICK);
			break;
			case tbiRestartButton:
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
			case tbiLevelNumberLabel:
				displayLevelNumber(rect_tbi);
			break;
			case tbiPointsLabel:
				displayPoints(rect_tbi);
			break;
			case tbiProgressWidget:
				displayProgressWidget(rect_tbi);
			break;
			case tbiWindIndicatorWidget:
				displayWindIndicatorWidget(rect_tbi);
			break;
		}
	}
}
}
