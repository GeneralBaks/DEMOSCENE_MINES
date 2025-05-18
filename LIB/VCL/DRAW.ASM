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


proc draw_cell \
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
proc draw_string, \
		pos, string, color
	
	mov bx,[string]
	
	_set_seg es to ds
	stdcall arr_len, bx
	_unset_seg
	
	_loop
		push cx bx
		
		movzx ax,byte[bx]
		stdcall draw_char, [pos],ax,[color]
		pop bx
		inc bx
		add [pos],7
		
		pop cx
	_end
	
	ret
endp

; Вывод символа (цифра или буква) с шаблоном
proc draw_char uses si di, \
    pos, char, color
    
    ; Проверяем, цифра ли это (0-9)
	_if [char] < '0' jmp .check_letter
	_if [char] > '9' jmp .check_letter
        
    ; Это цифра
    sub [char],'0'
    mov si,digits_data
    jmp .draw_symbol
    
.check_letter:
    ; Проверяем, буква ли это (A-Z)	
	_if [char] < 'A' jmp .end_proc
	_if [char] > 'Z' jmp .end_proc
    
    ; Это буква
    sub [char], 'A'
    mov si,letters_data
    
.draw_symbol:
    mov ax,[char]
    mov dx,7
    mul dx              ; AX = symbol * 7
    add si,ax          ; SI указывает на первую строку символа

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
proc draw_label \
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