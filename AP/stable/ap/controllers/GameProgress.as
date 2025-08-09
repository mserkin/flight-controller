package ap.controllers {

///////////////////////////////////////////////////////////
//  GameProgress.as
///////////////////////////////////////////////////////////

import ap.instrumental.CustomDispatcher;

public class GameProgress //static
{
//public fields & consts		

	//public consts
	static public const IS_BOSS_MODE_ON: Boolean = false;
	static public const N_BOX_PASS_REQ = 0.75; //0.75
	static public const N_BOX_FULL_COMPL_REQ = 0.99; //0.99
	static public const N_BOX_COUNT: int = 3;
	static public const N_LEVEL_COUNT: int = 27;
	
	//public fields
	static public var OnBoxOpened: CustomDispatcher = new CustomDispatcher();
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
	static private const N_BOX0_FIRST_LEVEL: int = 1;
	static private const N_BOX0_LAST_LEVEL: int = 9;
	static private const N_BOX1_FIRST_LEVEL: int = 10;
	static private const N_BOX1_LAST_LEVEL: int = 18;
	static private const N_BOX2_FIRST_LEVEL: int = 19;
	static private const N_BOX2_LAST_LEVEL: int = 27;

	//property fields
	static private var FLevel: int = 1;
	static private var FLevelCompletion: Vector.<int> = new Vector.<int>(N_LEVEL_COUNT, true);
	static private var FPoints: int = 0;
	static private var FNewlyOpenedBox: int = -1;

	//other fields
	static private var anBoxFirstLevels: Vector.<int> = null; 
	static private var anBoxLastLevels: Vector.<int> = null;
//properties

	static public function get Box()
	{
		return getBoxForLevel(FLevel);
	}
	
	static public function get BoxFirstLevel()
    {
		return anBoxFirstLevels[Box];
    }
	
	static public function get BoxLastLevel()
    {
		return anBoxLastLevels[Box];
    }
	
	static public function get BoxPassed()
	{
		return getBoxProgress(Box) >= 1;
	}

	static public function get IsLastBox()
	{
		return getBoxForLevel(FLevel) == N_BOX_COUNT - 1;
	}
	
	static public function get Level(): int
    {
    	return FLevel;
    }

	static public function get LevelCompletion(): Vector.<int>
	{
		return FLevelCompletion;
	}	
	
	static public function get NewlyOpenedBox(): int
	{
		return FNewlyOpenedBox;
	}	
	
	static public function get Points(): int
    {
    	return FPoints;
    }	
	
//methods
	//constructor
	/*public function <#DelphiStyle#> (<#ADelphiStyle#>: <#Type#>)
	{
		var <#prefix_underscore_style#>: <#Type#>;
	}*/		

	//public methods
	static public function acceptLevelResult(AResult: int)
	{
		var n_box: int = Box;
		if (FNewlyOpenedBox == n_box)
		{
			FNewlyOpenedBox = -1;
		}
		var dbl_progress_before: Number = getBoxProgress(n_box);
		FLevelCompletion[FLevel - 1] = Math.max(AResult, FLevelCompletion[FLevel - 1]); 
		var dbl_progress_after: Number = getBoxProgress(n_box);
		if (n_box + 1 < N_BOX_COUNT && dbl_progress_before < 1 && dbl_progress_after >= 1) {
			FNewlyOpenedBox = n_box + 1;
			OnBoxOpened.fireOnBoxOpened(n_box + 1);
		}
	}
	
	static public function addPoints(APointQty: int)
	{
		FPoints += APointQty;
	}
	
	static public function getBoxForLevel(ALevelNumber: int): int
	{
		if (!anBoxFirstLevels || !anBoxLastLevels) initBoxInfo();
	
		for(var n_box = 0; n_box < N_BOX_COUNT; n_box++)
			if (ALevelNumber >= anBoxFirstLevels[n_box] && ALevelNumber <= anBoxLastLevels[n_box])
				return n_box;
		return -1;
	}
	
	
	//result >= 1  - box passed
	static public function getBoxProgress(ABoxNumber: int): Number
	{
		if (ABoxNumber < 0 || ABoxNumber >= N_BOX_COUNT) return 0;
		if (!anBoxFirstLevels || !anBoxLastLevels) initBoxInfo();
		
		var n_first_level_number: int = anBoxFirstLevels[ABoxNumber];
		var n_last_level_number =  anBoxLastLevels[ABoxNumber];
		var n_target_sum: int = (n_last_level_number - n_first_level_number + 1) * 100 
			* ((ABoxNumber < N_LEVEL_COUNT - 1) ? N_BOX_PASS_REQ : N_BOX_FULL_COMPL_REQ);
		var n_progress_sum: int = 0;
		for (var i = n_first_level_number; i <= n_last_level_number; i++)
		{
			if (i > N_LEVEL_COUNT) break;
			
			n_progress_sum += GameProgress.LevelCompletion[i - 1];
		}	
		return n_progress_sum / n_target_sum;
	}			
	
	static public function getFirstLevelForBox(ABoxNumber: int): int
	{
		if (!anBoxFirstLevels || !anBoxLastLevels) initBoxInfo();
		return anBoxFirstLevels[ABoxNumber];
	}
	
	static public function nextLevel()
	{
		FLevel++;
	}

	static public function reset(): void
	{
		FLevel = 1;
	}

	static public function selectSpecifiedLevel (ALevelNumber: int)
	{
		FLevel = ALevelNumber;
	}	
	
	
	//protected methods

	/* protected function <#camelStyle#>(<#ADelphiStyle#>: <#Type#>)
	{
	}*/

	//private methods

	static private function initBoxInfo()
	{
		anBoxFirstLevels = new Vector.<int>(N_BOX_COUNT);
		anBoxLastLevels = new Vector.<int>(N_BOX_COUNT);
		anBoxFirstLevels[0] = N_BOX0_FIRST_LEVEL;
		anBoxLastLevels[0] = N_BOX0_LAST_LEVEL;
		anBoxFirstLevels[1] = N_BOX1_FIRST_LEVEL;
		anBoxLastLevels[1] = N_BOX1_LAST_LEVEL;
		anBoxFirstLevels[2] = N_BOX2_FIRST_LEVEL;
		anBoxLastLevels[2] = N_BOX2_LAST_LEVEL;
	}

	//event handlers

	/* private function <#object_OnDelphiStyle#>(<#AnDelphiStyle#>: Event): void
	{
	}*/
}
}
