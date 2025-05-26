;MINES - Игра "Сапёр" на ассемблере
; --------------------------------------------------------------
;                        Кодстайл
; --------------------------------------------------------------
; Константы - UPPER_SNAKE_CASE
; Переменные, операнды в памяти - snake_case с префиксами по типу данных 
;   (например: str_text) - надо доработать
; Структуры - PascalCase
; Макросы - _snake_case (с подчеркиванием в начале)
; Соблюдать правильную вложенность для улучшения читаемости

;------------------------------------------------------------------------------
;                            ДЕРЕВО ПРОЕКТА
;------------------------------------------------------------------------------
; MINES/
; +-- CONFIG.ASM             - Константы
; +-- MAIN.ASM               - Главный файл программы 
; +-- MAIN.COM               
; ¦
; +-- GAME/                  - Игровая логика
; ¦   +-- DATA/
; ¦   ¦    L-- STORAGE.ASM      - Игровые данные
; ¦   +-- RANDOM.ASM   			- Генератор случайных чисел
; ¦   L-- LOGIC.ASM  			- Основная игровая логика
; ¦   
; +-- INPUT/                 - Обработка пользовательского ввода
; ¦   +-- KEYBOARD.ASM       - Обработка событий клавиатуры
; ¦   L-- MOUSE/
; ¦       +-- DATA.ASM       - Данные состояния мыши и курсора
; ¦       +-- DRAW.ASM       - Отрисовка курсора мыши
; ¦       L-- LOGIC.ASM      - Логика обработки событий мыши
; ¦
; +-- LIB/                   - Библиотеки
; ¦   +-- MYLIB/             - Пользовательские библиотеки
; ¦   ¦   +-- VCL/           - Библиотека визуальных компонентов
; ¦   ¦   ¦   +-- AUTO.ASM       - Обёртки для методов и процедур отрисовок
; ¦   ¦   ¦   +-- DEFSTRUC.ASM   - Определения структур UI компонентов
; ¦   ¦   ¦   +-- DRAW.ASM       - Базовые отрисовки
; ¦   ¦   ¦   L-- METHODS.ASM    - Методы работы с компонентами UI
; ¦   ¦   +-- MACROS.ASM     - Пользовательские макросы
; ¦   ¦   L-- UTILS.ASM      - Вспомогательные утилиты
; ¦   L-- STDLIB/            - Стандартные библиотеки FASM
; ¦       +-- PROC16.INC     
; ¦       L-- STRUCT.INC     
; ¦
; L-- UI/                    - Пользовательский интерфейс
;     +-- DATA/              - Данные интерфейса
;     ¦   +-- CHARS.ASM      - Символьные данные
;     ¦   +-- CLKDATA.ASM    - Данные обработки кликов мыши
;     ¦   +-- SCRDATA.ASM    - Данные экрана и видеорежима
;     ¦   +-- STRINGS.ASM    - Строковые константы интерфейса
;     ¦   L-- TIMEDATA.ASM   - Данные системы таймера
;     +-- FORMS/             - Формы интерфейса
;     ¦   +-- FORMCUST/      - Форма пользовательских настроек
;     ¦   ¦   +-- DRAWCUST.ASM   - Отрисовка
;     ¦   ¦   +-- HNDLCUST.ASM   - Обработчики событий 
;     ¦   ¦   L-- INITCUST.ASM   - Инициализация данных 
;     ¦   +-- FORMEXIT/      - Диалог подтверждения выхода
;     ¦   ¦   +-- DRAWEXIT.ASM   - Отрисовка 
;     ¦   ¦   +-- HNDLEXIT.ASM   - Обработчики событий 
;     ¦   ¦   L-- INITEXIT.ASM   - Инициализация данных 
;     ¦   +-- FORMMAIN/      - Главная игровая форма
;     ¦   ¦   +-- DRAWMAIN.ASM   - Отрисовка 
;     ¦   ¦   +-- HNDLMAIN.ASM   - Обработчики событий 
;     ¦   ¦   L-- INITMAIN.ASM   - Инициализация данных 
;     ¦   L-- FORMSETT/      - Форма выбора уровня сложности
;     ¦       +-- DRAWSETT.ASM   - Отрисовка 
;     ¦       +-- HNDLSETT.ASM   - Обработчики событий 
;     ¦       L-- INITSETT.ASM   - Инициализация данных 
;     +-- PREPCOMP.ASM       - Предварительная подготовка компонентов
;     L-- TIMER.ASM          - Система игрового таймера

include "LIB\STDLIB\PROC16.INC"
include "LIB\STDLIB\STRUCT.INC"
include "LIB\MYLIB\MACROS.ASM"

; --------------------------------------------------------------
;                        Кодстайл
; --------------------------------------------------------------
; Константы - UPPER_SNAKE_CASE
; Переменные, операнды в памяти - snake_case 
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
    stdcall set_video_mod_to_13h
	
	stdcall fm_main_centralize_buttons
	stdcall fm_options_centralize_buttons
	
    ; Отрисовка главной формы
	stdcall draw_fm_main
	; Инициализация мыши
	stdcall init_mouse
	stdcall init_random
	
    ; Основной цикл программы
	_repeat
		stdcall mouse_handle    ; Обработка событий мыши
		stdcall keyboard_handle ; Обработка клавиатуры
		_if [game_state] == GAME_PLAY
			_if [active_form_index] == ACTIVE_MAIN
				stdcall update_timer, fm_main.pn_control.lb_timer
				_if word[game_time] == MAX_TIME
					mov [game_state], GAME_LOSE
					stdcall change_br_reset_to_lose
					_mcall fm_main.pn_control.bt_reset:draw
					_mcall fm_main.pn_field.gr_field:fill_grid, <field_matrix>
				_end
			_end
		_end
	_until [game_state] == GAME_EXIT
	
    ; Восстановление исходного видеорежима
	stdcall restore_video_mod

    ; Завершение программы
    ret

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
	
    ; Установка видеорежима 13h 
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

include "GAME\LOGIC.ASM"
include "GAME\RANDOM.ASM"

include "INPUT\KEYBOARD.ASM"

include "INPUT\MOUSE\LOGIC.ASM"  
include "INPUT\MOUSE\DRAW.ASM"   


include "LIB\MYLIB\VCL\DRAW.ASM"       
include "LIB\MYLIB\VCL\METHODS.ASM"   
include "LIB\MYLIB\VCL\AUTO.ASM"      


include "LIB\MYLIB\UTILS.ASM"
 
include "LIB\MYLIB\VCL\DEFSTRUC.ASM"

include "UI\FORMS\FORMMAIN\DRAWMAIN.ASM"      
include "UI\FORMS\FORMMAIN\HNDLMAIN.ASM"   
    
include "UI\FORMS\FORMEXIT\DRAWEXIT.ASM"      
include "UI\FORMS\FORMEXIT\HNDLEXIT.ASM"  
    
include "UI\FORMS\FORMSETT\DRAWSETT.ASM"      
include "UI\FORMS\FORMSETT\HNDLSETT.ASM"  
  
include "UI\FORMS\FORMCUST\DRAWCUST.ASM"      
include "UI\FORMS\FORMCUST\HNDLCUST.ASM"     

include "UI\TIMER.ASM"
include "UI\PREPCOMP.ASM"

include "UI\FORMS\FORMMAIN\INITMAIN.ASM" 
include "UI\FORMS\FORMEXIT\INITEXIT.ASM"   
include "UI\FORMS\FORMSETT\INITSETT.ASM"  
include "UI\FORMS\FORMCUST\INITCUST.ASM"      
 
include "UI\DATA\CHARS.ASM"					
include "UI\DATA\STRINGS.ASM"
include "UI\DATA\CLKDATA.ASM"
include "UI\DATA\SCRDATA.ASM"
include "UI\DATA\TIMEDATA.ASM"
include "INPUT\MOUSE\DATA.ASM"   
include "GAME\DATA\STORAGE.ASM"  