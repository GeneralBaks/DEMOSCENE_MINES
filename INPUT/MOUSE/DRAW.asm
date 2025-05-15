; Сохранение фона под курсором
proc save_cursor_background uses si di, \
    x, y
    mov di,arr_cursor_back ; Указатель на буфер для сохранения фона
	imul si,[y],SCR_W	; Вычисляем начальное смещение 
    add si,[x]
    push es ds ds es
	pop ds es
	_loop CURSOR_SIZE ; Сохраняем область CURSOR_SIZE x CURSOR_SIZE
		push cx di si
		mov cx,CURSOR_SIZE
		rep movsb       
		pop si di cx
    
		add si,SCR_W ; Переходим к следующей строке
		add di,CURSOR_SIZE
    _end
	pop ds es
    
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

proc draw_cursor \
    x, y
    
    xor dx,dx
    
    mov ax,[x]
    add ax,CURSOR_SIZE
    sub ax,SCR_W
    
    _if ax > 0 
        mov dx,ax
    _end
    
    mov cx,CURSOR_SIZE
    
    mov ax,[y]
    add ax,CURSOR_SIZE
    sub ax,SCR_H
    
    _if ax > 0 
        sub cx,ax
    _end
    
    mov si,cursor_dump
    imul di,[y],SCR_W  ; Вычисляем начальное смещение
    add di,[x]
    
    mov bx,0           ; Счетчик строк курсора
    _loop
        push cx
        
        ; Вычисляем ширину текущей строки курсора (треугольная форма)
        mov cx,CURSOR_SIZE
		push bx dx
		_if dx < bx
			xchg dx,bx
		_end
		sub cx,dx
		
        jle .skip_row   ; Если ширина <= 0, пропускаем строку
        
        push di
        rep movsb      ; Копируем строку курсора
        pop di
        
    .skip_row:
        ; Указатель источника должен указывать на начало следующей строки курсора
        ; Пропускаем оставшиеся байты в текущей строке курсора
		pop dx bx
		push dx
		
		_if dx > bx
			sub dx,bx
			add si,dx
		_end
		pop dx
        add di,SCR_W   ; Переходим к следующей строке экрана
        pop cx
		inc bx         ; Увеличиваем счетчик строк
    _end
    
    ret
endp