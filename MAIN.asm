; MINES - Игра "Сапёр" на ассемблере
; --------------------------------------------------------------
;                        Кодстайл
; --------------------------------------------------------------
; Константы - UPPER_SNAKE_CASE
; Переменные, операнды в памяти - snake_case с префиксами по типу данных 
;   (например: str_text) - не везде есть префикс
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
; ¦   +-- RANDOM.ASM            - Генератор случайных чисел
; ¦   L-- LOGIC.ASM             - Основная игровая логика
; ¦   
; +-- INPUT/                 - Обработка пользовательского ввода
; ¦   +-- KEYBOARD.ASM       - Обработка событий клавиатуры
; ¦   L-- MOUSE/
; ¦       +-- DATA.ASM       - Данные состояния мыши
; ¦       +-- MOUSEDMP.ASM   - Хранилище для занего фона мышки
; ¦       +-- DRAW.ASM       - Отрисовка курсора мыши
; ¦       L-- LOGIC.ASM      - Логика обработки событий мыши
; ¦
; +-- LIB/                   - Библиотеки
; ¦   +-- MYLIB/             - Пользовательские библиотеки
; ¦   ¦   +-- SCRUTILS/          - Папка с процедурами и данными для работы с графическим режимом
; ¦   ¦   ¦   +-- SCRDATA.ASM    - Данные о предыдущей страницы и режиме
; ¦   ¦   ¦   L-- SCRPROC.ASM    - Процедуры для изменения и востановления режима
; ¦   ¦   +-- VCL/               - Библиотека визуальных компонентов
; ¦   ¦   ¦   +-- AUTO.ASM       - Обёртки для методов и процедур отрисовок(Загнулась)
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

; --------------------------------------------------------------
;                       Заметки
; --------------------------------------------------------------
; Методом я обзываю процедуру, которая всегда требует в качестве одного из параметра
; структуру, в которой находиться метка этой процедуры.
; Компоненты - это структуры с визуальным представлением.
; Инициализацию форм даже не буду пытаться комментировать - 
; это отдельный адский слой кода
; Некоторые процедуры находятся несовсем в своих модулях.

include "LIB\STDLIB\PROC16.INC"     ; Стандартные процедуры FASM 
include "LIB\STDLIB\STRUCT.INC"     ; Стандартные определения структур FASM
include "LIB\MYLIB\MACROS.ASM"      ; Макросы общего назначения (_mcall, _if, _repeat и др.)
include "CONFIG.ASM"                ; Глобальные константы и параметры конфигурации проекта

; --------------------------------------------------------------
;                  Точка входа и основной цикл
; --------------------------------------------------------------
org 100h
start:
    stdcall set_video_mod_to_13h      

    stdcall fm_main_centralize_buttons    ; Центровка кнопок главной формы(retset)
    stdcall fm_options_centralize_buttons ; Центровка кнопок формы настроек
    stdcall clear_matrix, field_matrix    ; Очистка игрового поля

    stdcall draw_fm_main               ; Отрисовка интерфейса главной формы
    stdcall init_mouse                 ; Инициализация мыши
    stdcall init_random                ; Инициализация генератора случайных чисел

    ; Главный цикл программы
    _repeat
        ; Обработку нажатия мышки можно было формить через
        ; int 33h 0Ch, но поздно узнал об этом
        stdcall mouse_handle      
    
        ; Обработка клавиатуры
        stdcall keyboard_handle        

        ; Проверка состояния игры и активной формы
        _if [game_state] == GAME_PLAY
            _if [active_form_index] == ACTIVE_MAIN
                stdcall update_timer, fm_main.pn_control.lb_timer ; Обновление таймера
                _if word[game_time] == MAX_TIME
                    mov [game_state], GAME_LOSE
                    stdcall change_br_reset_to_lose
                    _mcall fm_main.pn_control.bt_reset:draw
                    _mcall fm_main.pn_field.gr_field:fill_grid, <field_matrix>
                _end
            _end
        _end
    _until [game_state] == GAME_EXIT

    stdcall restore_video_mod          ; Возврат текстового видеорежима
    ret                                
; --------------------------------------------------------------
;                     Подключение модулей 
; --------------------------------------------------------------

; Игровая логика
include "GAME\LOGIC.ASM"              ; Основная логика игры
include "GAME\RANDOM.ASM"             ; Случайные числа (расположение мин)

; Ввод с клавиатуры и мыши
include "INPUT\KEYBOARD.ASM"          ; Обработка клавиш
include "INPUT\MOUSE\LOGIC.ASM"       ; Обработка событий мыши
include "INPUT\MOUSE\DRAW.ASM"        ; Отрисовка курсора

; UI-компоненты и отрисовка
include "LIB\MYLIB\VCL\DRAW.ASM"      ; Базовая отрисовка компонентов
include "LIB\MYLIB\VCL\METHODS.ASM"   ; Методы компонентов VCL
include "LIB\MYLIB\VCL\AUTO.ASM"      ; Обёртка для более удобной работы с полями(сдохла)

; Вспомогательные библиотеки
include "LIB\MYLIB\UTILS.ASM"            ; Утилиты общего назначения
include "LIB\MYLIB\SCRUTILS\SCRPROC.ASM" ; Процедуры переключения видеорежимов
include "LIB\MYLIB\VCL\DEFSTRUC.ASM"     ; Структуры визуальных компонентов

; Формы интерфейса: главная, выход, настройки, пользовательская
include "UI\FORMS\FORMMAIN\DRAWMAIN.ASM"
include "UI\FORMS\FORMMAIN\HNDLMAIN.ASM"

include "UI\FORMS\FORMEXIT\DRAWEXIT.ASM"
include "UI\FORMS\FORMEXIT\HNDLEXIT.ASM"

include "UI\FORMS\FORMSETT\DRAWSETT.ASM"
include "UI\FORMS\FORMSETT\HNDLSETT.ASM"

include "UI\FORMS\FORMCUST\DRAWCUST.ASM"
include "UI\FORMS\FORMCUST\HNDLCUST.ASM"

include "UI\TIMER.ASM"                ; Управление игровым таймером
include "UI\PREPCOMP.ASM"             ; Предварительная инициализация компонентов

; Инициализация всех форм
include "UI\FORMS\FORMMAIN\INITMAIN.ASM"
include "UI\FORMS\FORMEXIT\INITEXIT.ASM"
include "UI\FORMS\FORMSETT\INITSETT.ASM"
include "UI\FORMS\FORMCUST\INITCUST.ASM"

; Данные интерфейса
include "UI\DATA\CHARS.ASM"              ; Символы для отрисовки
include "UI\DATA\STRINGS.ASM"            ; ВСЕ строки в программе
include "UI\DATA\CLKDATA.ASM"            ; Данные обработки кликов
include "LIB\MYLIB\SCRUTILS\SCRDATA.ASM" ; Данные видеостраницы
include "UI\DATA\TIMEDATA.ASM"           ; Данные таймера

; Данные и отладка мыши
include "INPUT\MOUSE\DATA.ASM"       ; Переменные мыши
include "GAME\DATA\STORAGE.ASM"      ; Игровое поле, состояние ячеек
include "INPUT\MOUSE\MOUSEDMP.ASM"   ; Буфер под курсор мыши (для восстановления фона)
