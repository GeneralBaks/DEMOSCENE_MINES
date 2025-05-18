proc init_mouse
    xor ax,ax  
    int 33h     
    
	_if ax~=0FFFFh jmp .no_mouse ; Проверка, доступен ли драйвер мыши (AX будет 0FFFFh если да)
   

    mov ax,7       ; Установка горизонтальных границ
    xor cx,cx      ; Min X = 0
    mov dx,SCR_W-1 ; Max X = 319 
    int 33h
    
    mov ax,8       ; Установка вертикальных границ
    xor cx,cx      ; Min Y = 0  
    mov dx,SCR_H-1 ; Max Y = 199
    int 33h
    
    ; Сохраним начальную позицию для дальнейшей работы
    stdcall get_mouse_state
    
    ; Сохраняем фон под начальной позицией курсора
    stdcall save_cursor_background, [cursor_x],[cursor_y]
    
    ; Отрисовываем курсор в начальной позиции
    stdcall draw_cursor, [cursor_x],[cursor_y]
    
    ret
    
.no_mouse:
    ret
endp

; Получить текущую позицию курсора
proc get_mouse_state
    mov ax,3       ; Функция 3: получить позицию и статус кнопок
    int 33h         ; CX = X, DX = Y, BX = состояние кнопок
    
    mov ax,[cursor_x] ; Сохраняем предыдущие координаты
    mov [prev_x],ax
    mov ax,[cursor_y]
    mov [prev_y],ax
    
    mov [cursor_x],cx
    mov [cursor_y],dx
    
    ret
endp

proc click_handle uses si
	mov bx,clickables_matrix
	add bx,[active_form_index]
	mov ax,[bx]
	xchg ax,bx
	
	movzx cx,byte[bx]
	inc bx
	_loop
		mov si,[bx]
		mov ax,[si]
		_if [cursor_x] < ax jmp .skip
		mov si,[bx+4]
		add ax,[si]
		_if [cursor_x] > ax jmp .skip
		mov si,[bx+2]
		mov ax,[si]
		_if [cursor_y] < ax jmp .skip
		mov si,[bx+6]
		add ax,[si]
		_if [cursor_y] > ax jmp .skip
		
		mov si,[bx+8]
		stdcall word[si]
		_break
		
		.skip:
		add bx,10
	_end
	ret
endp

proc mouse_handle
    stdcall get_mouse_state
    
    ; Проверяем, изменилось ли состояние кнопок
    test bl, 0FFh         ; Проверяем, нажата ли какая-либо кнопка
    jz .buttons_released  ; Если нет (BL=0), переходим к обработке отпускания
    
    ; Если какая-то кнопка нажата:
    cmp [prev_button],NONE   ; Проверяем, была ли кнопка отпущена ранее
    jne .skip_click       ; Если кнопка уже была нажата, пропускаем обработку
    
    ; Если кнопка только что нажата (переход из 0 в ненулевое значение):
    mov [mouse_button], bl
    stdcall click_handle  ; Обрабатываем клик
    jmp .skip_click
    
.buttons_released:
    ; Кнопки отпущены - сбрасываем предыдущее состояние
    mov [prev_button],NONE
    
.skip_click:
    ; Сохраняем текущее состояние кнопок для следующего вызова
    mov [prev_button], bl
    
    ; Обработка перемещения мыши
    mov ax, [cursor_x]
    cmp ax, [prev_x]
    jne .position_changed
	
    mov ax, [cursor_y]
    cmp ax, [prev_y]
    jne .position_changed
	
    jmp .end_proc
    
.position_changed:
    cmp [cursor_visible], CURSOR_VISIBLE
    jne .no_restore
    stdcall restore_cursor_background, [prev_x], [prev_y]
.no_restore:
    stdcall save_cursor_background, [cursor_x], [cursor_y]
    stdcall draw_cursor, [cursor_x], [cursor_y]
    mov [cursor_visible], CURSOR_VISIBLE
    
.end_proc:
    ret
endp

; Скрытие курсора
proc hide_cursor
    ; Если курсор уже скрыт, ничего не делаем
    cmp [cursor_visible],CURSOR_N_VISIBLE
    je .already_hidden
    
    ; Восстанавливаем фон под курсором
    stdcall restore_cursor_background, [cursor_x],[cursor_y]
    
    ; Устанавливаем флаг скрытия
    mov [cursor_visible],CURSOR_N_VISIBLE
    
.already_hidden:
    ret
endp

; Показ курсора
proc show_cursor
    ; Если курсор уже видим, ничего не делаем
    cmp [cursor_visible],CURSOR_VISIBLE
    je .already_visible
    
    ; Сохраняем фон и отрисовываем курсор
    stdcall save_cursor_background, [cursor_x],[cursor_y]
    stdcall draw_cursor, [cursor_x],[cursor_y]
    
    ; Устанавливаем флаг видимости
    mov [cursor_visible],CURSOR_VISIBLE
    
.already_visible:
    ret
endp