# План миграции системы событий на EventManager (Observer Pattern)

## Цель
Перестроить систему управления событиями на основе паттерна Observer с использованием нового EventManager, реализующего методы `subscribe` и `notify`.

## Архитектура нового EventManager

### Базовый EventManager
```javascript
class EventManager {
    #listeners = new Map(); // Map<eventType, Set<callback>>
    
    subscribe(eventType, callback) {
        if (!this.#listeners.has(eventType)) {
            this.#listeners.set(eventType, new Set());
        }
        this.#listeners.get(eventType).add(callback);
        
        // Возвращаем функцию для отписки
        return () => this.unsubscribe(eventType, callback);
    }
    
    unsubscribe(eventType, callback) {
        if (this.#listeners.has(eventType)) {
            this.#listeners.get(eventType).delete(callback);
        }
    }
    
    notify(eventType, data = null) {
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
    
    clear(eventType = null) {
        if (eventType) {
            this.#listeners.delete(eventType);
        } else {
            this.#listeners.clear();
        }
    }
    
    hasListeners(eventType) {
        return this.#listeners.has(eventType) && 
               this.#listeners.get(eventType).size > 0;
    }
}
```

## Этапы миграции

### Этап 1: Создание базового EventManager
**Приоритет: ВЫСОКИЙ**

1. Создать класс `EventManager` после определения базовых классов (после строки ~1300)
2. Протестировать базовую функциональность
3. **Не трогать существующий код** - только добавить новый класс

**Файлы для изменения:**
- `script.js` - добавить класс EventManager

**Критерии готовности:**
- ✅ EventManager создан и протестирован
- ✅ Методы subscribe/notify работают корректно

---

### Этап 2: Миграция PointsEventDispatcher
**Приоритет: ВЫСОКИЙ**

**Текущее состояние:**
- `PointsEventDispatcher` extends `EventDispatcher` (строка 1306)
- Методы `fire_on_add()` и `fire_on_remove()` закомментированы
- Используется в `Points` классе (строки 1348-1349)
- Подписки в `Aircraft` (строки 2424-2425)

**План действий:**

1. **Заменить PointsEventDispatcher на EventManager:**
   ```javascript
   // Было:
   class PointsEventDispatcher extends EventDispatcher {
       static ON_ADD() {return "OnAdd";}
       static ON_REMOVE() {return "OnRemove";}
       fire_on_add() { /* закомментировано */ }
       fire_on_remove() { /* закомментировано */ }
   }
   
   // Станет:
   class PointsEventTypes {
       static ON_ADD = "Points.OnAdd";
       static ON_REMOVE = "Points.OnRemove";
   }
   ```

2. **Обновить Points класс:**
   ```javascript
   // Было:
   constructor() {
       this.on_add = new PointsEventDispatcher();
       this.on_remove = new PointsEventDispatcher();
   }
   
   // Станет:
   constructor() {
       this.eventManager = new EventManager();
   }
   
   append(point) {
       this.#points.push(point);
       this.eventManager.notify(PointsEventTypes.ON_ADD, { point, index: this.#points.length - 1 });
       return this.#points.length - 1;
   }
   ```

3. **Обновить Aircraft класс:**
   ```javascript
   // Было:
   this._path.on_add.add_event_listener(PointsEventDispatcher.ON_ADD, this.#points_on_add);
   this._path.on_remove.add_event_listener(PointsEventDispatcher.ON_REMOVE, this.#points_on_remove);
   
   // Станет:
   this._path.eventManager.subscribe(PointsEventTypes.ON_ADD, (data) => this.#points_on_add(data));
   this._path.eventManager.subscribe(PointsEventTypes.ON_REMOVE, (data) => this.#points_on_remove(data));
   ```

4. **Обновить обработчики в Aircraft:**
   ```javascript
   // Было:
   #points_on_add(event) {
       // event - старый формат
   }
   
   // Станет:
   #points_on_add(data) {
       // data = { point, index }
   }
   ```

**Файлы для изменения:**
- `script.js` строки 1306-1326 (PointsEventDispatcher)
- `script.js` строки 1333-1382 (Points)
- `script.js` строки 2424-2425, 3018, 3029 (Aircraft)

**Критерии готовности:**
- ✅ PointsEventDispatcher удален или помечен как deprecated
- ✅ Points использует EventManager
- ✅ Aircraft подписывается через subscribe
- ✅ События ON_ADD/ON_REMOVE работают
- ✅ Раскомментированы вызовы fire_on_add/fire_on_remove

---

### Этап 3: Миграция CustomDispatcher (Aircraft.on_landed)
**Приоритет: ВЫСОКИЙ**

**Текущее состояние:**
- `Aircraft.on_landed = new CustomDispatcher()` (строка 2441)
- `aircraft.on_landed.fire_on_landed(this)` (строка 3454) - активен
- `aircraft.on_landed.add_event_listener(CustomDispatcher.ON_LANDED, this.#aircraft_on_landed)` (строка 6800) - активен
- Много закомментированных использований

**План действий:**

1. **Создать типы событий:**
   ```javascript
   class AircraftEventTypes {
       static ON_LANDED = "Aircraft.OnLanded";
   }
   ```

2. **Обновить Aircraft класс:**
   ```javascript
   // Было:
   this.on_landed = new CustomDispatcher();
   
   // Станет:
   this.eventManager = new EventManager();
   ```

3. **Обновить вызов события:**
   ```javascript
   // Было:
   this.on_landed.fire_on_landed(this);
   
   // Станет:
   this.eventManager.notify(AircraftEventTypes.ON_LANDED, { aircraft: this });
   ```

4. **Обновить подписку в GameController:**
   ```javascript
   // Было:
   aircraft.on_landed.add_event_listener(CustomDispatcher.ON_LANDED, this.#aircraft_on_landed);
   
   // Станет:
   aircraft.eventManager.subscribe(AircraftEventTypes.ON_LANDED, (data) => 
       this.#aircraft_on_landed(data)
   );
   ```

5. **Обновить обработчик:**
   ```javascript
   // Было:
   #aircraft_on_landed(event) {
       let aircraft = event.SourceObject;
   }
   
   // Станет:
   #aircraft_on_landed(data) {
       let aircraft = data.aircraft;
   }
   ```

**Файлы для изменения:**
- `script.js` строка 2441 (Aircraft constructor)
- `script.js` строка 3454 (fire_on_landed)
- `script.js` строка 6800 (GameController подписка)
- `script.js` строка 7145 (GameController обработчик)

**Критерии готовности:**
- ✅ Aircraft.on_landed заменен на eventManager
- ✅ Событие ON_LANDED работает
- ✅ GameController корректно обрабатывает посадку

---

### Этап 4: Миграция CustomDispatcher (другие события)
**Приоритет: СРЕДНИЙ**

**События для миграции:**
- `Airport.on_level_loaded` (закомментировано, строка 4058)
- `Airport.on_gate_loaded` (закомментировано, строка 4057)
- `Airport.on_resized` (закомментировано, строка 4059)
- `FrameBuilder.before_rescale` (закомментировано, строка 8883)
- `HintPanelView.on_shown`, `on_hiding`, `on_hidden` (строки 5775-5777)
- `GameProgress.on_box_opened` (строка 4657)

**План действий:**

1. **Создать типы событий для каждого компонента:**
   ```javascript
   class AirportEventTypes {
       static ON_LEVEL_LOADED = "Airport.OnLevelLoaded";
       static ON_GATE_LOADED = "Airport.OnGateLoaded";
       static ON_RESIZED = "Airport.OnResized";
   }
   
   class FrameBuilderEventTypes {
       static BEFORE_RESCALE = "FrameBuilder.BeforeRescale";
   }
   
   class HintPanelEventTypes {
       static ON_SHOWN = "HintPanel.OnShown";
       static ON_HIDING = "HintPanel.OnHiding";
       static ON_HIDDEN = "HintPanel.OnHidden";
   }
   
   class GameProgressEventTypes {
       static ON_BOX_OPENED = "GameProgress.OnBoxOpened";
   }
   ```

2. **Для каждого компонента:**
   - Заменить `new CustomDispatcher()` на `new EventManager()`
   - Заменить `fire_*()` на `eventManager.notify()`
   - Заменить `add_event_listener()` на `eventManager.subscribe()`
   - Раскомментировать закомментированные строки

**Файлы для изменения:**
- `script.js` строки 4057-4059 (Airport)
- `script.js` строка 8883 (FrameBuilder)
- `script.js` строки 5775-5777 (HintPanelView)
- `script.js` строка 4657 (GameProgress)
- Все места использования этих событий

**Критерии готовности:**
- ✅ Все CustomDispatcher заменены на EventManager
- ✅ Все закомментированные события раскомментированы и работают
- ✅ Подписки обновлены на subscribe

---

### Этап 5: Миграция ToolBarEventDispatcher
**Приоритет: СРЕДНИЙ**

**Текущее состояние:**
- `ToolBarEventDispatcher` extends `EventDispatcher` (строка 6304)
- Все методы `fire_*()` закомментированы
- Используется в `ToolBarItem`, `ToolBarToggleButton`
- Подписки частично закомментированы

**План действий:**

1. **Создать типы событий:**
   ```javascript
   class ToolBarEventTypes {
       static ON_CLICK = "ToolBar.OnClick";
       static ON_PAINT = "ToolBar.OnPaint";
       static ON_PRESSED = "ToolBar.OnPressed";
       static ON_RELEASED = "ToolBar.OnReleased";
       static ON_TOGGLE = "ToolBar.OnToggle";
   }
   ```

2. **Обновить ToolBarItem:**
   ```javascript
   // Было:
   this.on_click = new ToolBarEventDispatcher();
   this.on_pressed = new ToolBarEventDispatcher();
   this.on_released = new ToolBarEventDispatcher();
   this.on_paint = new ToolBarEventDispatcher();
   
   // Станет:
   this.eventManager = new EventManager();
   ```

3. **Раскомментировать и обновить fire методы:**
   ```javascript
   // Было:
   fire_on_click(source) {
       //dispatchEvent(new ObjectEvent(ON_CLICK, source));
   }
   
   // Станет:
   fire_on_click(source) {
       this.eventManager.notify(ToolBarEventTypes.ON_CLICK, { source });
   }
   ```

4. **Обновить подписки:**
   ```javascript
   // Было:
   BannerView.#restart_item.on_click.add_event_listener(ToolBarEventDispatcher.ON_CLICK, ...);
   
   // Станет:
   BannerView.#restart_item.eventManager.subscribe(ToolBarEventTypes.ON_CLICK, ...);
   ```

**Файлы для изменения:**
- `script.js` строки 6304-6339 (ToolBarEventDispatcher)
- `script.js` строки 6043-6046 (ToolBarItem)
- `script.js` строки 6366 (ToolBarToggleButton)
- `script.js` строки 7875, 8046, 8248 (использования)

**Критерии готовности:**
- ✅ ToolBarEventDispatcher удален
- ✅ Все fire методы раскомментированы и работают
- ✅ Подписки обновлены
- ✅ Кнопки корректно генерируют события

---

### Этап 6: Интеграция с ControlDispatcher (опционально)
**Приоритет: НИЗКИЙ**

**Идея:** Можно использовать EventManager внутри ControlDispatcher для унификации, но это не обязательно, так как ControlDispatcher уже работает как центральный диспетчер.

**Вариант реализации:**
```javascript
class ControlDispatcher {
    static #eventManager = new EventManager();
    
    static dispatch_view_event(event_type, param_obj = null) {
        // Существующая логика маршрутизации
        // + опционально:
        this.#eventManager.notify(`ControlDispatcher.${event_type}`, param_obj);
    }
}
```

**Критерии готовности:**
- ✅ Если реализовано - ControlDispatcher использует EventManager для внутренних событий
- ✅ Обратная совместимость сохранена

---

## Стратегия миграции

### Принципы:
1. **Постепенность** - мигрировать по одному компоненту
2. **Обратная совместимость** - старый код должен работать параллельно на время миграции
3. **Тестирование** - после каждого этапа проверять работоспособность
4. **Раскомментирование** - закомментированные строки раскомментировать только после миграции

### Порядок выполнения:
1. ✅ Этап 1: Создать EventManager
2. ✅ Этап 2: PointsEventDispatcher (простой, изолированный)
3. ✅ Этап 3: Aircraft.on_landed (важный, активно используется)
4. ✅ Этап 4: Остальные CustomDispatcher (расширение)
5. ✅ Этап 5: ToolBarEventDispatcher (UI события)
6. ⚠️ Этап 6: Интеграция с ControlDispatcher (опционально)

### Чек-лист перед началом каждого этапа:
- [ ] Понять все места использования компонента
- [ ] Создать резервную копию или коммит
- [ ] Написать тестовый сценарий для проверки
- [ ] Выполнить миграцию
- [ ] Протестировать
- [ ] Удалить старый код (если все работает)

### Риски и митигация:

**Риск 1:** Поломка существующей функциональности
- **Митигация:** Мигрировать постепенно, тестировать после каждого шага

**Риск 2:** Потеря данных в событиях
- **Митигация:** Убедиться, что новый формат данных содержит всю необходимую информацию

**Риск 3:** Проблемы с контекстом (this)
- **Митигация:** Использовать стрелочные функции или bind при подписке

**Риск 4:** Утечки памяти (неотписанные слушатели)
- **Митигация:** EventManager может возвращать функцию unsubscribe, использовать при уничтожении объектов

---

## Примеры использования после миграции

### Подписка на событие:
```javascript
// Старый способ:
aircraft.on_landed.add_event_listener(CustomDispatcher.ON_LANDED, handler);

// Новый способ:
const unsubscribe = aircraft.eventManager.subscribe(
    AircraftEventTypes.ON_LANDED, 
    (data) => handler(data)
);

// При необходимости отписаться:
unsubscribe();
```

### Генерация события:
```javascript
// Старый способ:
this.on_landed.fire_on_landed(this);

// Новый способ:
this.eventManager.notify(AircraftEventTypes.ON_LANDED, { aircraft: this });
```

### Множественные подписки:
```javascript
// Можно подписаться на несколько событий:
aircraft.eventManager.subscribe(AircraftEventTypes.ON_LANDED, handler1);
aircraft.eventManager.subscribe(AircraftEventTypes.ON_CRASH, handler2);
```

---

## Дополнительные улучшения (по желанию)

1. **Типизация событий** - создать enum/константы для всех типов событий
2. **Логирование** - добавить опциональное логирование событий для отладки
3. **Приоритеты** - добавить систему приоритетов для обработчиков
4. **Одноразовые подписки** - `subscribeOnce(eventType, callback)`
5. **Глобальный EventManager** - для глобальных событий приложения

---

## Заключение

Миграция должна быть постепенной и безопасной. Начать с простых изолированных компонентов (PointsEventDispatcher), затем перейти к более сложным (CustomDispatcher), и в конце - к UI событиям (ToolBarEventDispatcher).

После каждого этапа необходимо тестировать функциональность и убедиться, что ничего не сломалось.

