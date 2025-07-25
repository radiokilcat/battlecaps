
# Спецификация стартового проекта “Капсы” (2D, Godot Engine)

## 1. Цель проекта

Создать минимально работающий прототип (MVP) цифровой настольной игры в фишки (капсы), с упрощённой физикой броска и базовой системой эффектов на сбиваемых фишках.

---

## 2. Требования к платформе

- **Движок:** Godot Engine 4.x  
- **Платформа:** ПК (Windows/macOS/Linux), поддержка мобильных желательна, но не обязательна для MVP  
- **Язык:** GDScript (основной), допускается C# при согласовании  
- **Архитектура:** Проект должен быть легко расширяемым для добавления новых эффектов, типов капсов, режимов игры  

---

## 3. Геймдизайн — краткое описание

- **Игроки:** Одиночный режим против NPC (другой игрок — опционально)  
- **Игровое поле:** 2D-вид сверху, стилизованное под стол/асфальт  
- **Объекты:** Капсы (фишки) — круги, разложенные башней (стеком) в центре поля; Бита — отдельная крупная фишка игрока для броска  
- **Механика броска:** Игрок выбирает угол и силу броска, нажимает кнопку "Бросить", бита анимируется по выбранной траектории  
- **Сбивание:** При попадании в капсы проверяется, какие фишки считаются сбитыми по заданному радиусу от точки удара  
- **Эффекты:** Некоторые капсы при сбитии активируют “эффект” — (например, дополнительный бросок)  
- **Победа:** Не реализуется в MVP, только базовая механика  

---

## 4. Минимальный набор игровых объектов

### 4.1. Капс (фишка)

- Спрайт (картинка, можно простой кружок с номером или иконкой)
- Координаты (позиция на поле)
- Флаг “есть ли эффект” (`has_effect: bool`)
- Тип эффекта (`effect_type: string/null`)
- Метод для анимации сбития и удаления

### 4.2. Бита

- Спрайт (отличается визуально)
- Метод броска (анимация по заданному вектору)
- Может быть одна на сцене

### 4.3. Игровое поле

- Фоновый спрайт (текстура “стол”/“асфальт”)
- Логика для вычисления координат капсов в башне
- Радиус сбития капсов (например, 48px от точки удара)

---

## 5. Интерфейс (UI)

- Кнопка “Бросить”
- Ползунок/кнопки выбора угла броска (0-360°)
- Ползунок/кнопки выбора силы броска (от минимума до максимума)
- Отображение количества бросков у игрока (индикатор)
- Всплывающее сообщение при активации эффекта (например: “Бонусный бросок!”)

---

## 6. Геймплейная логика

### 6.1. Старт игры

- На старте генерируется башня из капсов в центре поля (например, 9 капсов в 3 ряда)
- Случайно 1-2 капса получают спец-эффекты (например, “экстра бросок”)

### 6.2. Бросок

- Игрок задаёт угол и силу броска, жмёт кнопку “Бросить”
- Бита анимируется по дуге (Tween по X/Y или Linear Interpolation)
- В момент удара определяется точка соприкосновения

### 6.3. Проверка сбитых капсов

- Для каждой капсы: если её центр ближе к точке удара, чем радиус сбития — капса считается сбитой

### 6.4. Обработка эффектов

- Если сбита капса с эффектом — срабатывает соответствующее действие
    - Например: игрок получает дополнительный бросок

### 6.5. Удаление сбитых капсов

- Анимация “разлёта” (можно просто исчезновение или короткий твийн)
- Капса удаляется из сцены

---

## 7. Архитектура проекта (сцены Godot)
Main (Node2D)
|- UI (Control)
|- Button “Бросить”
|- AngleSlider (или кнопки +/–)
|- ForceSlider (или кнопки +/–)
|- Label для эффектов/сообщений
|- Field (Node2D)
|- Background (Sprite)
|- CapsContainer (Node2D)
|- Cap (Sprite) x N
|- Bita (Sprite)
|- FXLayer (Node2D)
|- Эффекты (анимированные объекты, вспышки)

---

## 8. Минимальные эффекты капсов (MVP)

- **extra_throw**: Игрок получает ещё один бросок (в этот же ход)
- **none**: Капса обычная, без эффекта

---

## 9. Минимальный набор ассетов

- 1 спрайт стола/асфальта (фон)
- 1 спрайт для обычной капсы
- 1 спрайт для капсы с эффектом (или наложить иконку)
- 1 спрайт для биты

(Можно использовать placeholders и простые кружки)

---

## 10. Ожидаемое поведение проекта

- Запуск — на экране появляется поле, башня из капсов и бита.
- Игрок задаёт угол и силу броска, нажимает “Бросить”.
- Бита анимируется к выбранной точке, определяется столкновение с капсами.
- Сбитые капсы исчезают, активируются эффекты, если они были.
- Игра не заканчивается, можно повторить бросок вручную для теста.

---

## 11. Расширяемость (для будущих итераций)

- Код и структура проекта должны позволять добавить новые эффекты, типы капсов, новые режимы игры и победные условия.
- Все параметры (радиус сбития, количество капсов, эффекты) выносятся в константы/настройки.

---

## 12. Прочее

- Проект должен быть собран в виде Godot-проекта с открытым кодом.
- Все исходные сцены и ассеты должны быть частью репозитория/архива.
- Скрипты — с базовой документацией (комментарии к ключевым методам).
- Названия файлов, папок и классов — на английском.

---

## 13. Минимальный успех для сдачи

- Реализована логика броска с выбором угла/силы.
- Капсы сбиваются и исчезают с поля.
- Срабатывает эффект “дополнительный бросок”.
- UI сообщает игроку о получении эффекта.
- Проект запускается и работает стабильно на ПК.



---

## 8. Минимальные эффекты капсов (MVP)

- **extra_throw**: Игрок получает ещё один бросок (в этот же ход)
- **none**: Капса обычная, без эффекта

---

## 9. Минимальный набор ассетов

- 1 спрайт стола/асфальта (фон)
- 1 спрайт для обычной капсы
- 1 спрайт для капсы с эффектом (или наложить иконку)
- 1 спрайт для биты

(Можно использовать placeholders и простые кружки)

---

## 10. Ожидаемое поведение проекта

- Запуск — на экране появляется поле, башня из капсов и бита.
- Игрок задаёт угол и силу броска, нажимает “Бросить”.
- Бита анимируется к выбранной точке, определяется столкновение с капсами.
- Сбитые капсы исчезают, активируются эффекты, если они были.
- Игра не заканчивается, можно повторить бросок вручную для теста.

---

## 11. Расширяемость (для будущих итераций)

- Код и структура проекта должны позволять добавить новые эффекты, типы капсов, новые режимы игры и победные условия.
- Все параметры (радиус сбития, количество капсов, эффекты) выносятся в константы/настройки.

---

## 12. Прочее

- Проект должен быть собран в виде Godot-проекта с открытым кодом.
- Все исходные сцены и ассеты должны быть частью репозитория/архива.
- Скрипты — с базовой документацией (комментарии к ключевым методам).
- Названия файлов, папок и классов — на английском.

---

## 13. Минимальный успех для сдачи

- Реализована логика броска с выбором угла/силы.
- Капсы сбиваются и исчезают с поля.
- Срабатывает эффект “дополнительный бросок”.
- UI сообщает игроку о получении эффекта.
- Проект запускается и работает стабильно на ПК.

