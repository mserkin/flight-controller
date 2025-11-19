# Реализация EventManager и примеры миграции

## 1. Базовый EventManager (Этап 1)

### Размещение в коде
Добавить **перед** строкой 1303 (перед `PointsEventDispatcher`):

```javascript
///////////////////////////////////////////////////////////
//  EventManager.js - Observer Pattern Implementation
///////////////////////////////////////////////////////////

class EventManager 
{
	#listeners = new Map(); // Map<eventType, Set<callback>>

	/**
	 * Подписывается на событие
	 * @param {string} eventType - Тип события
	 * @param {Function} callback - Функция-обработчик
	 * @returns {Function} - Функция для отписки
	 */
	subscribe(eventType, callback) 
	{
		if (!this.#listeners.has(eventType)) {
			this.#listeners.set(eventType, new Set());
		}
		this.#listeners.get(eventType).add(callback);
		
		// Возвращаем функцию для отписки
		return () => this.unsubscribe(eventType, callback);
	}

	/**
	 * Отписывается от события
	 * @param {string} eventType - Тип события
	 * @param {Function} callback - Функция-обработчик
	 */
	unsubscribe(eventType, callback) 
	{
		if (this.#listeners.has(eventType)) {
			this.#listeners.get(eventType).delete(callback);
		}
	}

	/**
	 * Уведомляет всех подписчиков о событии
	 * @param {string} eventType - Тип события
	 * @param {*} data - Данные события (любой тип)
	 */
	notify(eventType, data = null) 
	{
		if (this.#listeners.has(eventType)) {
			this.#listeners.get(eventType).forEach(callback => {
				try {
					callback(data);
				} catch (error) {
					console.error(`Error in event handler for ${eventType}:`, error);
				}
			});
		}
	}

	/**
	 * Очищает подписки
	 * @param {string|null} eventType - Тип события (null = все события)
	 */
	clear(eventType = null) 
	{
		if (eventType) {
			this.#listeners.delete(eventType);
		} else {
			this.#listeners.clear();
		}
	}

	/**
	 * Проверяет наличие подписчиков
	 * @param {string} eventType - Тип события
	 * @returns {boolean}
	 */
	hasListeners(eventType) 
	{
		return this.#listeners.has(eventType) && 
			   this.#listeners.get(eventType).size > 0;
	}

	/**
	 * Возвращает количество подписчиков
	 * @param {string} eventType - Тип события
	 * @returns {number}
	 */
	getListenerCount(eventType) 
	{
		return this.#listeners.has(eventType) ? 
			   this.#listeners.get(eventType).size : 0;
	}
}
```

---

## 2. Типы событий (Этап 2 - PointsEventDispatcher)

### Создать после EventManager:

```javascript
///////////////////////////////////////////////////////////
//  EventTypes.js - Константы типов событий
///////////////////////////////////////////////////////////

class PointsEventTypes 
{
	static ON_ADD = "Points.OnAdd";
	static ON_REMOVE = "Points.OnRemove";
}
```

### Обновить класс Points:

**Было (строки 1333-1382):**
```javascript
class Points
{
	#points = [];

	constructor()
	{
		this.#points = [];
		this.on_add  = new PointsEventDispatcher();
		this.on_remove = new PointsEventDispatcher();
	}

	append(point)
	{
		this.#points.push(point);
		this.on_add.fire_on_add();  // ЗАКОММЕНТИРОВАНО
		return this.#points.length - 1;
	}

	removeAll()
	{
		this.#points.length = 0;
		this.on_remove.fire_on_remove();  // ЗАКОММЕНТИРОВАНО
	}

	removeAt(index_from, count=1) 
	{
		this.#points.splice(index_from, count);
		on_remove.fire_on_remove();  // ЗАКОММЕНТИРОВАНО
	}

	shift()
	{
		return this.#points.shift();
		on_remove.fire_on_remove();  // ЗАКОММЕНТИРОВАНО
	}
}
```

**Станет:**
```javascript
class Points
{
	#points = [];
	eventManager = null; // EventManager

	constructor()
	{
		this.#points = [];
		this.eventManager = new EventManager();
	}

	append(point)
	{
		this.#points.push(point);
		const index = this.#points.length - 1;
		this.eventManager.notify(PointsEventTypes.ON_ADD, { 
			point: point, 
			index: index 
		});
		return index;
	}

	removeAll()
	{
		this.#points.length = 0;
		this.eventManager.notify(PointsEventTypes.ON_REMOVE, { 
			removedCount: 0, // все удалены
			remainingCount: 0
		});
	}

	removeAt(index_from, count=1) 
	{
		const removed = this.#points.splice(index_from, count);
		this.eventManager.notify(PointsEventTypes.ON_REMOVE, { 
			removed: removed,
			removedCount: removed.length,
			index: index_from,
			remainingCount: this.#points.length
		});
	}

	shift()
	{
		const point = this.#points.shift();
		if (point) {
			this.eventManager.notify(PointsEventTypes.ON_REMOVE, { 
				removed: [point],
				removedCount: 1,
				index: 0,
				remainingCount: this.#points.length
			});
		}
		return point;
	}
}
```

### Обновить Aircraft класс:

**Было (строки 2424-2425):**
```javascript
constructor(aircraft_type, location, course, airport_rect, state, fuel_residue, gate=null)
{
	this._type = aircraft_type;
	this._path = new Points();
	this._path.on_add.add_event_listener(PointsEventDispatcher.ON_ADD, this.#points_on_add);
	this._path.on_remove.add_event_listener(PointsEventDispatcher.ON_REMOVE, this.#points_on_remove);
	// ...
}
```

**Станет:**
```javascript
constructor(aircraft_type, location, course, airport_rect, state, fuel_residue, gate=null)
{
	this._type = aircraft_type;
	this._path = new Points();
	
	// Подписка на события через новый EventManager
	this._path.eventManager.subscribe(
		PointsEventTypes.ON_ADD, 
		(data) => this.#points_on_add(data)
	);
	this._path.eventManager.subscribe(
		PointsEventTypes.ON_REMOVE, 
		(data) => this.#points_on_remove(data)
	);
	// ...
}
```

### Обновить обработчики в Aircraft:

**Было (строки 3018, 3029):**
```javascript
#points_on_add(event)
{
	// event - старый формат Flash Event
}

#points_on_remove(event)
{
	// event - старый формат Flash Event
}
```

**Станет:**
```javascript
#points_on_add(data)
{
	// data = { point, index }
	// Можно использовать data.point и data.index
}

#points_on_remove(data)
{
	// data = { removed, removedCount, index, remainingCount }
	// Можно использовать data.removed, data.removedCount и т.д.
}
```

---

## 3. Миграция Aircraft.on_landed (Этап 3)

### Создать типы событий:

```javascript
class AircraftEventTypes 
{
	static ON_LANDED = "Aircraft.OnLanded";
}
```

### Обновить Aircraft класс:

**Было (строка 2441):**
```javascript
this.on_landed = new CustomDispatcher();
```

**Станет:**
```javascript
// В конструкторе Aircraft, если eventManager еще не создан:
if (!this.eventManager) {
	this.eventManager = new EventManager();
}
// Или использовать существующий, если он уже есть для других событий
```

**Было (строка 3454):**
```javascript
this.on_landed.fire_on_landed(this);
```

**Станет:**
```javascript
this.eventManager.notify(AircraftEventTypes.ON_LANDED, { 
	aircraft: this 
});
```

### Обновить GameController:

**Было (строка 6800):**
```javascript
aircraft.on_landed.add_event_listener(CustomDispatcher.ON_LANDED, this.#aircraft_on_landed);
```

**Станет:**
```javascript
aircraft.eventManager.subscribe(
	AircraftEventTypes.ON_LANDED, 
	(data) => this.#aircraft_on_landed(data)
);
```

**Было (строка 7145):**
```javascript
#aircraft_on_landed(event)
{
	this.#landings_done += 1;
	let aircraft = event.SourceObject; 
	GameProgress.add_points(int(aircraft.fuel*GameController.#FULL_TANK_POINTS));
	StarView.StarView.add_star(FrameBuilder.convert_to_screen_point(aircraft.location));
}
```

**Станет:**
```javascript
#aircraft_on_landed(data)
{
	this.#landings_done += 1;
	let aircraft = data.aircraft; 
	GameProgress.add_points(int(aircraft.fuel*GameController.#FULL_TANK_POINTS));
	StarView.StarView.add_star(FrameBuilder.convert_to_screen_point(aircraft.location));
}
```

---

## 4. Миграция ToolBarEventDispatcher (Этап 5)

### Создать типы событий:

```javascript
class ToolBarEventTypes 
{
	static ON_CLICK = "ToolBar.OnClick";
	static ON_PAINT = "ToolBar.OnPaint";
	static ON_PRESSED = "ToolBar.OnPressed";
	static ON_RELEASED = "ToolBar.OnReleased";
	static ON_TOGGLE = "ToolBar.OnToggle";
}
```

### Обновить ToolBarItem:

**Было (строки 6043-6046):**
```javascript
this.on_click = new ToolBarEventDispatcher();
this.on_pressed = new ToolBarEventDispatcher();
this.on_released = new ToolBarEventDispatcher();
this.on_paint = new ToolBarEventDispatcher();
```

**Станет:**
```javascript
this.eventManager = new EventManager();
```

### Раскомментировать и обновить fire методы:

**Было (строки 6315-6338):**
```javascript
fire_on_click(source) {
	//TODO: Event
	//dispatchEvent(new ObjectEvent(ON_CLICK, source));
}

fire_on_paint(source) {
	//TODO: Event
	//dispatchEvent(new ObjectEvent(ON_PAINT, source));
}
```

**Станет:**
```javascript
fire_on_click(source) {
	this.eventManager.notify(ToolBarEventTypes.ON_CLICK, { source });
}

fire_on_paint(source) {
	this.eventManager.notify(ToolBarEventTypes.ON_PAINT, { source });
}

fire_on_pressed(source) {
	this.eventManager.notify(ToolBarEventTypes.ON_PRESSED, { source });
}

fire_on_released(source) {
	this.eventManager.notify(ToolBarEventTypes.ON_RELEASED, { source });
}

fire_on_toggle(source) {
	this.eventManager.notify(ToolBarEventTypes.ON_TOGGLE, { source });
}
```

### Обновить подписки:

**Было (строка 8046):**
```javascript
BannerView.#restart_item.on_click.add_event_listener(ToolBarEventDispatcher.ON_CLICK, BannerView.#tool_bar_item_on_click);
```

**Станет:**
```javascript
BannerView.#restart_item.eventManager.subscribe(
	ToolBarEventTypes.ON_CLICK, 
	(data) => BannerView.#tool_bar_item_on_click(data)
);
```

**Обновить обработчик (строка 8248):**
```javascript
// Было:
static #tool_bar_item_on_click(event) {
	switch(event.SourceObject) {
		// ...
	}
}

// Станет:
static #tool_bar_item_on_click(data) {
	switch(data.source) {
		// ...
	}
}
```

---

## 5. Дополнительные типы событий (Этап 4)

```javascript
class AirportEventTypes 
{
	static ON_LEVEL_LOADED = "Airport.OnLevelLoaded";
	static ON_GATE_LOADED = "Airport.OnGateLoaded";
	static ON_RESIZED = "Airport.OnResized";
}

class FrameBuilderEventTypes 
{
	static BEFORE_RESCALE = "FrameBuilder.BeforeRescale";
}

class HintPanelEventTypes 
{
	static ON_SHOWN = "HintPanel.OnShown";
	static ON_HIDING = "HintPanel.OnHiding";
	static ON_HIDDEN = "HintPanel.OnHidden";
}

class GameProgressEventTypes 
{
	static ON_BOX_OPENED = "GameProgress.OnBoxOpened";
}
```

---

## 6. Примеры использования

### Простая подписка:
```javascript
const unsubscribe = object.eventManager.subscribe(
	EventType.SOME_EVENT,
	(data) => {
		console.log("Event received:", data);
	}
);

// Позже можно отписаться:
unsubscribe();
```

### Подписка с сохранением контекста:
```javascript
// Для методов класса:
this.unsubscribePath = this._path.eventManager.subscribe(
	PointsEventTypes.ON_ADD,
	(data) => this.#points_on_add(data)
);

// При уничтожении объекта:
if (this.unsubscribePath) {
	this.unsubscribePath();
}
```

### Множественные подписки:
```javascript
// Подписаться на несколько событий одного объекта:
aircraft.eventManager.subscribe(AircraftEventTypes.ON_LANDED, handler1);
aircraft.eventManager.subscribe(AircraftEventTypes.ON_CRASH, handler2);
```

### Генерация события с данными:
```javascript
// Простое событие:
this.eventManager.notify(EventType.SOME_EVENT);

// С данными:
this.eventManager.notify(EventType.SOME_EVENT, {
	value: 42,
	message: "Hello"
});

// С объектом:
this.eventManager.notify(AircraftEventTypes.ON_LANDED, {
	aircraft: this,
	timestamp: Date.now()
});
```

---

## 7. Отладка

### Добавить логирование в EventManager (опционально):

```javascript
notify(eventType, data = null) 
{
	if (this.#listeners.has(eventType)) {
		console.log(`[EventManager] Notifying ${eventType} to ${this.#listeners.get(eventType).size} listeners`);
		this.#listeners.get(eventType).forEach(callback => {
			try {
				callback(data);
			} catch (error) {
				console.error(`Error in event handler for ${eventType}:`, error);
			}
		});
	} else {
		console.warn(`[EventManager] No listeners for ${eventType}`);
	}
}
```

---

## 8. Чек-лист миграции

Для каждого компонента:

- [ ] Создать типы событий (EventTypes класс)
- [ ] Заменить `new CustomDispatcher()` / `new PointsEventDispatcher()` на `new EventManager()`
- [ ] Заменить `fire_*()` на `eventManager.notify()`
- [ ] Заменить `add_event_listener()` на `eventManager.subscribe()`
- [ ] Обновить обработчики для работы с новым форматом данных
- [ ] Раскомментировать закомментированные строки
- [ ] Протестировать функциональность
- [ ] Удалить старый код (если все работает)

