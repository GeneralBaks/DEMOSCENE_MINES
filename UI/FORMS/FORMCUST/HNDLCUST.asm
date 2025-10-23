proc edit_cols_on_click 
    stdcall edit_on_click, fm_custom_options.ed_cols,2
    ret
endp

proc edit_rows_on_click
    stdcall edit_on_click, fm_custom_options.ed_rows,2
    ret
endp

proc edit_mines_on_click
    stdcall edit_on_click, fm_custom_options.ed_mines,2
    ret
endp

proc edit_on_click \
    edit, len
    test [mouse_button],BTN_LEFT
    _if zf == 0 
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall edit_keyboard_handler, [edit],[len]
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]
    _end
    ret
endp

; Обработка нажатия на кнопку "ОК" в форме пользовательских настроек
proc fm_custom_options_ok_button_click
    test [mouse_button], BTN_LEFT
    _if zf == 1 jmp .end_proc
    
        stdcall get_custom_set
        jc .invalid_data        ; Ошибка — пропустить и вернуться на главную форму
    
            ; Переход к генерации новой карты
            push ax ax cx dx     ; Сохраняем значения: мины, строки, столбцы
            stdcall clear_matrix, field_matrix
            pop dx cx ax
            stdcall update_field_matrix, cx, dx, ax
            pop ax
            stdcall word_to_str, ax, str_mines_num
    
        stdcall reset_timer    
    
    .invalid_data:
        mov [active_form_index], ACTIVE_MAIN
        stdcall set_to_default_bt_reset
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_fm_main
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]

.end_proc:
    ret
endp


; Получает пользовательские значения (столбцы, строки, мины)
; Проверяет на валидность. Устанавливает CF=1 при ошибке.
; Здесь я пожалел, что использовал С строки
proc get_custom_set
    locals
        temp_cols db ?   ; Временные переменные
        temp_rows db ?
    endl
    
    ; Читаем и проверяем колонки
    _set_seg es to ds
    stdcall arr_len, str_ed_cols
    _unset_seg
    
    stdcall try_str_to_word, str_ed_cols,cx
    _if ax < MIN_COLS jmp .invalid_data
    _if ax > MAX_COLS jmp .invalid_data
    mov [temp_cols],al
    
    ; Читаем и проверяем строки
    _set_seg es to ds
    stdcall arr_len, str_ed_rows
    _unset_seg
    
    stdcall try_str_to_word, str_ed_rows,cx
    _if ax < MIN_ROWS jmp .invalid_data
    _if ax > MAX_ROWS jmp .invalid_data
    mov [temp_rows],al
    
    ; Читаем и проверяем мины
    _set_seg es to ds
    stdcall arr_len, str_ed_mines
    _unset_seg
    
    stdcall try_str_to_word, str_ed_mines,cx
    
    movzx dx, [temp_cols]
    movzx cx, [temp_rows]
    imul cx, dx               ; Общее количество клеток
    
    _if ax < 1 jmp .invalid_data
    _if ax > cx jmp .invalid_data ; Мин не должно быть больше клеток

    ; Подготовка параметров (cols в cx, rows в dx)
    movzx cx,[temp_cols]
    movzx dx,[temp_rows]

    clc                         ; Валидные данные
    jmp .end_proc

.invalid_data:
    stc                         ; Ошибка
.end_proc:
    ret
endp



proc fm_custom_options_back_button_click
    test [mouse_button],BTN_LEFT
    _if zf == 0 
        mov [active_form_index],ACTIVE_OPTIONS
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_fm_options
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]
    _end
    ret
endp
