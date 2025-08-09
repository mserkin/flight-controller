package ap.views {

///////////////////////////////////////////////////////////
//  FrameBuilder.as
///////////////////////////////////////////////////////////

import flash.events.Event;
import ap.basic.*;
import ap.controllers.ControlDispatcher;
import ap.controllers.EditController;
import ap.controllers.GameProgress;
import ap.enumerations.Colors;
import ap.enumerations.DisplayMode;
import ap.instrumental.*;
import ap.model.Airport;

public class FrameBuilder
{
//public fields & consts		

	//public consts

	//public fields

	//events
	static public var BeforeRescale: CustomDispatcher = new CustomDispatcher();
	
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
	static private const CY_INFO_PANEL_HEIGHT: Number = 24.0;  
	static private const DBL_STANDARD_FRAME_HEIGHT: int = 400;
	static private const DBL_STANDARD_FRAME_WIDTH: int = 550;
	static private const N_MARGIN_WIDTH: int = 300;
	
	//property fields
	static private var FFrameRect: Rect;
	static private var FGameZoneRect: Rect;
	static private var FInfoPanelRect: Rect;
	
	//Определяет, где на экране находится точка отсчета координат аэродрома
	//Задается в: 
	//	FrameBuilder.init
	//	FrameBuilder.scaleScene
	//Используется в:
	//	функциях конвертации между моделью и игровой зоной
	static private var FOrigin: Point;
	static private var FPerformanceMetricsShown: Boolean = false;
	static private var FZoom: Number;	
	
	//other fields
	static private var apAirport: Airport = null;
	static private var dblFrameAdaptationRatio: Number;
	static private var dtFrameCount: Date = new Date(0);
	static private var nFrameCount: int;
	static private var nFramesPerSecond: int;

//properties
	//
	//Location = {0,0}
	//Extent = {stage.stageWidth, stage.stageHeight}
	//Задается в: get FrameRect
	//Не изменяется ли динамически 
	//Используется в: 
	//	FrameBuilder.drawMargin
	//	AircraftView.draw
	//  HintPanelView.show
	//  HintPanelView.getHintPanelRect
	//Всегда ли равен по ширене GameZone.Extent.Width?
	static public function get FrameRect(): Rect
	{
		return FFrameRect;
	}
	
	//Прямоугольник игровой области в единицах сцены Flash без величины панели
	//Задается как: FrameRect - InfoPanelRect
	//Не изменяется ли динамически 
	//Всегда равен FrameRect за вычетом панели
	//Используется в:
	//	AircraftView.displayArrivalMark
	//	AirportView.processMouseEvent
	//  MenuView.getMenuParameters
	static public function get GameZoneRect(): Rect
	{
		return FGameZoneRect;
	}

	//Прямоугольник инфопанели в единицах сцены Flash
	//Задается как:
	//	Location = new Point(0, 0);
	//	Extent = new Size(InfoPanelView.Height, InfoPanelView.Height);
	//Не изменяется ли динамически 
	//Всегда равен FrameRect за вычетом панели
	//Используется в:
	//	InfoPanelView.display
	//	InfoPanelView.setButtonRects
	static public function get InfoPanelRect(): Rect
	{
		return FInfoPanelRect;
	}

	static public function set PerformanceMetricsShown(AValue: Boolean) 
	{
		FPerformanceMetricsShown = AValue;
	}	

	static public function get Zoom(): Number
	{
		return FZoom;
	}
	
//methods
	//public methods
	
	static public function adaptToFrame(ALength: Number): Number 
	{
		return ALength * dblFrameAdaptationRatio;
	}
	
	static public function adaptSizeToFrame(ASize: Size): Size 
	{
		return new Size (ASize.Width * dblFrameAdaptationRatio, ASize.Height * dblFrameAdaptationRatio);
	}

	static public function buildFrame() 
	{
		setFrameDimensions(ScreenManager.createFrame());

		if (!ControlDispatcher.CurrentDisplayMode.IsSplashScreen) {
			displayGameZoneBackground();
		}
		
		if (ControlDispatcher.CurrentDisplayMode.AirportShown) {
			AirportView.display(apAirport, ControlDispatcher.ActiveController.getControllerType() == 0);
			StarView.display();
		}
		
		if (ControlDispatcher.CurrentDisplayMode.MenuShown) {
			MenuView.display();
		}

		if (ControlDispatcher.CurrentDisplayMode.BannerShown) {
			BannerView.display();
		}

		if (ControlDispatcher.CurrentDisplayMode == DisplayMode.Edit) {
			var edit_controller: EditController = EditController.getInstance();
			if (edit_controller.LevelConfig) {
				displayLevelConfig(edit_controller.LevelConfig);
			}
		}
		
		HintPanelView.display();
		
		if (!ControlDispatcher.CurrentDisplayMode.IsSplashScreen) {
			InfoPanelView.display(apAirport);
			
			displayFrameMargins();
		}

		if (FPerformanceMetricsShown)
			displayPerformanceMetrics();
			
		
	}
	
	static public function centerInFrame(ARect: Rect): Rect
	{
		var rect_result = ARect.clone();
		rect_result.Location.X = (FFrameRect.Extent.Width - rect_result.Extent.Width) / 2;
		rect_result.Location.Y = (FFrameRect.Extent.Height - rect_result.Extent.Height) / 2;
		return rect_result;
	}

	static public function convertToModelLength(ALength: Number): Number 
	{
		return ALength * FZoom;
	}
	
	static public function convertToModelPoint(APoint: Point): Point
	{
		return new Point((APoint.X - FOrigin.X) * FZoom, (APoint.Y - FOrigin.Y - FInfoPanelRect.Extent.Height) * FZoom);
	}
	
	static public function convertToModelRect(ARect: Rect): Rect
	{
		return new Rect (convertToModelPoint(ARect.Location), convertToModelSize(ARect.Extent));
	}
	
	static public function convertToModelSize(ASize: Size): Size 
	{
		return new Size(convertToModelLength(ASize.Width), convertToModelLength(ASize.Height));
	}
	
	static public function convertToScreenLength(ALength: Number): Number
	{
		return ALength / FZoom;
	}
	
	static public function convertToScreenPoint(APoint: Point): Point
	{
		return new Point(APoint.X / FZoom + FOrigin.X, APoint.Y / FZoom + FOrigin.Y + FInfoPanelRect.Extent.Height);
	}
	
	static public function convertToScreenRect(ARect: Rect): Rect 
	{
		return new Rect (convertToScreenPoint(ARect.Location), convertToScreenSize(ARect.Extent));
	}
	
	static public function convertToScreenSize(ASize: Size): Size
	{
		return new Size(convertToScreenLength(ASize.Width), convertToScreenLength(ASize.Height));
	}		
				
	static public function init(AnAirport: Airport)		
	{
		apAirport = AnAirport;		

		FOrigin = new Point();
		apAirport.OnResized.addEventListener(CustomDispatcher.ON_RESIZED, Airport_OnResized);
	}

	static public function fitToFrame(ARect: Rect): Rect
	{
		var rect_result = ARect.clone();
		var dbl_hor_scale = FFrameRect.Extent.Width / ARect.Extent.Width;    //10x50 / 500x100 //50
		var dbl_ver_scale = FFrameRect.Extent.Height / ARect.Extent.Height;//2
		var dbl_scale = Math.min(dbl_hor_scale, dbl_ver_scale);
		rect_result.Extent.Width *= dbl_scale; 
		rect_result.Extent.Height *= dbl_scale;			
		
		return centerInFrame(rect_result);
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function displayFrameMargins()
	{
		Profiler.checkin("margins");
		for (var x = -1; x <= 1; x++)
			for (var y = (x ? 0: -1); y <= (x ? 0 : 1); y+=2)
				displayMargin(x, y);
		
		//рамка	
		ScreenManager.displayImage(new BorderImage(), GameZoneRect);
		Profiler.checkout("margins");
	}

	static private function displayGameZoneBackground()
	{
		Profiler.checkin("background");
		ScreenManager.displayImage(new GameZoneBgImage(), GameZoneRect);
		Profiler.checkout("background");
	}
	
	static private function displayLevelConfig(AConfig: XML)
	{
		ScreenManager.displayText(AConfig.toString(), new Rect(new Point(20, 50), new Size(500, -1)), 
			FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_MEDIUM), Colors.White, true, true)		
	}	

	static private function displayMargin(AnX: int, AnY: int)
	{
		var dbl_margin_width = adaptToFrame(N_MARGIN_WIDTH);
		var x: Number = AnX ? ((AnX < 0) ? -dbl_margin_width : FrameBuilder.FrameRect.Extent.Width): 0;
		var y: Number = AnY ? ((AnY < 0) ? -dbl_margin_width : FrameBuilder.FrameRect.Extent.Height): 0;
		var cx: Number = AnX ? dbl_margin_width : FrameBuilder.FrameRect.Extent.Width;
		var cy: Number = AnY ? dbl_margin_width : FrameBuilder.FrameRect.Extent.Height;		
	
		ScreenManager.displayImage(new MarginImage(), new Rect(new Point(x, y), new Size(cx, cy)));
	}

	static private function displayPerformanceMetrics() 
	{
		nFrameCount++;
		var dt: Date = new Date();
		if (dt.getTime() - dtFrameCount.getTime() > 1000)
		{	
			nFramesPerSecond = nFrameCount;
			nFrameCount = 0;
			dtFrameCount = dt;
		}	
		
		var str_text: String = "FPS: " + nFramesPerSecond.toString() 
		+ "\nDisplaying:"
		+ "\n\t" + Profiler.getWatch("background")
		+ "\n\t" + Profiler.getWatch("margins")
		+ "\n\t" + Profiler.getWatch("airport")
		+ "\n\t\t" + Profiler.getWatch("aprons")
		+ "\n\t\t" + Profiler.getWatch("gates")
		+ "\n\t\t" + Profiler.getWatch("airfields")
		+ "\n\t\t" + Profiler.getWatch("aircrafts")
		+ "\n\t\t\t" + Profiler.getWatch("balloons")
		+ "\n\t\t\t" + Profiler.getWatch("shadows")
		+ "\n\t\t\t" + Profiler.getWatch("headlights")
		+ "\n\t\t\t" + Profiler.getWatch("bodies")
		+ "\n\t\t\t" + Profiler.getWatch("gauges")	
		+ "\n\t\t\t" + Profiler.getWatch("paths")
		+ "\n\t" + Profiler.getWatch("menu")
		+ "\n\t" + Profiler.getWatch("hint")
		+ "\n\t" + Profiler.getWatch("banner")
		+ "\n" + Profiler.getWatch("Computing")
		+ "\nDisplay objects: " + ScreenManager.DisplayObjectsCount;
		ScreenManager.displayText(str_text, new Rect(new Point(50, 50), new Size(-1, -1)), FrameBuilder.adaptToFrame(ScreenManager.FONT_SIZE_SMALL));
	}
		
	static private function scaleScene()
	{
		BeforeRescale.fireBeforeRescale();
		
		FZoom = apAirport.Extent.Width/GameZoneRect.Extent.Width;//after fix apAirport.CY / cyScreen == apAirport.CX / cxScreen
		//1. 0 аэропорта совпадает с 0 экрана
		//2. - apAirport.X/FZoom - сдвигаем 0 аэропорта чтобы 0 экрана совпал с левой границей аэропорта
		//3. apAirport.CX/FZoom  - получаем размер аэропорта в экранном размере
		//4. cxScreen -                    - получаем лишнее, свободное место экрана не занятое аэропортом
		//5. /2.0                          - делим лишнее место, чтобы получить ширину поля слева (справа будет равное)
		//6. +                             - сдвигаем аэропорт на ширину левого поля 
		FOrigin.X = - apAirport.Location.X/FZoom + (GameZoneRect.Extent.Width - apAirport.Extent.Width/FZoom)/2.0;
		FOrigin.Y = - apAirport.Location.Y/FZoom + (GameZoneRect.Extent.Height - apAirport.Extent.Height/FZoom)/2.0;		
	}

	static private function setFrameDimensions(AFrameSize: Size)
	{
		FFrameRect = new Rect(new Point(), ScreenManager.StageSize);	

		if (FFrameRect.Extent.Width > FFrameRect.Extent.Height)
			dblFrameAdaptationRatio = FFrameRect.Extent.Height / DBL_STANDARD_FRAME_HEIGHT;
		else
			dblFrameAdaptationRatio = FFrameRect.Extent.Width / DBL_STANDARD_FRAME_WIDTH;

		FInfoPanelRect = new Rect(new Point(), new Size(FFrameRect.Extent.Width, adaptToFrame(CY_INFO_PANEL_HEIGHT)));		
		
		var sz_game_zone: Size = ScreenManager.StageSize.clone();
		sz_game_zone.Height -= FInfoPanelRect.Extent.Height;
		FGameZoneRect = new Rect(new Point(0, FInfoPanelRect.Extent.Height), sz_game_zone);		
	}

	//event handlers	
	static private function Airport_OnResized(AnEvent: Event):void 
	{
		scaleScene();
	}
}
}