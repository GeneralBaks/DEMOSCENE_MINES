; Центрирование сетки по центру панели
proc centralize_grid_cord \
    panel
; Ожидается структура:
; panel_x       [bx]     — координата X панели
; panel_y       [bx+2]   — координата Y панели
; panel_wt      [bx+4]   — ширина панели
; panel_ht      [bx+6]   — высота панели
; cols          [bx+26]  — количество столбцов
; rows          [bx+28]  — количество строк
; cell_size     [bx+30]  — размер одной ячейки (в пикселях)

    locals
        new_grid_x dw ?      ; новая координата X для сетки
        new_grid_y dw ?      ; новая координата Y для сетки
        new_grid_wt dw ?     ; новая ширина сетки
        new_grid_ht dw ?     ; новая высота сетки
    endl
    
    mov bx,[panel]

    ; Вычисляем ширину сетки: cols * cell_size + (cols - 1) * 1 (разделители)
    mov ax,[bx+30]         ; ax = cell_size
    imul ax,[bx+26]        ; ax = cell_size * cols
    add ax,[bx+26]         ; + разделители между ячейками
    mov [new_grid_wt],ax   ; сохраняем как ширину сетки

    ; Центрируем сетку по горизонтали внутри панели
    mov ax,[bx+4]          ; ax = panel_wt
    sub ax,[new_grid_wt]   ; вычитаем ширину сетки
    shr ax,1               ; делим на 2 (центрирование)
    add ax,5               ; сдвиг от левого края панели
    inc ax                 ; финальная корректировка
    mov [new_grid_x],ax    ; сохраняем координату X сетки

    ; Вычисляем высоту сетки: rows * cell_size + (rows - 1) * 1 + 1
    mov ax,[bx+30]
    imul ax,[bx+28]
    add ax,[bx+28]
    inc ax
    mov [new_grid_ht],ax

    ; Центрируем сетку по вертикали внутри панели
    mov ax,[bx+6]          ; panel_ht
    sub ax,[new_grid_ht]
    shr ax,1
    add ax,[bx+2]          ; смещение от верха панели
    inc ax
    mov [new_grid_y],ax

    ; Сохраняем результаты в структуру панели (начиная с offset +14)
    mov ax,[new_grid_x]
    mov cx,[new_grid_y]
    mov dx,[new_grid_wt]

    add bx,14
    mov [bx],ax            ; grid_x
    mov [bx+2],cx          ; grid_y
    mov [bx+4],dx          ; grid_width

    mov ax,[new_grid_ht]
    mov [bx+6],ax          ; grid_height

    ret
endp


; Автоматический подбор размера ячеек в зависимости от количества столбцов и строк
proc change_cell_size \
    grid

    mov bx,[grid]

    ; Столбцы: уменьшаем размер ячеек при большом количестве
    mov ax,13                 ; базовый размер ячейки
    _if word[bx+12] > 28
        mov ax,7              ; много столбцов — маленькие ячейки
    _elseif word[bx+12] > 21
        mov ax,10             ; умеренно много — средние
    _end

    ; Строки: аналогично
    mov dx,13
    _if word[bx+14] > 14
        mov dx,7
    _elseif word[bx+14] > 9
        mov dx,10
    _end

    ; Берём минимальный из размеров по X и Y
    _if ax > dx
        mov ax,dx
    _end

    ; Устанавливаем рассчитанный размер ячейки
    mov word[bx+16],ax

    ret
endp


; Обновляет количество столбцов и строк в структуре сетки
proc update_grid_dimensions \
    grid, new_cols:byte, new_rows:byte

    mov bx,[grid]
    mov al,[new_cols]
    mov ah,[new_rows]

    mov [bx+12],al    ; grid.cols
    mov [bx+14],ah    ; grid.rows

    ret
endp


; Обновляет параметры матрицы поля (размеры, количество мин и ячеек)
proc update_field_matrix \
    cols:byte, rows:byte, mines:byte

    mov al,[cols]
    mov ah,[rows]

    ; Обновляем размеры в элементе интерфейса и в структуре поля
    mov byte[fm_main.pn_field.gr_field.cols],al
    mov [field_matrix.cols],al
    mov byte[fm_main.pn_field.gr_field.rows],ah
    mov [field_matrix.rows],ah

    ; Вычисляем общее количество ячеек (cols * rows)
    mul ah
    mov [field_matrix.size],ax

    ; Вычисляем количество оставшихся ячеек без мин
    movzx dx,[mines]
    sub ax,dx
    mov [save_cells_left],ax

    ; Устанавливаем общее количество мин
    mov [field_matrix.mines_total],dl
    mov [mines_left],dl

    ret
endp

; Обработчик ввода с клавиатуры для edit
proc edit_keyboard_handler uses si, \
    edit, max_len

    mov bx,[edit]                
    mov si,[bx+12]               ; Указатель на строку редактирования

    ; Очистка клавиатурного буфера
    ; (Впринципи и без этого всё работает)
    mov ah,0Bh
    int 21h
    _while al ~= 0
        mov ah,06h
        int 21h
        mov ah,0Bh
        int 21h
    _end

    ; Переход на DS-сегмент для подсчёта длины строки
    _set_seg es to ds
    stdcall arr_len, si          ; Получаем длину строки (cx)
    _unset_seg

    add si,cx                    ; SI — на конец строки
    _if cx > 0
        dec si                   ; Учитываем последний символ
    _end

    _repeat
        _clear dh               ; dh будет флагом обновления строки

        ; Проверка наличия клавиши
        mov ah,01h
        int 16h
        jz .no_key

        mov ah,00h
        int 16h                 ; AL = символ

        _if al == 0 jmp .no_key ; Защита от расширеного кода

        _switch al
            _case 0Dh           ; Enter — завершить ввод
                _break

            _case 08h           ; Backspace
                _if cx > 0
                    mov byte[si],0
                    dec si
                    dec cx
                    inc dh        ; Обновить строку
                _end

            _standart           ; Обычный символ
                _if cx < [max_len]
                    stdcall check_is_num ; Можно было бы передовать ссылку на свою проверку символа
                    _if dl == 1
                        inc si
                        mov byte[si],al
                        inc cx
                        inc dh
                    _end
                _end
        _end

        ; Если строка изменилась — вызываем функцию перерисовки
        _if dh == 1
            push cx
            stdcall word[bx+16], bx ; Вызов обработчика draw
            pop cx
        _end

        .no_key:
    _until al == 0Dh             ; Пока не нажали Enter
    ret
endp


; Было решено начать использовать в качестве процедуры из-за проблем
; с изменением местами полей в field_matrix().
; Я короче забыл, что если зарезирвировать память знаком ? в самом конце, то она не
; будет занимать место в исполняемом файле. Уже было написанно кучу процедур,
; которые намертво привязан к текущим адресам полей, 
; поэтому я использую этот метод как процедуру.


; Очистка матрицы (заполняем нулями)
proc clear_matrix \
    mtrx
    mov bx,[mtrx]
    mov ax,[bx+3]
    inc ax
    add bx,5
    
    _set_seg es to ds
    stdcall clr_arr, bx,ax
    _unset_seg
    
    ret
endp