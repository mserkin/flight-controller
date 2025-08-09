package ap.basic {

///////////////////////////////////////////////////////////
//  Points.as
///////////////////////////////////////////////////////////

import ap.basic.PointsEventDispatcher;

public class Points
{
	//events
	public var OnAdd: PointsEventDispatcher = new PointsEventDispatcher();
	public var OnRemove: PointsEventDispatcher = new PointsEventDispatcher();

	private var apntPoints: Vector.<Point>;

//properties

	public function get Length ():uint
	{
		return apntPoints.length;
	}

//methods
	//constructor
	public function Points ()
	{
		apntPoints = new Vector.<Point>();
	}		

	//public methods

	public function append(APoint: Point): int
	{
		apntPoints.push(APoint);
		OnAdd.fireOnAdd();
		return apntPoints.length - 1;
	}

	public function get(AnIndex: int): Point
	{
		return apntPoints[AnIndex];
	}
	
	public function removeAll()
	{
		apntPoints.length = 0;
		OnRemove.fireOnRemove();
	}	

	public function removeAt(AnIndexFrom: int, ACount: uint = 1): void
	{
		apntPoints.splice(AnIndexFrom, ACount);
		OnRemove.fireOnRemove();		
	}
	
	public function shift(): Point	
	{
		return apntPoints.shift();
		OnRemove.fireOnRemove();
	}	
}
}
