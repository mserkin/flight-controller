package ap.model {

import ap.basic.Angle;
import ap.input.Core;

public class Wind
{
//public fields & consts		

	//public consts
	public const DBL_MAX_WIND_SPEED = 70;

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
	private const DBL_ACC: Number = 1; //m/s/s
	private const DBL_TURN_RATE: Number = Math.PI / 360; //deg/sec

	//property fields
	private var FDirection: Angle = new Angle(); //Куда дует ветер, не откуда!
	private var	FMaximalSpeed: Number;
	private var	FMinimalSpeed: Number;	
	private var FSpeed: Number = 0;

	//other fields
	private var	angTargetDirection: Angle = new Angle;
	private var	dblTargetSpeed: Number;
	private var	dblVariability: Number; 
	private var	dtTimeout: Date = new Date(0);
	
//properties
	//Направление в котором дует ветер. Не откуда он дует!
	public function get Direction(): Angle
	{
		return FDirection;
	}

	public function get HorizontalSpeed(): Number
	{
		return FSpeed * FDirection.sin();
	}

	public function get MaximalSpeed(): Number
	{
		return FMaximalSpeed;
	}
	
	public function get MinimalSpeed(): Number
	{
		return FMinimalSpeed;
	}

	public function get Speed(): Number
	{
		return FSpeed;
	}
	
	public function get VerticalSpeed(): Number
	{
		return -FSpeed * FDirection.cos();	
	}

//methods
	//constructor

	public function Wind (AMinSpeed: Number, AMaxSpeed: Number, AVariability: Number)
	{
		FMaximalSpeed = Math.min(AMaxSpeed, DBL_MAX_WIND_SPEED);
		FMinimalSpeed = AMinSpeed;
		dblVariability = AVariability;
		update();
		FDirection.Radian = angTargetDirection.Radian;
		FSpeed = dblTargetSpeed;
	}		

	//public methods

	public function update()
	{
		var dt_now: Date = new Date();
		if (dt_now.time > dtTimeout.time)
		{
			dtTimeout.setTime((dblVariability > 0) ? dt_now.time + 1000/dblVariability : int.MAX_VALUE);
				
			angTargetDirection.Radian = Math.random() * Math.PI * 2;
			dblTargetSpeed = Math.random() * (FMaximalSpeed - FMinimalSpeed) + FMinimalSpeed;
		}
		FDirection.Radian += FDirection.getRotation(angTargetDirection) * DBL_TURN_RATE / Core.N_FRAME_RATE;
		FSpeed += DBL_ACC / Core.N_FRAME_RATE * ((FSpeed < dblTargetSpeed) ? +1 : -1)
		if (FSpeed < 0) FSpeed = 0;
	}

	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	/* private function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
