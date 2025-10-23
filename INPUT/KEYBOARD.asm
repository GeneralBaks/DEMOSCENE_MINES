; Обработка клавиатурного ввода
proc keyboard_handle

    ; Проверка: есть ли нажатая клавиша 
    mov ah,01h
    int 16h
    
    jz .no_key           ; если клавиш нет — выйти из процедуры

    ; Чтение кода клавиши из буфера
    mov ah,00h
    int 16h
    
    ; Игнорируем расширенные клавиши 
    _if al == 0
        jmp .no_key
    _end

    ; Если нажата клавиша ESC 
    _if al == 27
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_fm_exit
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]
        mov [active_form_index],ACTIVE_EXIT
    _end

.no_key:
    ret
endp
