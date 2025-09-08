package ap.model {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import ap.basic.*;
import ap.instrumental.CustomDispatcher;

public class Airport extends Rect
{
//public fields & consts		

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events

	public var OnGateLoaded: CustomDispatcher = new CustomDispatcher();
	public var OnLevelLoaded: CustomDispatcher = new CustomDispatcher();
	public var OnResized: CustomDispatcher = new CustomDispatcher();

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
	/*private const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//property fields
    private var FAircrafts: Vector.<Aircraft> = new Vector.<Aircraft>();

    private var FAirfields: Vector.<IAirfield> = new Vector.<IAirfield>();
    private var FAprons: Vector.<SelectableObject> = new Vector.<SelectableObject>();
	private var FCloudProbability: Number;
	private var FClouds: Vector.<Cloud> = new Vector.<Cloud>();
	private var FCurrentWind: Wind;
	private var FGates: Vector.<Gate> = new Vector.<Gate>();
	private var FThumbnailMode: Boolean;

	//other fields
	private var ulLoader: URLLoader;	
	
//properties

    public function get Aircrafts(): Vector.<Aircraft>
    {
    	return FAircrafts;
    }

    public function get Airfields(): Vector.<IAirfield>
    {
    	return FAirfields;
    }

	public function get Aprons(): Vector.<SelectableObject>
    {
    	return FAprons;
    }

	public function get Clouds(): Vector.<Cloud>
    {
    	return FClouds;
    }	
	
	public function get CloudProbability(): Number
    {
    	return FCloudProbability;
    }	
	
	public function get CurrentWind(): Wind
    {
    	return FCurrentWind;
    }	
	
    public function get Gates(): Vector.<Gate>
    {
    	return FGates;
    }

    public function get ThumbnailMode(): Boolean
    {
    	return FThumbnailMode;
    }

//methods
	//constructor
	public function Airport (IsThumbnailMode: Boolean = false)
	{
		FThumbnailMode = IsThumbnailMode;
		super(new Point(0, 0), new Size(0, 0));
		
		trace ("Airport created!");
	}		

	//public methods

	public function findGate(AnId: String): Gate
	{
		for each (var gate: Gate in FGates)
		{
			if (gate.Id == AnId)
				return gate;
		}
		return null;
	}

	public function fixAirportRect(AHorZoom: Number, AVertZoom: Number): void
    {
		if (AVertZoom > AHorZoom)
		{
			var cx_fixed = this.Extent.Width / AHorZoom * AVertZoom;
			this.Location.X -=(cx_fixed - this.Extent.Width) / 2;
			this.Extent.Width = cx_fixed;
		}
		else
		{
			var cy_fixed = this.Extent.Height / AVertZoom * AHorZoom;
			this.Location.Y -=(cy_fixed - this.Extent.Height) / 2;
			this.Extent.Height = cy_fixed;
		}
	}

	public function getAirportModelRegion(): Region
	{
		var region: Region = new Region();
		for each (var airfield: IAirfield in Airfields)
		{
			var apoints: Vector.<Point> = airfield.getRegion().CornerPoints;
			for (var j: int = 0; j < apoints.length; j++)
			{
				var point: Point = apoints[j];
				var x_left: Number = region.Location.X - region.Extent.Width / 2;
				var x_right: Number = region.Location.X + region.Extent.Width / 2;
				var y_top: Number = region.Location.Y - region.Extent.Height / 2;
				var y_bottom: Number = region.Location.Y + region.Extent.Height / 2;
				var cx_left_shift = x_left - point.X;
				var cx_right_shift = point.X - x_right;
				var cy_top_shift = y_top - point.Y;
				var cy_bottom_shift = point.Y - y_bottom;
				if (cx_left_shift > 0)
				{
					region.Extent.Width += cx_left_shift;
					region.Location.X -= cx_left_shift / 2;
				}
				else if (cx_right_shift > 0)
				{
					region.Extent.Width += cx_right_shift;
					region.Location.X += cx_right_shift / 2;
				}
				if (cy_top_shift > 0)
				{
					region.Extent.Height += cy_top_shift;
					region.Location.Y -= cy_top_shift / 2;
				}
				else if (cy_bottom_shift > 0)
				{
					region.Extent.Height += cy_bottom_shift;
					region.Location.Y += cy_bottom_shift / 2;
				}
			}
		}
		return region;
	}

	public function loadLevel(ALevelFile: String)
    {
		ulLoader = new URLLoader();
		var urlr_file: URLRequest = new URLRequest(ALevelFile);
		try {
			ulLoader.addEventListener(Event.COMPLETE, URLLoader_OnComplete);
			ulLoader.load(urlr_file);
		} 
		catch (error:Error) 
		{
			trace("  Unable to load file " + ALevelFile);
		}		
    }

	public function makeLevelXML(): XML
	{
		var xml_doc: XML = new XML('<level></level>');
		saveGates(xml_doc);
		saveAirfields(xml_doc);
		saveAprons(xml_doc);

		return xml_doc;
	}	
	
	public function resize(ALocation: Point, AnExtent: Size)
	{
		this.Location = ALocation;
		this.Extent = AnExtent;
		
		OnResized.fireOnResized();
	}

	public function updateWind()
	{
		FCurrentWind.update();
		for each (var airfield: IAirfield in FAirfields)
		{
			airfield.updateWind(FCurrentWind.Direction);
		}
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	
	private function loadAirport(AnXml: XML): void
	{
		resize(
			new Point(AnXml.@left, AnXml.@top), 
			new Size(AnXml.@width, AnXml.@height)
		);
		
		if (!FThumbnailMode)
		{
			loadGates(AnXml.gates[0]);
			loadHelipads(AnXml.helipads[0]);
			loadAprons(AnXml.aprons[0]);		
		}
		loadRunways(AnXml.runways[0]);
	}
	
	private function loadAprons(AnXml: XML): void
    {
		if (!AnXml || !AnXml.apron) return;
		
		for each (var xml_node: XML in AnXml.apron)
		{
			FAprons.push(SelectableObject.fromXml(xml_node));
		}
	}
		
	private function loadGates(AnXml: XML): void
    {
		for each (var xml_node in AnXml.gate)
		{
			var gate: Gate = Gate.fromXml(xml_node);
			FGates.push(gate);
			
			OnGateLoaded.fireOnGateLoaded(gate);
		}
	}

	private function loadHelipads(AnXml: XML)
	{
		if (!AnXml || !AnXml.helipad) return;
		
		for each (var xml_helipad: XML in AnXml.helipad)
		{
			var helipad: Helipad = Helipad.fromXml(xml_helipad);
			FGates.push(helipad);
			FAirfields.push(helipad);
			
			OnGateLoaded.fireOnGateLoaded(helipad);			
		}
	}	
	
	private function loadLevelCont()
    {
		var xml_doc: XML = new XML(ulLoader.data);
		ulLoader.close();

		var xml_airport: XML = xml_doc.airport[0];

		if (!xml_airport)
		{
			trace("Failed to load level: airport tag not found.");
			return;
		}
		
		if (!FThumbnailMode)
		{
			loadWeather(xml_doc.weather[0]);
		}
		loadAirport(xml_airport);

		OnLevelLoaded.fireOnLevelLoaded();
	}
		
	private function loadRunways(AnXml: XML)
	{
		if (!AnXml || !AnXml.runway) return;		
		
		for each (var xml_runway: XML in AnXml.runway)
		{
			FAirfields.push(new Runway(xml_runway, this));
		}
	}
	
	private function loadWeather(AnXml: XML)
	{
		var dbl_cloud_probability: Number = AnXml.clouds[0].@probability;
		var xml_wind: XML = AnXml.wind[0];
		var dbl_wind_variability: Number = xml_wind.@variability;
		var dbl_wind_min_speed: Number = xml_wind.@minSpeed;
		var dbl_wind_max_speed: Number = xml_wind.@maxSpeed;
		
		FCurrentWind = new Wind(dbl_wind_min_speed, dbl_wind_max_speed, dbl_wind_variability);
		FCloudProbability = dbl_cloud_probability;
	}
	
	private function saveAirfields(AnXmlNode: XML): void
	{
		var xml_runways: XML = new XML('<runways></runways>');
		AnXmlNode.appendChild(xml_runways);
		
		for each (var airfield: IAirfield in FAirfields)
		{
			var xml_runway: XML = new XML('<runway></runway>');
			xml_runways.appendChild(xml_runway);

			airfield.toXml(xml_runway);
		}
	}
 	
	private function saveAprons(AnXmlNode: XML): void
	{
		var xml_aprons: XML = new XML('<aprons></aprons>');
		AnXmlNode.appendChild(xml_aprons);
		
		for each (var mo_apron: SelectableObject in FAprons)
		{
			var xml_apron: XML = new XML('<apron></apron>');
			xml_aprons.appendChild(xml_apron);
			
			mo_apron.toXml(xml_apron);
		}
	}

	private function saveGates(AnXmlNode: XML): void
	{
		var xml_gates: XML = new XML('<gates></gates>');
		AnXmlNode.appendChild(xml_gates);
		
		for each(var gate: Gate in FGates)
		{
			var xml_gate: XML = new XML('<gate></gate>');
			xml_gates.appendChild(xml_gate);

			gate.toXml(xml_gate);
		}
	}

	//event handlers
	
	private function URLLoader_OnComplete(AnEvent: Event): void
	{
		loadLevelCont();
	}
}
}