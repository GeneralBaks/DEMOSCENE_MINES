proc draw_line uses si di, \
	pos, len, dir, color:BYTE

	; === Вычисление смещения в видеопамяти: y * 320 + x ===
	mov di,[pos]

	mov al,[color]     ; AL = цвет
	mov cx,[len]
	
	_switch word[dir]
	_case DIR_HOR
		rep stosb
	_case DIR_VER
		_loop
			mov [es:di], al     ; Пишем пиксель
			add di,SCR_W         ; Смещаемся вниз на строку
		_end
	_case DIR_DIAG_L
		_loop
			mov [es:di],al
			add di,SCR_W
			inc di
		_end
	_case DIR_DIAG_R
		_loop
			mov [es:di],al
			add di,SCR_W
			dec di
		_end
	_end

	ret
endp


; Тонкая рамка с цветами для верхней/нижней стороны
proc draw_frame \
	pos, wt, ht, cond

	; --- подготовка цветов ---
	_if [cond] == FRM_STD
		mov ax,FRM_UP_COL
		mov dx,FRM_DW_COL
	_elseif [cond] == FRM_REV
		mov ax,FRM_DW_COL
		mov dx,FRM_UP_COL
	_else
		mov ax,[cond]
		mov dx,[cond]
	_end

	; === Верх/лево: светлое ===
	stdcall draw_line, [pos],[wt],DIR_HOR,ax
	stdcall draw_line, [pos],[ht],DIR_VER,ax

	; === Низ/право: тёмное ===
	imul cx,[ht],SCR_W
	add cx,[pos]
	sub cx,SCR_W
	stdcall draw_line, cx,[wt],DIR_HOR,dx

	add cx,[pos]
	add cx,[wt]
	dec cx
	stdcall draw_line, cx,[ht],DIR_VER,dx
	
.end_proc:
	ret
endp


; Заливка прямоугольника
proc draw_rect uses si di, \
	pos, wt, ht, color:BYTE
    mov al,[color]          ; Цвет пикселя
    _if al==0 jmp .end_proc ; Если цвет NONE
	
	mov cx,[ht]
	_if al==0 jmp .end_proc ; Если высота 0 - выходим
	
	mov di,[pos]
	
	_loop
		push cx
		mov cx,[wt]          ; Заливаем строку шириной w
		rep stosb
		pop cx

		add di,SCR_W        ; Переход на следующую строку
		sub di,[wt]          ; Возвращаемся к началу следующей строки
	_end

.end_proc:
	ret
endp


proc draw_cell_h \
	pos, size
	
	stdcall draw_frame, [pos],[size],[size],FRM_STD
	inc [pos]
	add [pos],SCR_W
	sub [size],2
	stdcall draw_frame, [pos],[size],[size],FRM_STD
	inc [pos]
	add [pos],SCR_W
	sub [size],2
	stdcall draw_rect, [pos],[size],[size],CL_GREY_1 
	ret
endp


; Отрисовка сетки
proc draw_grid uses si di, \
	grid
	mov bx,[grid]
	_calc_offset [bx],[bx+2],dx
	sub dx,SCR_W
	dec dx
	push dx
	; === Горизонтальные линии ===
	mov cx,[bx+14]
	inc cx
	_loop
		push cx dx bx
		stdcall draw_line, dx,[bx+4],DIR_HOR,GR_SEPAR_COLOR
		pop bx dx cx
		imul ax,[bx+16],SCR_W
		add ax,SCR_W
		add dx,ax
	_end
	; === Вертикальные линии ===
	pop dx
	mov cx,[bx+12]
	inc cx
	_loop 
		push cx dx bx
		stdcall draw_line, dx,[bx+6],DIR_VER,GR_SEPAR_COLOR
		pop bx dx cx
		add dx,[bx+16]
		inc dx
	_end
.end_proc:
	ret
endp

; Отрисовка строки символов через draw_char
proc draw_string uses bx, \
		pos, string, color
	
	mov bx,[string]
	
	_set_seg es to ds
	stdcall arr_len, bx
	_unset_seg
	
	_if cx == 0 jmp .end_proc
	
	_loop
		push cx bx
		
		movzx ax,byte[bx]
		stdcall draw_char, [pos],ax,[color]
		pop bx
		inc bx
		add [pos],7
		
		pop cx
	_end
.end_proc:
	ret
endp

; Вывод символа (цифра или буква) с шаблоном
proc draw_char uses bx si di, \
    pos, char:byte, color:byte
    
    ; Проверяем, цифра ли это (0-9)
	_if [char] < '0' jmp .check_letter
	_if [char] > '9' jmp .check_letter
        
    ; Это цифра
    sub [char],'0'
    mov si,digits_data
    jmp .draw_symbol
    
.check_letter:
    ; Проверяем, буква ли это (A-Z)	
	_if [char] < 'A' jmp .check_extra
	_if [char] > 'Z' jmp .check_extra
    
    ; Это буква
    sub [char], 'A'
    mov si,letters_data
	jmp .draw_symbol
	
.check_extra:
    ; Проверяем дополнительные символы
    _if [char] == '?' jmp .draw_question
    _if [char] == '*' jmp .draw_mine  
    jmp .end_proc  ; Неизвестный символ
    
.draw_question:
    mov si, extra_symbols_data.question
    jmp .skip_table
    
.draw_mine:
    mov si, extra_symbols_data.mine
    jmp .skip_table
    
.draw_symbol:
    movzx ax,[char]
    mov dx,7
    mul dx              ; AX = symbol * 7
    add si,ax          ; SI указывает на первую строку символа
.skip_table:
    ; Цвет пикселя
	mov al,byte[color]

    ; Начальное смещение в видеопамяти
	mov di,[pos]

    ; Рисуем 7 строк
	_loop 7
		mov dl,[si]        ; Загружаем байт-строку из данных символа
		inc si              ; Следующая строка
		mov bx,10000b     ; Рисуем 5 пикселей (от старшего к младшему биту)

		_loop 5
			test dl,bl
			_if zf == 0
				mov [es:di],al     ; Рисуем пиксель
			_end	  
			inc di
			shr bx,1
		_end

		add di, SCR_W - 5     ; Переход на следующую строку
	_end

.end_proc:
    ret
endp

proc draw_centered_char \
	pos, wt, ht, char, color
	mov dx,[wt]
	sub dx,5
	shr dx,1
	
	mov ax,[ht]
	sub ax,7
	shr ax,1
	
	imul ax,SCR_W
	add ax,dx
	add word[pos],ax
	
	stdcall draw_char, [pos],[char],[color]
	
	ret
endp

; Отрисовка прямоугольной рамки с толщиной
proc draw_hollow_rect uses di si, \
	pos, outer_w, outer_h, border_thickness, color:BYTE

	mov ax,[border_thickness]
	shl ax,1
	; === Расчёт внутреннего прямоугольника (центр, без границ) ===
	mov si,[outer_w]
	sub si,ax
	mov dx,[outer_h]
	sub dx,ax

	; === Начало отрисовки ===
	mov di,[pos]
	mov al,[color]

	; --- Верхняя граница ---
	_loop [border_thickness]
		push cx
		mov cx,[outer_w]
		rep stosb
		add di,SCR_W
		sub di,[outer_w]
		pop cx
	_end

	; --- Боковые границы ---
	_loop dx
		push cx
		mov cx,[border_thickness]
		rep stosb
		add di,si               ; Пропускаем внутреннюю часть
		mov cx,[border_thickness]
		rep stosb
		add di,SCR_W
		sub di,[outer_w]
		pop cx
	_end

	; --- Нижняя граница ---
	_loop [border_thickness]
		push cx
		mov cx,[outer_w]
		rep stosb
		add di,SCR_W
		sub di,[outer_w]
		pop cx
	_end

	ret
endp

; Панель с рамкой и фоном
proc draw_panel, \
	pos, wt, ht, color, frm_cond

	_if [frm_cond] ~= FRM_NONE 
		stdcall draw_frame, [pos],[wt],[ht],[frm_cond]
		add [pos],SCR_W
		inc [pos]
		
		sub [wt],2
		sub [ht],2
	_end
	
	_if [color] ~= NONE
		stdcall draw_rect, [pos],[wt],[ht],[color]
	_end
	
	ret
endp

; Отрисовка формы с рамкой и заливкой
proc draw_form \
	pos, wt, ht, back_col, bw, board_col
	
	; --- Основная внешняя рамка ---
	stdcall draw_frame, [pos],[wt],[ht],FRM_STD
	
	add [pos],SCR_W+1
	sub [wt],2
	sub [ht],2
	stdcall draw_hollow_rect, [pos],[wt],[ht],[bw],[board_col]
	
	imul ax,[bw],SCR_W
	add [pos],ax
	mov ax,[bw]
	add [pos],ax
	
	mov bx,2
	mul bx
	
	sub [wt],ax
	sub [ht],ax
	
	stdcall draw_frame, [pos],[wt],[ht],FRM_REV
	
	add [pos],SCR_W+1
	sub [wt],2
	sub [ht],2
	stdcall draw_rect, [pos],[wt],[ht],[back_col]
	
	ret
endp

; Отрисовка строки с опциональной рамкой и фоном
proc draw_label uses bx, \
	label
	
	mov bx,[label]
	_calc_offset [bx],[bx+2],ax
	
	_if byte[bx+8] ~= NONE
		push ax
		stdcall draw_rect, ax,[bx+4],[bx+6],[bx+8]
		pop ax
	_end
	
	_if byte[bx+10] ~= FRM_NONE
		push ax
		stdcall draw_frame, ax,[bx+4],[bx+6],[bx+10]
		pop ax
		
		mov cx,[bx+4]
		mov dx,[bx+6]
		
		add ax,SCR_W
		sub cx,2
		add ax,SCR_W
		sub cx,2
		add ax,2
	_end	
	
	stdcall draw_string, ax,[bx+12],[bx+14]
	
	ret
endp

proc set_cell_char uses bx si di, \
		grid, mtrx, col_0, row_0
	mov bx,[grid]    
	mov si,[mtrx]
						;здесь у столбца и строки индексация начинается с 0
	mov cx,[bx+16]		;cx = cell_size
	inc cx			    ;cell_size + 1 для учёта разделителя 
	 
	mov ax,[bx]			;ax = grid.x
	mov dx,[col_0]		;dx = cur_col
	imul dx,cx  		;dx(shift) = cur_col  * (cell_size + 1)
	add ax,dx			;cell_x = grid.x + shift
	
	push ax
	
	mov ax,[bx+2]       ;ax = grid.y
	mov dx,[row_0]      ;dx = cur_row
	imul dx,cx          ;dx(shift) = cur_row  * (cell_size + 1)
	add ax,dx           ;cell_y = grid.y + shift	
	
	pop cx
	
	_calc_offset cx,ax,di
	_calc_mtrx_offset [col_0],[row_0],[bx+12]
	add si,5
	add si,ax
	
	mov al,byte[si]
	test al,MASK_OPENED
	jnz .end_proc
	and al,MASK_SYMBOL
	
	_switch al
	_case MASK_HIDDEN
		or byte[si],MASK_QUESTION
		stdcall draw_cell_h, di,[bx+16]
		stdcall draw_centered_char, di,[bx+16],[bx+16],'?',CL_RED_0
	_case MASK_QUESTION
		xor byte[si],MASK_QUESTION
		_if [mines_left] == 0 jmp @f
		
		dec byte[mines_left]
		movzx ax,[mines_left]
		stdcall word_to_str, ax,str_mines_num
		_mcall fm_main.pn_control.lb_mines:draw 
		
		or byte[si],MASK_FLAG
		stdcall draw_cell_h, di,[bx+16]
		stdcall draw_centered_char, di,[bx+16],[bx+16],'F',CL_RED_0
	_case MASK_FLAG
		xor byte[si],MASK_FLAG
		inc byte[mines_left]
		@@:
		
		movzx ax,[mines_left]
		stdcall word_to_str, ax,str_mines_num
		_mcall fm_main.pn_control.lb_mines:draw 
		
		stdcall draw_cell_h, di,[bx+16]
	_end 
.end_proc:
	ret
endp

proc fill_grid uses bx si di, \
	grid,mtrx ;_grid_, col, row, state
	mov bx,[grid]
	mov si,[mtrx]
	add si,5
	
	_calc_offset [bx],[bx+2],di
	
	_for cx=[bx+14] : cx>0 : -1
		push cx
		_for cx=[bx+12] : cx>0 : -1
			push cx
			
			test byte[si],MASK_OPENED
			jz @f
				test byte[si],MASK_MINE
				jz .not_mine
					stdcall draw_rect, di,[bx+16],[bx+16],CL_RED_0
					stdcall draw_centered_char, di,[bx+16],[bx+16],'*',CL_BLACK
					jmp .skip_switch
				.not_mine:
				stdcall draw_rect, di,[bx+16],[bx+16],CL_GREY_0
				movzx dx,byte[si]
				and dl,MASK_COUNT
				jz .skip_num
					stdcall select_num_color, dx
					add dl,'0'
					stdcall draw_centered_char, di,[bx+16],[bx+16],dx,ax
				.skip_num:
				jmp .skip_switch
			@@:
			stdcall draw_cell_h, di,[bx+16]
			test byte[si],MASK_MINE
			jz @f
				cmp byte[game_state],GAME_LOSE
				jne .skip_switch
					stdcall draw_centered_char, di,[bx+16],[bx+16],'*',CL_BLACK
					jmp .skip_switch
			@@:
			test byte[si],MASK_QUESTION
			jz @f
				stdcall draw_centered_char, di,[bx+16],[bx+16],'?',CL_RED_0
				jmp .skip_switch
			@@:
			test byte[si],MASK_FLAG
			jz .skip_switch
				stdcall draw_centered_char, di,[bx+16],[bx+16],'F',CL_RED_0
				

			.skip_switch:
			
			add di,[bx+16]
			inc di
			inc si
			pop cx
		_end
		imul ax,[bx+16],SCR_W
		add di,ax
		add di,SCR_W
		sub di,[bx+4]
		pop cx
	_end
	ret
endp

proc draw_button uses bx, \
	_button_
	mov bx,[_button_]
	stdcall auto_draw_panel, bx
	mov bx,[_button_] 
	
	mov dx,[bx+12]
	_set_seg es to ds
	stdcall arr_len, dx
	_unset_seg
	
	mov ax,cx
	mov dx,5
	mul dx
	dec cx
	imul cx,2
	add ax,cx
	
	mov cx,[bx]
	inc cx
	mov dx,[bx+4]
	sub dx,2
	
	stdcall centralize_cord, cx,dx,ax
	
	mov cx,[bx+2]
	add cx,2
	_calc_offset ax,cx,dx	
	stdcall draw_string, dx,[bx+12],[bx+14]
	ret
endp
