package ap.instrumental {

///////////////////////////////////////////////////////////
//  ScreenManager.as
///////////////////////////////////////////////////////////

import flash.display.CapsStyle;
import flash.display.DisplayObject;
import flash.display.GraphicsPathCommand
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import ap.basic.*;
import ap.enumerations.Colors;
import ap.views.InfoPanelView;
import ap.views.FrameBuilder;

public class ScreenManager //static
{
//public fields & consts		

	//public consts	
	//font sizes
	public static const FONT_SIZE_TINY: int = 8;
	public static const FONT_SIZE_SMALL: int = 12;
	public static const FONT_SIZE_MEDIUM: int = 16;
	public static const FONT_SIZE_LARGE: int = 32;

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
	//static private var smInstance: ScreenManager = null;
	
	//property fields

	//other fields
	static private var stgStage: Stage;

//properties

	static public function get DisplayObjectsCount (): int
	{
		return stgStage.numChildren;
	}

	static public function get StageSize (): Size
	{
		return new Size(stgStage.stageWidth, stgStage.stageHeight);
	}
//methods
	//public methods
	static public function createFrame(): Size
	{
		var i:int=0;
		while (i < stgStage.numChildren) 
		{
			stgStage.removeChildAt(i);
		}
		
	//	createFrameBuffer();

		return StageSize;
	}

	static public function displayFrame()
	{
		/*
		spFrameBuffer.x = 0;
		spFrameBuffer.y = 0;
		spFrameBuffer.width = stgStage.stageWidth;
		spFrameBuffer.height = stgStage.stageHeight;
		*/
		//stgStage.addChild(spFrameBuffer);
	}
	
	static public function displayImage(AnImage: DisplayObject, ARect: Rect, AnAngle: Angle = null) 
	{
		AnImage.x = ARect.Location.X;
		AnImage.y = ARect.Location.Y;
		if (ARect.Extent.Width >= 0 && ARect.Extent.Height >= 0)
		{
			AnImage.width = ARect.Extent.Width;
			AnImage.height = ARect.Extent.Height;
		}
		
		if (AnAngle)
		{
			AnImage.rotation = AnAngle.Degree;
		}

		//spFrameBuffer.addChild(AnImage);
		stgStage.addChild(AnImage);
	}
		
	static public function displayText(AText: String, ARect: Rect, 	AFontSize: Number = FONT_SIZE_MEDIUM, 
		AColor: int = 0xFFFFFF, ToShowBackground: Boolean = false, 
		IsInputField: Boolean = false, IsMultiline: Boolean = true)		
	{
		var txt_field: TextField = new TextField();
		
		txt_field.autoSize = TextFieldAutoSize.LEFT;
		
		if (ARect.Extent.Width >= 0) txt_field.width = ARect.Extent.Width;
		if (ARect.Extent.Height >= 0) txt_field.height = ARect.Extent.Height;
		if (ToShowBackground) txt_field.background = true;
		if (IsInputField) 
		{
			txt_field.type = TextFieldType.INPUT;
			if (IsMultiline)
			{
				txt_field.wordWrap = true;
				txt_field.multiline = true;
			}
		}
		
		txt_field.defaultTextFormat = new TextFormat("Arial", AFontSize, AColor);
		txt_field.text = AText; 
		if (ARect is Region)
		{
			txt_field.autoSize = TextFieldAutoSize.CENTER;
			txt_field.rotation = Region(ARect).Rotation.Degree;
			txt_field.x = ARect.Location.X - txt_field.textWidth/2;
			txt_field.y = ARect.Location.Y - txt_field.textHeight/2;
		}		
		else
		{
			txt_field.x = ARect.Location.X;
			txt_field.y = ARect.Location.Y;
		}
		stgStage.addChild(txt_field);
	}
	
	static public function drawLine(APointVector: Vector.<Point>, AColor: int, AnAlpha: Number)
	{
		if (APointVector.length < 2) return;

		var shp_path: Shape = new Shape();
		shp_path.graphics.lineStyle(1, AColor, AnAlpha, false, LineScaleMode.NONE, CapsStyle.NONE, null, 3);
	
		var vdbl_data: Vector.<Number> = convertToIntVector(APointVector);
		var vn_commands: Vector.<int> = getCommands(APointVector.length);
				
		shp_path.graphics.drawPath(vn_commands, vdbl_data);
		
		//spFrameBuffer.addChild(shp_path);
		stgStage.addChild(shp_path);
	}

	static public function init(AStage: Stage)
	{
		stgStage = AStage;
	}
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods
	static private function convertToIntVector(APath: Vector.<Point>): Vector.<Number>
	{	
		var vn_result: Vector.<Number> = new Vector.<Number>();
		for each (var pnt: Point in APath)
		{
			vn_result.push(pnt.X);
			vn_result.push(pnt.Y);
		}
		return vn_result;
	}
	
	static private function createFrameBuffer()
	{
		/*spFrameBuffer = new Sprite();
		spFrameBuffer.x = 0;
		spFrameBuffer.y = 0;
		spFrameBuffer.width = stgStage.stageWidth;
		spFrameBuffer.height = stgStage.stageHeight;*/
	}
	
	static private function getCommands(ALength: int): Vector.<int>
	{
		var vn_result: Vector.<int> = new Vector.<int>();	
		vn_result.push(GraphicsPathCommand.MOVE_TO);
		for (var i: int = 1; i < ALength; i++)
			vn_result.push(GraphicsPathCommand.LINE_TO);
		return vn_result;
	}
	
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
