///////////////////////////////////////////////////////////
//  IAirfield.as
///////////////////////////////////////////////////////////

package ap.model
{

import ap.basic.Angle;
import ap.basic.Point;
import ap.basic.Region;

public interface IAirfield
{
	
//properties
	function get ActiveCourse(): Angle;

	function get BackCourseLightsDistance(): Number;
	
	function get Course(): Angle	

	function get CourseLightsDistance(): Number;
	
	function get Gates(): Vector.<Gate>;

	function get IsRunway(): Boolean;	
	
	function get Length(): Number;

    function get Location(): Point;
	
	function set Location(AValue: Point);
	
	function get Occupied(): Boolean;
	
	function get OccupiedBy(): Aircraft;
	
    function get Selected(): Boolean

    function set Selected(IsSelected: Boolean)	

	function get UpwindCourse(): Angle;
	
	function get Width(): Number;

//methods
	//constructor

	//public methods

	function exchangeGate(AGate: Gate, ALocation: Point): Gate;

	function free(AnAircraft: Aircraft): void;
	
	function getRegion(): Region;

	function inArea(APoint: Point);
	
	function inLandingZone(APoint: Point): Boolean;
	
	function occupyToLand(AnAircraft: Aircraft): Gate;

	function occupyToTakeoff(AnAircraft: Aircraft): Boolean;

	function toString(AnIndent: int = 0): String;

	function toXml(AnXmlNode: XML);

	function updateWind(AWindDirection: Angle);

}
}
