;MINES - Игра "Сапёр" на ассемблере
include "LIB\PROC16.INC"
include "LIB\STRUCT.INC"
include "LIB\MACROS.ASM"

; --------------------------------------------------------------
;                        Кодстайл
; --------------------------------------------------------------
; Константы - UPPER_SNAKE_CASE
; Переменные, операнды в памяти - snake_case с префиксами по типу данных 
;   (например: str_text) - надо доработать
; Структуры - PascalCase
; Макросы - _snake_case (с подчеркиванием в начале)
; Соблюдать правильную вложенность для улучшения читаемости
; Минимизировать использование меток

include "CONFIG.ASM"
	
; --------------------------------------------------------------
;                        Точка входа программы
; --------------------------------------------------------------
org 100h		
start:
    ; Инициализация видеорежима 13h (320x200, 256 цветов)
    stdcall set_video_mod_to_13h
	
	stdcall fm_main_centralize_buttons
	stdcall fm_options_centralize_buttons
;	stdcall fm_custom_options_centralize_buttons
	
    ; Отрисовка главной формы
	stdcall draw_fm_main
	; Инициализация мыши
	stdcall init_mouse
	
    ; Основной цикл программы
	_repeat
		stdcall mouse_handle    ; Обработка событий мыши
		stdcall keyboard_handle ; Обработка клавиатуры
		_if [game_state] == GAME_PLAY
			stdcall update_timer, fm_main.pn_control.lb_timer
		_else
			stdcall get_start_time
		_end
	_until [game_state] == GAME_EXIT
	
    ; Восстановление исходного видеорежима
	stdcall restore_video_mod

    ; Завершение программы
    ret

; --------------------------------------------------------------
;                 Архитектура пользовательского интерфейса
; --------------------------------------------------------------
; Интерфейс построен на компонентной модели, где каждый визуальный элемент
; представлен соответствующей структурой данных и набором процедур:
;
; 1. Визуальные компоненты:
;    - Form - основная форма (окно)
;    - Panel - панель с возможностью вложенных элементов
;    - Label - текстовая метка
;    - Grid - сетка для игрового поля
;
; 2. Каждый компонент имеет параметры:
;    - Координаты (x, y)
;    - Размеры (width, height)
;    - Цвета (background, border)
;    - Специфичные свойства (текст для Label, размер ячеек для Grid)
;
; 3. Для компонентов реализованы методы:
;    - draw_* - отрисовка компонента
;    - resize_* - изменение размеров
;    - centralize_* - центрирование внутри родительского элемента

; --------------------------------------------------------------
;                  Процедуры управления видеорежимом
; --------------------------------------------------------------

; Переключение в видеорежим 13h и установка сегмента видеопамяти
proc set_video_mod_to_13h 
    ; Сохранение текущего режима и активной страницы
	mov ah, 0Fh
	int 10h
	
    mov [prev_mode], al
    mov [prev_page], bh
	
    ; Установка видеорежима 13h (320x200, 256 цветов)
	mov ax, 13h
	int 10h
	
    ; Установка активной страницы 0
	mov ah, 5
	mov al, 0
	int 10h
	
    ; Настройка ES на сегмент видеопамяти
	push 0A000h
	pop es
	
	ret
endp

; Восстановление исходного видеорежима
proc restore_video_mod
    ; Восстановление предыдущего видеорежима
    mov al, [prev_mode]
    mov ah, 0
    int 10h

    ; Восстановление активной страницы
    mov ah, 5
    mov al, [prev_page]
    int 10h
	ret
endp

; --------------------------------------------------------------
;                  Подключение модулей программы
; --------------------------------------------------------------

; Модуль обработки клавиатуры
include "INPUT\KEYBOARD.ASM"

; Модули работы с мышью
include "INPUT\MOUSE\LOGIC.ASM"  ; Логика обработки мыши
include "INPUT\MOUSE\DRAW.ASM"   ; Отрисовка курсора мыши

; Библиотеки визуальных компонентов (VCL - Visual Component Library)
include "LIB\VCL\DRAW.ASM"       ; Базовые функции отрисовки
include "LIB\VCL\METHODS.ASM"    ; Методы для работы с компонентами
include "LIB\VCL\AUTO.ASM"       ; Автоматическая обработка компонентов

; Вспомогательные функции
include "LIB\UTILS.ASM"

; Обработчики пользовательского интерфейса
include "UI\HANDLERS.ASM"        ; Обработчики событий
include "UI\DRAW.ASM"            ; Отрисовка интерфейса
include "UI\PREPCOMP.ASM"

; Определения структур компонентов
include "LIB\VCL\DEFSTRUC.ASM"

; Формы пользовательского интерфейса
include "UI\FORMS\MAINFORM.ASM"        ; Основная форма
include "UI\FORMS\OPTIONS.ASM"         ; Форма настроек
include "UI\FORMS\CUSTOM.ASM"
include "UI\FORMS\EXIT.ASM"            ; Форма выхода
include "UI\TIMER.ASM"

; Игровые данные
include "UI\DATA\CHARS.ASM"					
include "UI\DATA\STRINGS.ASM"
include "UI\DATA\CLKDATA.ASM"
include "UI\DATA\SCRDATA.ASM"
include "UI\DATA\TIMEDATA.ASM"
include "INPUT\MOUSE\DATA.ASM"   ; Данные мыши
include "GAME\DATA\STORAGE.ASM"  ; Структуры для хранения игровых данных