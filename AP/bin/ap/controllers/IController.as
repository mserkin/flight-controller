package ap.controllers {

public interface IController
{
	//methods
	function getControllerType(): int;

	function processDispatcherEvent(AType: int, AParamObj: Object = null): Boolean;	

	function run(): void;
}
}