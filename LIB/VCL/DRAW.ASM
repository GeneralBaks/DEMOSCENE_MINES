proc draw_line uses si di, \
	x, y, len, dir, color:BYTE

	; === Вычисление смещения в видеопамяти: y * 320 + x ===
	imul di,[y],SCR_W
	add di,[x]

	mov al,[color]     ; AL = цвет
	mov cx,[len]
	
	_switch [dir]
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

; Заливка прямоугольника
proc draw_rect uses di, \
	x, y, w, h, color:BYTE
	
    mov al,[color]          ; Цвет пикселя
    _if al==0 jmp .end_proc ; Если цвет NONE
	
	mov cx,[h]
	_if al==0 jmp .end_proc ; Если высота 0 - выходим
	
	imul di,[y],SCR_W  	    ; Начало в видеопамяти: y * 320
	add di,[x]         	    ; + смещение x
	
	_loop
		push cx
		mov cx,[w]          ; Заливаем строку шириной w
		rep stosb
		pop cx

		add di,SCR_W        ; Переход на следующую строку
		sub di,[w]          ; Возвращаемся к началу следующей строки
	_end

.end_proc:
	ret
endp

; Отрисовка прямоугольной рамки с толщиной
proc draw_hollow_rect uses di si, \
	x, y, outer_w, outer_h, border_thickness, color:BYTE

	mov ax,[border_thickness]
	shl ax,1
	; === Расчёт внутреннего прямоугольника (центр, без границ) ===
	mov si,[outer_w]
	sub si,ax
	mov dx,[outer_h]
	sub dx,ax

	; === Начало отрисовки ===
	imul di,[y],SCR_W
	add di,[x]
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

; Тонкая рамка с цветами для верхней/нижней стороны
proc draw_frame \
	x, y, w, h, cond

	; --- Проверка габаритов (влезает ли в экран) ---
	mov ax,[x]
	add ax,[w]
	_if ax>SCR_W jmp .end_proc

	mov ax,[y]
	add ax,[h]
	_if ax>SCR_H jmp .end_proc

	; --- подготовка цветов ---
	_if [cond] == FRM_STD
		mov ax,FRM_UP_COL
		mov bx,FRM_DW_COL
	_elseif [cond] == FRM_REV
		mov ax,FRM_DW_COL
		mov bx,FRM_UP_COL
	_else
		mov ax,[cond]
		mov bx,[cond]
	_end

	; === Верх/лево: светлое ===
	stdcall draw_line, [x],[y],[w],1,ax
	stdcall draw_line, [x],[y],[h],0,ax

	; === Низ/право: тёмное ===
	mov cx,[y]
	add cx,[h]
	dec cx
	stdcall draw_line, [x],cx,[w],1,bx

	mov cx,[x]
	add cx,[w]
	dec cx
	stdcall draw_line, cx,[y],[h],0,bx
	
.end_proc:
	ret
endp

; Панель с рамкой и фоном
proc draw_panel, \
	x, y, w, h, color, frm_cond

	_if [frm_cond] ~= FRM_NONE 
		stdcall draw_frame, [x],[y],[w],[h],[frm_cond]
		inc [x]
		inc [y]
		
		sub [w],2
		sub [h],2
	_end
	
	_if [color] ~= NONE
		stdcall draw_rect, [x],[y],[w],[h],[color]
	_end
	
	ret
endp

; Отрисовка формы с рамкой и заливкой
proc draw_form \
	x, y, w, h, back_col, bw, board_col
	
	; --- Основная внешняя рамка ---
	stdcall draw_frame, [x],[y],[w],[h],FRM_STD
	
	inc [x]
	inc [y]
	sub [w],2
	sub [h],2
	stdcall draw_hollow_rect, [x],[y],[w],[h],[bw],[board_col]
	
	mov ax,[bw]
	add [x],ax
	add [y],ax
	
	mov bx,2
	mul bx
	
	sub [w],ax
	sub [h],ax
	
	stdcall draw_frame, [x],[y],[w],[h],FRM_REV
	
	inc [x]
	inc [y]
	sub [w],2
	sub [h],2
	stdcall draw_rect, [x],[y],[w],[h],[back_col]
	
	ret
endp

; Отрисовка строки с опциональной рамкой и фоном
proc draw_label \
	x, y, w, h, back_color, frm_cond, string, string_color
		
	locals
		total_w dw ?
	endl
	
	_if [back_color] ~= NONE
		stdcall draw_rect, [x],[y],[w],[h],[back_color]
	_end
	
	_if [frm_cond] ~= FRM_NONE
		stdcall draw_frame, [x],[y],[w],[h],[frm_cond]
		add [x],2
		add [y],2
		
		sub [w],2
		sub [h],2
	_end
	
	stdcall draw_string, [x],[y],[string],[string_color]
	
	ret
endp

; Отрисовка строки символов через draw_char
proc draw_string, \
		x, y, string, color
	
	mov bx,[string]
	
	_set_seg es to ds
	stdcall arr_len, bx
	_unset_seg
	
	_loop
		push cx bx
		
		movzx ax,byte[bx]
		stdcall draw_char, [x],[y],ax,[color]
		pop bx
		inc bx
		add [x],7
		
		pop cx
	_end
	
	ret
endp

; Вывод символа (цифра или буква) с шаблоном
proc draw_char uses si di, \
    cell_x, cell_y, char, color
    
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
;    mov al,byte[char]
;    xlatb               ; AL = цвет пикселя
	mov al,byte[color]

    ; Вычисление начального смещения в видеопамяти (320x200)
    imul di,[cell_y],SCR_W
    add di,[cell_x]

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

; Отрисовка сетки
proc draw_grid uses si di, \
	x, y, cols, rows, cell_size
	
	locals
		total_w dw ?
		total_h dw ?
	endl

	cmp [cell_size], 1
	jl .end_proc

	; === Расчёт полной ширины и высоты области ===
	mov ax,[cols]
	imul ax,[cell_size]
	add ax,[cols]                  ; ещё одна вертикальная линия
	mov [total_w],ax

	mov ax,[rows]
	imul ax,[cell_size]
	add ax,[rows]
	inc ax
	mov [total_h],ax

	; === Вертикальные линии ===
	mov cx,[cols]
	inc cx
	mov si,[x]
	mov di,[y]
	_loop
		push cx
		stdcall draw_line, si,di,[total_h],0,GR_SEPAR_COL
		add si,[cell_size]
		inc si
		pop cx
	_end

	; === Горизонтальные линии ===
	mov cx, [rows]
	inc cx
	mov si, [x]
	mov di, [y]
	_loop
		push cx
		stdcall draw_line, si,di,[total_w],1,GR_SEPAR_COL
		add di,[cell_size]
		inc di
		pop cx
	_end

.end_proc:
	ret
endp

proc draw_cell \
	x, y, size
	stdcall draw_frame, [x],[y],[size],[size],FRM_STD
	inc [x]
	inc [y]
	sub [size],2
	stdcall draw_frame, [x],[y],[size],[size],FRM_STD
	inc [x]
	inc [y]
	sub [size],2
	stdcall draw_rect, [x],[y],[size],[size],CL_GREY_1 
	ret
endp