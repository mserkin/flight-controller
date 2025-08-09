Анализ использования функций вывода текста

Используемые свойства текстового поля
	done - fixed - font: Arial
	done - AFontSize -size: 8, 12, 16, 32
	done - AColor - color: Blue, White, Brown, ControlDispatcher.CurrentDisplayMode.Color
	done - ARect - x,y, width/nothing, height/nothing 
	done - ARect - autosize: TextFieldAutoSize.LEFT / TextFieldAutoSize.CENTER / nothing 
	done - ToShowBackground - background = true/nothing;
	done - IsMultiline - multiline = true/nothing
	done - IsMultiline - wordWrap = true/nothing
	done - IsInputField - type = TextFieldType.INPUT/nothing
	
	Типы: 
		статический текст
		многострочный текст
		поле ввода без возможности ввода

	ScreenManager.displayText(AText: String, ARect: Rect, 
		AFontSize: int = ScreenManager.FONT_SIZE_MIDDLE, AColor: int = Colors.White,
		ToShowBackground: Boolean = false, IsInputField: Boolean = false, IsMultiline: Boolean = true)
		
	AirportView::displayText(AText: String, ASize: Number, AColor: int, APoint: Point)
	{
		var tf_format: TextFormat = new TextFormat();
		tf_format.font="Arial";
		tf_format.size=ASize;
		tf_format.color=AColor;
		var txt_info: TextField = new TextField();
		txt_info.x = APoint.X;
		txt_info.y = APoint.Y;
		txt_info.autoSize = TextFieldAutoSize.LEFT;
		txt_info.defaultTextFormat = tf_format;
		txt_info.text = AText;
		ScreenManager.displayImage(txt_info, new Rect(APoint, new Size(-1, -1)));
	}
			
	FrameBuilder::displayDebug() 
	{
		...
		//стиль
		var tf_format: TextFormat = new TextFormat();
		tf_format.font="Arial";
		tf_format.size=16;
		tf_format.color=Colors.White;
	
		//текст
		var txt_info: TextField = new TextField();
		txt_info.autoSize = TextFieldAutoSize.LEFT;
		txt_info.defaultTextFormat = tf_format;
		txt_info.text = str_text;
		//TODO реализовать логику, связанную с выводом текста в ScreenManager.getText
		ScreenManager.displayImage(txt_info, new Rect(new Point(50, 50), new Size(-1, -1)));	
	}

	FrameBuilder::displayLevelConfig(AConfig: XML)
	{
		var outputText:TextField = new TextField();
			
		outputText.x = 20;
		outputText.y = 20;
		outputText.width = 500;
		outputText.background = true;
		outputText.autoSize = TextFieldAutoSize.LEFT;
		outputText.wordWrap = true;
		outputText.type = TextFieldType.INPUT;
	
		outputText.text = AConfig.toString();
	
		ScreenManager._Stage.addChild(outputText);			
	}	

	FrameBuilder::printTitle(AText: String, AColor: int) 
	{
		//стиль
		var tf_format: TextFormat = new TextFormat();
		tf_format.font="Arial";
		tf_format.size=32;
		tf_format.color=AColor;//черный
	
		//текст
		var txt_info: TextField = new TextField();
		txt_info.defaultTextFormat=tf_format;
		txt_info.autoSize=TextFieldAutoSize.CENTER;
		txt_info.text=AText;
		txt_info.x=FrameBuilder.ScreenSize.Width/2-txt_info.textWidth/2;
		txt_info.y=FrameBuilder.ScreenSize.Height/2-txt_info.textHeight/2;
		ScreenManager._Stage.addChild(txt_info);
	}
	
	ScreenManager::displayText(AText: String, AFont: String, ASize: Number, AColor: Object, 
		AnX: Number, AnY: Number, AWidth: Number = 0, AHeight: Number = 0)
	{
		var txt_info: TextField = new TextField();
		txt_info.x = AnX;
		txt_info.y = AnY;

		if (AWidth > 0) txt_info.width = AWidth;
		if (AHeight > 0)
		{
			txt_info.wordWrap = true;
			txt_info.multiline = true;
			txt_info.height = AHeight;
		}
		txt_info.defaultTextFormat = new TextFormat(AFont, ASize, AColor);
		txt_info.text = AText; 

		FStage.addChild(txt_info);
	}
		ScreenManager.displayText("Level " + GameProgress.Level.toString(), "Arial", 12, Colors.Brown, 
			X_TITLE_LEVEL_NUMBER, Y_TITLE_LEVEL_NUMBER)
			
	font: Arial
	size: 8, 12, 16, 32
	color: Blue, White, Brown, ControlDispatcher.CurrentDisplayMode.Color
	x,y, width/nothing, height/nothing 
	autosize: TextFieldAutoSize.LEFT / TextFieldAutoSize.CENTER / nothing
	background = true;
	multiline = true/nothing
	wordWrap = true/nothing
	type = TextFieldType.INPUT/nothing