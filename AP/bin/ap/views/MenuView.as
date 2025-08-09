package ap.views {

///////////////////////////////////////////////////////////
//  MenuView.as
///////////////////////////////////////////////////////////

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.*;
import ap.basic.*;
import ap.controllers.ControlDispatcher;
import ap.controllers.GameProgress;
import ap.controllers.MenuController;
import ap.enumerations.DisplayMode;
import ap.instrumental.Profiler;
import ap.instrumental.ScreenManager;
import ap.model.Airport;
import ap.model.IAirfield;

public class MenuView
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
	static private const CX_PROGRESS: Number = 78.8; 
	static private const CY_PROGRESS: Number = 20.50;
	static private const CY_PROGRESS_BOTTOM_MARGIN: Number = 6;
	static private const CY_THUMBNAIL_RELATIVE_TO_ICON: Number = 0.8;
	static private const DBL_BOX_CLOSED_ICON_HEIGHT_RATIO: Number= 1.13;	
	static private const DBL_HORIZONTAL_MARGIN: Number = 0.045; //relative to GameZone height
	static private const DBL_SPACE_ICON_RATIO: Number = 0.5; //отношение места между иконками к размеру иконки
	static private const DBL_THUMBNAIL_MINIATURE_SPACING: Number = 0.1; //отношение полей миниатюры к размеру пиктограммы
	static private const DBL_VERTICAL_MARGIN: Number = 0.066; //relative to GameZone height
	static private const N_BOX_MENU_COLUMNS: int = GameProgress.N_BOX_COUNT;
	static private const N_BOX_MENU_ROWS: int = 1;
	static private const N_LEVEL_MENU_COLUMNS: int = 3;
	static private const N_LEVEL_MENU_ROWS: int = 3;
	static private const STR_SPRITE_NAME1: String = "Box";
	static private const STR_SPRITE_NAME2: String = "ThumbnailImage";
	static private const X_PROGRESS: Number = 98.60; 
	static private const Y_PROGRESS: Number = 155.65; 
	
	//property fields


	//other fields

//properties

//methods
	//constructor
	//public methods
	
	static public function display()
	{
		Profiler.checkin("menu");
		var is_box_menu: Boolean = (ControlDispatcher.CurrentDisplayMode == DisplayMode.BoxMenu);
		var obj_params: Object = getMenuParameters(is_box_menu);

		var n_item_number = is_box_menu ? -1 : GameProgress.BoxFirstLevel - 1;
		var n_item_last = is_box_menu ? GameProgress.N_BOX_COUNT - 1 : GameProgress.BoxLastLevel;
		for (var y: int = 0; y < obj_params.IconRows; y++)
		{
			for (var x: int = 0; x < obj_params.IconColumns; x++)
			{
				if (++n_item_number > n_item_last) break;
				
				var rect_icon: Rect = new Rect(
					new Point(
						obj_params.HorizontalMargin + (obj_params.IconWidth + obj_params.HorizontalSpace)*x, 
						obj_params.VerticalMargin + FrameBuilder.InfoPanelRect.Extent.Height + (obj_params.IconHeight + obj_params.VerticalSpace)*y
					), 
					new Size(obj_params.IconWidth, obj_params.IconHeight)
				)
	
				displayBoxIcon(is_box_menu, n_item_number, rect_icon, obj_params);
			}
		}		
		Profiler.checkout("menu");
	}

	static public function displayBoxIcon(IsBox: Boolean, AnItemNumber: int, AnIconRect: Rect, ABoxParams: Object = null)
	{
		if (!ABoxParams)
		{
			var ABoxParams: Object = getMenuParameters(IsBox);
		}
		var dbl_progress: Number = IsBox ? GameProgress.getBoxProgress(AnItemNumber) : GameProgress.LevelCompletion[AnItemNumber-1] / 100;
		var sp_icon_frame: Sprite = (dbl_progress >= 1) ? new BoxCompleteImage() : new BoxOpenImage();				
		ABoxParams.HorizontalZoom = AnIconRect.Extent.Width / sp_icon_frame.width;
		ABoxParams.VerticalZoom = AnIconRect.Extent.Height / sp_icon_frame.height;
		
		displayProgress(dbl_progress, AnIconRect, ABoxParams);	
		ScreenManager.displayImage(sp_icon_frame, AnIconRect, new Angle());		
		displayThumbnail(IsBox, AnItemNumber, AnIconRect, ABoxParams);
			
		if (IsBox && (!GameProgress.IS_BOSS_MODE_ON && AnItemNumber != 0 
			&& GameProgress.getBoxProgress(AnItemNumber - 1) < 1
			|| AnItemNumber == GameProgress.NewlyOpenedBox))
		{
			var sp_lock: Sprite = (AnItemNumber == GameProgress.NewlyOpenedBox) ? new LockOpenedImage() : new LockClosedImage();
			ScreenManager.displayImage(sp_lock, AnIconRect, new Angle());
		}
	}
	
	static public function processEvent(AnEvent: Event): Boolean
	{
		if (AnEvent is MouseEvent && AnEvent.type == MouseEvent.CLICK)
		{
			var mouse_event: MouseEvent = MouseEvent(AnEvent);
			
			switch (ControlDispatcher.CurrentDisplayMode)
			{
				case DisplayMode.LevelMenu:
					return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_MENU_LEVEL_SELECT, 
						{LevelNumber: getLevelByCoords(mouse_event.stageX, mouse_event.stageY)});
					break;
				case DisplayMode.BoxMenu:
					return ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_MENU_BOX_SELECT, 
						MenuView.getBoxByCoords(mouse_event.stageX, mouse_event.stageY));					
					break;				
				default: return false;
			}
		}
		return false;
	}
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods
		
	static private function displayAirfield(AnAirfield: IAirfield, AThumbnailRect: Rect, AZoom: Number, AModelCenter: Point)
	{
		if (!AnAirfield.IsRunway) return;
		var rect_scr: Region = AnAirfield.getRegion().cloneRegion();
		rect_scr.Extent.Width /= AZoom;
		rect_scr.Extent.Height /= AZoom;
		rect_scr.Location.X = (rect_scr.Location.X - AModelCenter.X) / AZoom 
			+ AThumbnailRect.Location.X + AThumbnailRect.Extent.Width/2;
		rect_scr.Location.Y = (rect_scr.Location.Y - AModelCenter.Y) / AZoom 
			+ AThumbnailRect.Location.Y + AThumbnailRect.Extent.Height/2;
			
		ScreenManager.displayImage(new RunwayThumbnailImage(), rect_scr, AnAirfield.ActiveCourse);
	}
	
	static private function displayProgress(AProgress: Number, AnIconRect: Rect, AParams: Object)
	{
		AProgress = Math.min(AProgress, 1);
		var sp_bg: Sprite = new MenuProgressBackgroundImage();	
		var rect_bg: Rect = new Rect(
			new Point(
				AnIconRect.Location.X + X_PROGRESS * AParams.HorizontalZoom, 
				AnIconRect.Location.Y + Y_PROGRESS * AParams.VerticalZoom
			), 
			new Size(CX_PROGRESS * AParams.HorizontalZoom, CY_PROGRESS * AParams.VerticalZoom)
		);
				
		var sp_filler: Sprite = new MenuProgressFillerImage();
		var rect_filler: Rect = rect_bg.clone();
		rect_filler.Extent.Width *= AProgress;
		ScreenManager.displayImage(sp_bg, rect_bg, new Angle());
		ScreenManager.displayImage(sp_filler, rect_filler, new Angle());
	}

	static private function displayThumbnail(IsBox: Boolean, AnItemNumber: int, AnIconRect: Rect, AParams: Object)
	{
		var rect_thumbnail = AnIconRect.clone();
		rect_thumbnail.Extent.Width *= CY_THUMBNAIL_RELATIVE_TO_ICON;
		var dbl_margin: Number = (AnIconRect.Extent.Width - rect_thumbnail.Extent.Width) / 2;
		rect_thumbnail.Location.X += dbl_margin;
		rect_thumbnail.Location.Y += dbl_margin;
		rect_thumbnail.Extent.Height -= dbl_margin*2 + CY_PROGRESS * AParams.VerticalZoom 
			+ FrameBuilder.adaptToFrame(CY_PROGRESS_BOTTOM_MARGIN);

		ScreenManager.displayImage(new ThumbnailBoxImage, rect_thumbnail, new Angle());

		rect_thumbnail.Location.X += rect_thumbnail.Extent.Width * DBL_THUMBNAIL_MINIATURE_SPACING;
		rect_thumbnail.Location.Y += rect_thumbnail.Extent.Height * DBL_THUMBNAIL_MINIATURE_SPACING;
		rect_thumbnail.Extent.Width *= (1 - 2*DBL_THUMBNAIL_MINIATURE_SPACING);
		rect_thumbnail.Extent.Height *= (1 - 2*DBL_THUMBNAIL_MINIATURE_SPACING);
		
		if (IsBox) {
			var classSprite: Class = getDefinitionByName(STR_SPRITE_NAME1 + AnItemNumber + STR_SPRITE_NAME2) as Class;
			var clip: Sprite = new classSprite();
			ScreenManager.displayImage(clip, rect_thumbnail);
		}	
		else {
			var airport: Airport = MenuController.getInstance().ThumbnailModels[AnItemNumber - 1];
			var rg_model: Region = airport.getAirportModelRegion();
			var dbl_zoom: Number = Math.max(rg_model.Extent.Width / rect_thumbnail.Extent.Width, 
				rg_model.Extent.Height / rect_thumbnail.Extent.Height);

			for each (var airfield: IAirfield in airport.Airfields)	{
				displayAirfield(airfield, rect_thumbnail, dbl_zoom, rg_model.Location);
			}
		}
	}

	static private function getBoxByCoords(AnX: Number, AnY: Number): Object
	{
		var obj_level_params = getMenuParameters(new Boolean(false));
		var obj_result = {BoxNumber: -1, OpeningLevel: -1, IsBoxLocked: true};
		var n_box_no: int = getMenuIconNumberByCoords(true, AnX, AnY);
		if (n_box_no >= 0 && n_box_no < GameProgress.N_BOX_COUNT)
		{
			obj_result.BoxNumber = n_box_no;
			obj_result.OpeningLevel = GameProgress.getFirstLevelForBox(n_box_no);
			obj_result.IsBoxLocked = !GameProgress.IS_BOSS_MODE_ON && n_box_no > 0 && GameProgress.getBoxProgress(n_box_no - 1) < 1;
		}
		return obj_result;
	}

	static private function getLevelByCoords(AnX: Number, AnY: Number): int
	{
		var obj_params = getMenuParameters(new Boolean(false));

		var n_icon_number = getMenuIconNumberByCoords(false, AnX, AnY);
		var n_level_number = GameProgress.BoxFirstLevel + n_icon_number;
		if (n_icon_number >= 0 && n_level_number <= GameProgress.BoxLastLevel)
			return n_level_number;
		else
			return -1;
	}	
	
	static private function getMenuIconNumberByCoords(IsBoxMenu: Boolean, AnX: Number, AnY: Number): int
	{
		var obj_params = getMenuParameters(IsBoxMenu);
		
		var n_row: int = Math.floor((AnY - FrameBuilder.InfoPanelRect.Extent.Height - obj_params.VerticalMargin)/(obj_params.IconHeight + obj_params.VerticalSpace));
		if (AnY - FrameBuilder.InfoPanelRect.Extent.Height - obj_params.VerticalMargin - (obj_params.IconHeight + obj_params.VerticalSpace) * n_row > obj_params.IconHeight) return -1;
			
		var n_column: int = Math.floor((AnX - obj_params.HorizontalMargin)/(obj_params.IconWidth + obj_params.HorizontalSpace));
		if (AnX - obj_params.HorizontalMargin - (obj_params.IconWidth + obj_params.HorizontalSpace) * n_column > obj_params.IconWidth) return -1;
		
		return n_row * obj_params.IconColumns + n_column;
	}

	static private function getMenuParameters(IsBoxMenu: Boolean)
	{
		var obj_params: Object = {};		
		if (IsBoxMenu) {
			obj_params.IconColumns = N_BOX_MENU_COLUMNS;
			obj_params.IconRows = N_BOX_MENU_ROWS;
		}
		else {
			obj_params.IconColumns = N_LEVEL_MENU_COLUMNS;
			obj_params.IconRows = N_LEVEL_MENU_ROWS;
		}		
		obj_params.HorizontalMargin = DBL_HORIZONTAL_MARGIN*FrameBuilder.GameZoneRect.Extent.Width;
		obj_params.VerticalMargin = DBL_VERTICAL_MARGIN*FrameBuilder.GameZoneRect.Extent.Height;
		var cx_menu: Number = FrameBuilder.GameZoneRect.Extent.Width * (1 - DBL_HORIZONTAL_MARGIN * 2);
		var cy_menu: Number = FrameBuilder.GameZoneRect.Extent.Height * (1 - DBL_VERTICAL_MARGIN * 2);
		var cx_icon: Number =  cx_menu / ((DBL_SPACE_ICON_RATIO + 1)*(obj_params.IconColumns - 1) + 1);;
		var cy_icon: Number =  cy_menu / ((DBL_SPACE_ICON_RATIO + 1)*(obj_params.IconRows - 1) + 1);		
		if (cx_icon > cy_icon) {
			obj_params.HorizontalSpace = (cx_menu - cy_icon*obj_params.IconColumns)/(obj_params.IconColumns - 1);
			if (obj_params.HorizontalSpace > cy_icon) {
				obj_params.HorizontalSpace = cy_icon;
				obj_params.HorizontalMargin += (cx_menu - cy_icon*(obj_params.IconColumns*2 - 1))/2;
			}
			obj_params.VerticalSpace = cy_icon * DBL_SPACE_ICON_RATIO;
			obj_params.IconWidth = cy_icon;
			obj_params.IconHeight = cy_icon;
		}
		else {
			obj_params.HorizontalSpace = cx_icon * DBL_SPACE_ICON_RATIO;
			obj_params.VerticalSpace = (cy_menu - cx_icon*obj_params.IconRows)/(obj_params.IconRows - 1);
			if (obj_params.VerticalSpace > cx_icon) {
				obj_params.VerticalSpace = cx_icon;
				obj_params.VerticalMargin += (cy_menu - cx_icon*(obj_params.IconRows*2 - 1))/2;
			}
			obj_params.IconWidth = cx_icon;
			obj_params.IconHeight = cx_icon;
		}
		return obj_params;
	}
	
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
