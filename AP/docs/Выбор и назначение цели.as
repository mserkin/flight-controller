Plane
	Select
		Клик по самолету - Game.selectPlane <- Game.select <- airport:1.stage_OnClick
	Deselect
		Клик в пустоту - Game.deselect <- Game.select
		Клик по самолету - Game.deselect <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
		После взлета - Plane.takeoff
Waypoint
	Select
		Клик по маршрутной точке - Game.selectWaypoint <- Game.select <- airport:1.stage_OnClick		
		Выбор самолета - Game.selectWaypoint <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
		При пролете текущей маршрутной точки (выбор следующей) - Plane.flyDirected <- Plane.calcAcceleration		
	Deselect
		Клик - Game.deselect <- Game.select
		При пролете текущей маршрутной точки - Plane.flyDirected <- Plane.calcAcceleration
	Set
		Клик по самолету - selectWaypoint <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
		Клик по маршрутной точке - selectWaypoint <- Game.select <- airport:1.stage_OnClick
		При пролете текущей маршрутной точки - Plane.flyDirected <- Plane.calcAcceleration
	Unset
		Клик по самолету - Plane.TargetRunway <- selectRunway <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
		Клик по ВВП - Plane.TargetRunway <- selectRunway <- Game.select <- airport:1.stage_OnClick
Runway
	Select
		Клик по ВВП - Game.selectRunway <- Game.select <- airport:1.stage_OnClick	
		Выбор самолета - Game.selectRunway <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
	Deselect
		Клик - Game.deselect <- Game.select
		При переходе на руление на гейт - Plane.brake <- Plane.calcAcceleration
		При уходн на круг - goAround <- Plane.calcAcceleration
		После взлета - Plane.takeoff
	Set
		Клик по самолету - selectRunway <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
		Клик по ВВП - selectRunway <- Game.select <- airport:1.stage_OnClick
	Unset		
		Клик по самолету - freeRunway <- Plane.TargetWaypoint <- selectWaypoint <- Game.selectPlane <- Game.select <- airport:1.stage_OnClick
		Клик по маршрутной точке - freeRunway <- Plane.TargetWaypoint <- selectWaypoint <- Game.select <- airport:1.stage_OnClick
		Клик по ВВП - freeRunway <- Plane.TargetRunway <- selectRunway <- Game.select <- airport:1.stage_OnClick
		При уходн на круг - freeRunway <- goAround <- Plane.calcAcceleration		
		Мнимое событие = При пролете текущей маршрутной точки - Plane.TargetWaypoint <- Plane.flyDirected <- Plane.calcAcceleration