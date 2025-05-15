include "LIB\PROC16.INC"
include "LIB\STRUCT.INC"
include "LIB\MACROS.ASM"

; --------------------------------------------------------------
;                        Кодстайл
; --------------------------------------------------------------
; Константы - UPPER_SNACE_CASE
; Переменные, операнды в памяти - snake_case 
; ^(обязательно использовать префиксы - str_name)^ <- (надо доработать)
; Структуры - PascalCase
; Макросы - _snake_case (в начале обязательно _ )
; Отображать вложеность
; Метки избегать (зачем я макросы делал???)

include "CONFIG.ASM"
	
; --------------------------------------------------------------
;                        Точка входа программы
; --------------------------------------------------------------
org 100h
start:
    ; BIOS: установка видеорежима 13h и сегмента видеопамяти ES = A000h
    stdcall set_video_mod_to_13h
	
	stdcall mouse_handle

    ; Отрисовка главной формы и панелей управления
    _mcall fm_main:draw                            ; отрисовка формы
    _mcall fm_main.pn_control:draw           ; отрисовка верхней панели
    _mcall fm_main.pn_control.lb_mines:draw  ; счётчик мин
    _mcall fm_main.pn_control.lb_timer:draw  ; таймер
	_mcall fm_main.pn_control.bt_exit:draw

    ; Настройка размеров и позиционирование игрового поля (сетка)
    _mcall fm_main.pn_field.gr_field:resize_cell   ; подстройка размера ячейки
    _mcall fm_main.pn_field:centralize_grid        ; выравнивание поля внутри панели
    ; Отрисовка панели поля и самой сетки
    _mcall fm_main.pn_field:draw
    _mcall fm_main.pn_field.gr_field:draw
	_mcall fm_main.pn_field.gr_field:fill_grid 
;	stdcall [fm_main.pn_field.gr_field.draw_cell], fm_main.pn_field.gr_field, 2,3
;	stdcall draw_cell, fm_main.pn_field.gr_field.x, fm_main.pn_field.gr_field.y, fm_main.pn_field.gr_field.cell_size 
;	_mcall fm_main.pn_field.gr_field:draw_cell, <2,3,CELL_HIDDEN> 
;	_mcall fm_main.pn_field.gr_field:draw_cell, <1,1,CELL_OPENED> 
    ; Отрисовка формы выхода (нижняя панель)
;    _mcall fm_exit:draw
;    _mcall fm_exit.lb_confirm:draw
;	_mcall fm_exit.bt_yes:draw
;	_mcall fm_exit.bt_no:draw
	
	stdcall init_mouse
	
	_repeat
		stdcall mouse_handle
		stdcall keyboard_handle
	_until [game_state] == GAME_EXIT
	
	stdcall restore_video_mod

    ; Завершение работы — ожидание ввода символа (pausa)
    ret

; --------------------------------------------------------------
;                      Основные компоненты 
; --------------------------------------------------------------
; Каждая процедура ниже отвечает за отрисовку конкретного элемента:
; рамки, фона, строки, символа, сетки и т.д.

; draw_form: рисует внешнюю форму с 3D-рамкой и заливкой
; draw_label: выводит строку с опциональной рамкой/фоном
; draw_panel: панель с рамкой и заливкой
; draw_grid: игровое поле — сетка квадратов (ячейки)
; draw_char: отрисовка символа (цифра или буква)
; set_video_mod: BIOS вызов видеорежима и настройка ES
; draw_line/draw_rect/draw_frame: базовые элементы отрисовки
; centralize_cord: вычисляет координаты для центрирования поля в панели
; change_cell_size: автоподбор размера клетки по количеству строк/столбцов

; --------------------------------------------------------------
;                            Структуры 
; --------------------------------------------------------------
; Компоненты сгруппированы через структуры: Form, Panel, Grid, Label и т.д.
; Также есть составные структуры: PanelControl, PanelField, FormMain, FormExit

; --------------------------------------------------------------
;                  Инициализация интерфейса (fm_main и др.)
; --------------------------------------------------------------
; Используется макрос _generate_cord — рассчитывает координаты
; компонентов до момента создания самой формы.
; Все формы, панели и метки определяются статически через свои структуры
; инициализированные макросом `FormMain`, `PanelField`, `Label` и т.д.

; --------------------------------------------------------------
;                   Шаблоны и цвета символов
; --------------------------------------------------------------
; digits_data: шаблоны отрисовки цифр 0..9 (7 строк по 5 бит)
; letters_data: шаблоны для букв A..Z
; digit_colors/letter_colors: цветовая палитра отрисовки текста


; Переключение видеорежима и установка сегмента ES = A000h
proc set_video_mod_to_13h 
	mov ah,0Fh
	int 10h
	
    mov [prev_mode], al
    mov [prev_page], bh
	
	mov ax,13h          ; Загружаем номер режима
	int 10h             ; BIOS-вызов установки видеорежима
	
	mov ah,5
	mov al,0
	int 10h
	
	push 0A000h         ; Сегмент видеопамяти графического режима
	pop es              ; Устанавливаем ES для доступа к видеопамяти
	
	ret
endp

proc restore_video_mod
    mov al, [prev_mode]
    mov ah, 0
    int 10h

    mov ah, 5
    mov al, [prev_page]
    int 10h
	ret
endp

include "INPUT\KEYBOARD.ASM"

; -------- Процедуры работы с мышкой --------

include "INPUT\MOUSE\LOGIC.ASM"
include "INPUT\MOUSE\DRAW.ASM"

; ----- Процедуры отрисовки компонентов -----

include "LIB\VCL\DRAW.ASM"
include "LIB\VCL\METHODS.ASM"

; ----- Авто-обёртки для структуры компонентов -----
; Упрощают вызов процедур draw/resize/center для структур
		
include "LIB\VCL\AUTO.ASM"
include "LIB\UTILS.ASM"

include "UI\HANDLERS.ASM"
include "UI\DRAW.ASM"

; ----- Данные игрового поля и текстовые ресурсы -----

include "LIB\VCL\DEFSTRUC.ASM"
include "UI\MAINFORM.ASM"
include "UI\DIALOGS.ASM"
include "UI\DATA.ASM"

include "INPUT\MOUSE\DATA.ASM"
include "GAME\DATA\STRINGS.ASM"
include "GAME\DATA\CHARS.ASM"

include "GAME\DATA\STORAGE.ASM"
