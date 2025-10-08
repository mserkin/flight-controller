package ap.views {

///////////////////////////////////////////////////////////
//  StarView.as
///////////////////////////////////////////////////////////

import flash.display.Sprite;
import flash.media.SoundTransform;
import flash.media.SoundChannel;
import flash.events.Event;
import ap.basic.Point;
import ap.basic.Rect;
import ap.basic.Size;
import ap.input.Core;
import ap.instrumental.ScreenManager;

public class StarView //static
{
//public fields & consts

	//public consts
	/*public const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//public fields
	/*public var <#DelphiStyle#>: <#Type#>;*/

	//events
//protected fields & consts

	//protected consts
	/*protected const <#PREFIX_UPPER_CASE_STYLE#>: <#Type#>;*/

	//protected fields
	/*protected var <#prefixCamelStyle#>: <#Type#>;*/

//private fields & consts

	//private consts
	static private var STAR_SIZE: Number = 24;

	//property fields
	
	//other fields
	static private var asStars: Vector.<Star>;
//properties


//methods
	//constructor - static
	
	//public methods

	public static function addStar(ALocation: Point)
	{
		asStars.push(new Star(ALocation));
		var transform: SoundTransform = new SoundTransform(1, 0);
		var zvon: Zvon = new Zvon();
		var ch: SoundChannel = zvon.play();
		ch.soundTransform = transform;
	}	
	
	public static function clear()
	{
		asStars = new Vector.<Star>(0, false);
	}	
	
	public static function display()
	{
		for (var i: int = asStars.length - 1; i >= 0; i--)
		{
			var star: Star = asStars[i];
			displayStar(star);		
			star.move();
			//delete if flown away
			if (star.IsFlownAway) {
				asStars.splice(i, 1);
			}			
		}
	}

	//protected methods
	
	//private methods

	private static function displayStar(star: Star)
	{
		ScreenManager.displayImage(new StarImage(), new Rect(star.Location, new Size(STAR_SIZE*star.RotationPhase, STAR_SIZE)));		
	}
		
	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}

internal class Star
{
	private const N_MOVE_STEPS: int = 16;
	private const N_ROTATION_STEPS: int = 16;
	private const DBL_ROTATION_MIN: Number = 0.2;
	private var FLocation: ap.basic.Point;
	private var FRotationPhase: Number = DBL_ROTATION_MIN;
	private var dblMoveStep: Number;
	private var dblRotationStep: Number = 1/N_ROTATION_STEPS*2;

	public function get Location(): ap.basic.Point 
	{
		return FLocation;
	}

	public function get RotationPhase(): Number
	{
		return FRotationPhase;
	}
	
	public function get IsFlownAway(): Boolean
	{
		return (FLocation.Y < 0);
	}
	
	public function Star(ALocation: ap.basic.Point) {
		FLocation = ALocation;
		dblMoveStep = ALocation.Y / N_MOVE_STEPS;
	}
	
	public function move(): void 
	{
		FLocation.Y -= dblMoveStep;
		var dbl_rot = FRotationPhase + dblRotationStep;
		if (dbl_rot < DBL_ROTATION_MIN || dbl_rot > 1) {
			dblRotationStep = -dblRotationStep;
			dbl_rot = FRotationPhase + dblRotationStep;
		}
		else {
			FRotationPhase = dbl_rot;
		}
	}
}