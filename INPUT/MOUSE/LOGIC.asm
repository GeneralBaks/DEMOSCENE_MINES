proc init_mouse
    xor ax,ax  
    int 33h     
    
    _if ax~=0FFFFh jmp .no_mouse 
   
    mov ax,7       ; Установка горизонтальных границ курсора
    xor cx,cx      ; Min X = 0
    mov dx,SCR_W-1 ; Max X = 319 
    int 33h
    
    mov ax,8       ; Установка вертикальных границ курсора
    xor cx,cx      ; Min Y = 0  
    mov dx,SCR_H-1 ; Max Y = 199
    int 33h
    
    stdcall get_mouse_state     ; Получение текущей позиции
    stdcall save_cursor_background, [cursor_x],[cursor_y]  ; Сохранение фона
    stdcall draw_cursor, [cursor_x],[cursor_y]             ; Отрисовка курсора
    
    ret
    
.no_mouse:
    ret
endp

; Получение текущего состояния мыши
proc get_mouse_state
    mov ax,3       ; Функция получения позиции и кнопок
    int 33h        ; CX = X, DX = Y, BX = кнопки
    
    mov ax, [cursor_x]
    mov [prev_x], ax
    mov ax, [cursor_y]
    mov [prev_y], ax
    
    mov [cursor_x],cx  ; Новые координаты
    mov [cursor_y],dx
    
    ret
endp

proc click_handle uses si
    mov bx,clickables_matrix
    add bx,[active_form_index]
    mov bx,[bx]
    
    movzx cx,byte[bx]  ; Количество кликабельных элементов
    inc bx
    _loop
        mov si,[bx]        ; X координата
        mov ax,[si]
        _if [cursor_x] < ax jmp .skip
        mov si,[bx+4]      ; Ширина
        add ax,[si]
        _if [cursor_x] > ax jmp .skip
        mov si,[bx+2]      ; Y координата
        mov ax,[si]
        _if [cursor_y] < ax jmp .skip
        mov si,[bx+6]      ; Высота
        add ax,[si]
        _if [cursor_y] > ax jmp .skip
        
        mov si,[bx+8]      ; Вызов обработчика клика
        stdcall word[si]
        _break
        
        .skip:
        add bx,10
    _end
    ret
endp

proc mouse_handle
    stdcall get_mouse_state
    
    ; Обрабатываем изменение позиции
    mov ax, [cursor_x]
    cmp ax, [prev_x]
    jne .position_changed
    
    mov ax, [cursor_y]
    cmp ax, [prev_y]
    jne .position_changed
    
    jmp .check_click
    
.position_changed:
    ; Восстанавливаем фон по старым координатам
    stdcall restore_cursor_background, [prev_x], [prev_y]
    
    ; Обновляем предыдущие координаты перед сохранением нового фона
    mov ax, [cursor_x]
    mov [prev_x], ax
    mov ax, [cursor_y]
    mov [prev_y], ax
    
    ; Сохраняем новый фон и рисуем курсор
    stdcall save_cursor_background, [cursor_x], [cursor_y]
    stdcall draw_cursor, [cursor_x], [cursor_y]
    
.check_click:
    ; Проверяем кнопки мыши
    test bl, 0FFh
    jz .update_prev_button
    
    ; Обработка нажатия кнопки (только при новом нажатии)
    _if byte[prev_button] == NONE
        ; Сохраняем кнопку и обрабатываем клик
        mov [mouse_button], bl
        stdcall click_handle
    _end
    
.update_prev_button:
    ; Обновляем состояние предыдущей кнопки
    mov [prev_button], bl
    
    ret
endp

; Процедуры ниже по итогу не используются

; Скрытие курсора
proc hide_cursor
    cmp [cursor_visible],CURSOR_N_VISIBLE
    je .already_hidden
    
    stdcall restore_cursor_background, [cursor_x],[cursor_y]  ; Восстановление фона
    mov [cursor_visible],CURSOR_N_VISIBLE
    
.already_hidden:
    ret
endp

; Показ курсора
proc show_cursor
    cmp [cursor_visible],CURSOR_VISIBLE
    je .already_visible
    
    stdcall save_cursor_background, [cursor_x],[cursor_y]  ; Сохранение фона
    stdcall draw_cursor, [cursor_x],[cursor_y]             ; Отрисовка курсора
    mov [cursor_visible],CURSOR_VISIBLE
    
.already_visible:
    ret
endp