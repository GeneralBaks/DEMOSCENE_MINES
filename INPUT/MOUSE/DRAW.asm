; ���������� ���� ��� ��������
proc save_cursor_background uses si di, \
    x, y
    mov di,arr_cursor_back ; ��������� �� ����� ��� ���������� ����
	imul si,[y],SCR_W	; ��������� ��������� �������� 
    add si,[x]
    push es ds ds es
	pop ds es
	_loop CURSOR_SIZE ; ��������� ������� CURSOR_SIZE x CURSOR_SIZE
		push cx di si
		mov cx,CURSOR_SIZE
		rep movsb       
		pop si di cx
    
		add si,SCR_W ; ��������� � ��������� ������
		add di,CURSOR_SIZE
    _end
	pop ds es
    
    ret
endp

; �������������� ���� ��� ��������
proc restore_cursor_background uses si di, \
    x, y 
    mov si,arr_cursor_back ; ��������� �� ����� � ����������� �����
    imul di,[y],SCR_W ; ��������� ��������� ��������
    add di,[x]
    
	_loop CURSOR_SIZE ; ��������������� ������� CURSOR_SIZE x CURSOR_SIZE
		push cx di si
		mov cx,CURSOR_SIZE
		rep movsb       ; �������� ������ �� DS:SI � ES:DI
		pop si di cx
		
		add di,SCR_W ; ��������� � ��������� ������
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
    imul di,[y],SCR_W  ; ��������� ��������� ��������
    add di,[x]
    
    mov bx,0           ; ������� ����� �������
    _loop
        push cx
        
        ; ��������� ������ ������� ������ ������� (����������� �����)
        mov cx,CURSOR_SIZE
		push bx dx
		_if dx < bx
			xchg dx,bx
		_end
		sub cx,dx
		
        jle .skip_row   ; ���� ������ <= 0, ���������� ������
        
        push di
        rep movsb      ; �������� ������ �������
        pop di
        
    .skip_row:
		pop dx bx
		push dx
		
		_if dx > bx
			sub dx,bx
			add si,dx
		_end
		pop dx
        add di,SCR_W   ; ��������� � ��������� ������ ������
        pop cx
		inc bx         ; ����������� ������� �����
    _end
    
    ret
endp