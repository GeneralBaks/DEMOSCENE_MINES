; Сохранение фона под курсором
proc save_cursor_background uses si di, \
    x, y
    mov di,arr_cursor_back ; Указатель на буфер для сохранения фона
    imul si,[y],SCR_W   ; Вычисляем начальное смещение 
    add si,[x]
    push es ds ds es ; ЭЭЭЭЭ... А! Муть с регистрами
    pop ds es ; Свапаем значения регистров ES и DS
    
    ; Сохраняем область CURSOR_SIZE x CURSOR_SIZE
    _loop CURSOR_SIZE
        push cx di si
        mov cx,CURSOR_SIZE
        rep movsb ; Копируем строку из DS:SI в ES:DI      
        pop si di cx
    
        add si,SCR_W ; Переходим к следующей строке
        add di,CURSOR_SIZE
    _end
    pop ds es ; Восстанавливаем значение регистров ES и DS
    
    ret
endp

; Восстановление фона под курсором
proc restore_cursor_background uses si di, \
    x, y 
    mov si,arr_cursor_back ; Указатель на буфер с сохраненным фоном
    imul di,[y],SCR_W ; Вычисляем начальное смещение
    add di,[x]
    
    _loop CURSOR_SIZE ; Восстанавливаем область CURSOR_SIZE x CURSOR_SIZE
        push cx di si
        mov cx,CURSOR_SIZE
        rep movsb       ; Копируем строку из DS:SI в ES:DI
        pop si di cx
        
        add di,SCR_W ; Переходим к следующей строке
        add si,CURSOR_SIZE
    _end
    
    ret
endp

proc draw_cursor uses bx, \
    x, y
    
    locals
        hor_lim db 0
        ver_lim db 0
    endl
    
    ; Высчитываем горизонтальную длину части курсора, которая выходит за экран
    mov ax,CURSOR_SIZE
    add ax,[x]
    sub ax,SCR_W
    ; Обновляем hor_lim, если хоть часть курсора выходит за экран
    jl @f
        mov [hor_lim],al
    @@:
    
    ; Высчитываем вертикальную длину части курсора, которая выходит за экран
    mov ax,CURSOR_SIZE
    add ax,[y]
    sub ax,SCR_H
    ; Обновляем ver_lim, если хоть часть курсора выходит за экран
    jl @f
        mov [ver_lim],al 
    @@:
    
    _calc_offset [x],[y],bx ; Высчитываем смещение для начальной точки отрисовки

    mov cx,CURSOR_SIZE
    sub cl,[hor_lim]
    stdcall draw_line, bx,cx,DIR_HOR,CL_BLACK   ; Рисуем верхнию линию
    
    mov cx,CURSOR_SIZE
    sub cl,[ver_lim]
    stdcall draw_line, bx,cx,DIR_VER,CL_BLACK  ; Рисуем левую линий
    
    mov byte[es:bx],CL_GOLD  ; Отрисовываем золотой пимтик
    
    ; Смещаем точку отрисовки во внутренюю часть
    inc bx
    add bx,SCR_W    
    
    mov dl,CURSOR_SIZE-1    ; Заготовка длины горизонтальной белой линии
    
    mov cx,CURSOR_SIZE-1    ; Заготовка количества повторений
    
    ; Высчитываем количество повторений для горизонтальной линии
    _if byte[ver_lim]>2     
        sub cl,[ver_lim]
    _else
        sub cl,2
    _end
    
    mov dh,2 ; DH необходимо для высчитывания уменьшения горизонтальной линии
    inc cl   
    
    ; Отрисовка внутреней части
    _loop 
        push cx 
        
        ; Высчитывае длину белой линии
        movzx cx,dl
        _if byte[hor_lim]>dh
            sub cl,[hor_lim]
        _else
            sub cl,dh
        _end
        
        mov di,bx                
        mov al,CL_WHITE_0
        rep stosb                ; Отрисовка белой линии

        ; Отрисовка части чёрной диогонали, 
        ; если горизонтальная линия не залазит за экран
        _if dh>byte[hor_lim]
            mov byte[es:di],CL_BLACK 
        _end
        
        add bx,SCR_W ; Смещаемся вниз
        inc dh       ; Сокращаем длину белой линии
        pop cx
    _end

    ret
endp