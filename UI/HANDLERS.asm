proc fm_main_exit_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		stdcall draw_fm_exit
		mov [active_form_index], ACTIVE_EXIT
	_end
	ret
endp

proc find_clicked_cell \
	grid
	mov bx,[grid]
	mov ax,[bx]
	mov dx,[bx+2]
	
	_loop [bx+14]
		_loop [bx+12]
			push ax dx
			
			_if [cursor_x] < ax jmp .skip
			_if [cursor_y] < dx jmp .skip
			
			add ax,[bx+16]
			_if [cursor_x] > ax jmp .skip
			
			add dx,[bx+16]
			_if [cursor_y] > dx jmp .skip
			
			pop dx ax
			
			mov ax,[bx+12]
			sub ax,cx
			inc ax
			
			mov dx,[bx+14]
			pop cx
			sub dx,cx
			inc dx
			jmp .end_proc
			
			.skip:
			pop dx ax
			add ax,[bx+16]
			inc ax
		_end
		sub ax,[bx+4]
		
		add dx,[bx+16]
		inc dx
	_end
.end_proc:	
	ret
endp

proc fm_main_grid_button_click
    test [mouse_button], BTN_LEFT
    _if zf == 0
        stdcall find_clicked_cell, fm_main.pn_field.gr_field
       _if cx ~= 0
            ; Сохраняем координаты (1-based) на стек
            push ax dx  ; ax = col (1-based), dx = row (1-based)

            ; Переводим в 0-based индексы
            dec ax     ; ax = col (0-based)
            dec dx     ; dx = row (0-based)

            ; Вычисляем смещение: (row * cols + col) * 2
            mov cx, [field_matrix.cols]  ; Кол-во столбцов
            imul dx, cx                               ; dx = row * cols
            add dx, ax                                ; dx = row * cols + col
;            shl dx, 1                                  ; умножаем на 2 (2 байта на ячейку)

            ; Получаем адрес нужной ячейки
            mov bx,field_matrix.elements
            add bx,dx                                 

            ; Восстанавливаем координаты (1-based)
            pop dx ax

            _if byte[bx] == CELL_HIDDEN
                mov byte[bx], CELL_OPENED
                stdcall restore_cursor_background, [cursor_x],[cursor_y]
                _mcall fm_main.pn_field.gr_field:draw_cell, <ax,dx,CELL_OPENED>
                stdcall save_cursor_background, [cursor_x],[cursor_y]
                stdcall draw_cursor, [cursor_x],[cursor_y]
            _end
        _end
    _end
    ret
endp

proc fm_exit_yes_button_click
	mov [game_state],GAME_EXIT
	ret
endp

proc fm_exit_no_button_click
	mov [active_form_index],ACTIVE_MAIN
	stdcall restore_cursor_background, [cursor_x],[cursor_y]
	stdcall draw_fm_main
	stdcall save_cursor_background, [cursor_x],[cursor_y]
	stdcall draw_cursor, [cursor_x],[cursor_y]
	ret
endp