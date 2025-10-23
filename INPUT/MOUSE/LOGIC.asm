proc init_mouse
    xor ax,ax  
    int 33h     
    
    _if ax~=0FFFFh jmp .no_mouse 
   
    mov ax,7       ; ��������� �������������� ������ �������
    xor cx,cx      ; Min X = 0
    mov dx,SCR_W-1 ; Max X = 319 
    int 33h
    
    mov ax,8       ; ��������� ������������ ������ �������
    xor cx,cx      ; Min Y = 0  
    mov dx,SCR_H-1 ; Max Y = 199
    int 33h
    
    stdcall get_mouse_state     ; ��������� ������� �������
    stdcall save_cursor_background, [cursor_x],[cursor_y]  ; ���������� ����
    stdcall draw_cursor, [cursor_x],[cursor_y]             ; ��������� �������
    
    ret
    
.no_mouse:
    ret
endp

; ��������� �������� ��������� ����
proc get_mouse_state
    mov ax,3       ; ������� ��������� ������� � ������
    int 33h        ; CX = X, DX = Y, BX = ������
    
    mov ax, [cursor_x]
    mov [prev_x], ax
    mov ax, [cursor_y]
    mov [prev_y], ax
    
    mov [cursor_x],cx  ; ����� ����������
    mov [cursor_y],dx
    
    ret
endp

proc click_handle uses si
    mov bx,clickables_matrix
    add bx,[active_form_index]
    mov bx,[bx]
    
    movzx cx,byte[bx]  ; ���������� ������������ ���������
    inc bx
    _loop
        mov si,[bx]        ; X ����������
        mov ax,[si]
        _if [cursor_x] < ax jmp .skip
        mov si,[bx+4]      ; ������
        add ax,[si]
        _if [cursor_x] > ax jmp .skip
        mov si,[bx+2]      ; Y ����������
        mov ax,[si]
        _if [cursor_y] < ax jmp .skip
        mov si,[bx+6]      ; ������
        add ax,[si]
        _if [cursor_y] > ax jmp .skip
        
        mov si,[bx+8]      ; ����� ����������� �����
        stdcall word[si]
        _break
        
        .skip:
        add bx,10
    _end
    ret
endp

proc mouse_handle
    stdcall get_mouse_state
    
    ; ������������ ��������� �������
    mov ax, [cursor_x]
    cmp ax, [prev_x]
    jne .position_changed
    
    mov ax, [cursor_y]
    cmp ax, [prev_y]
    jne .position_changed
    
    jmp .check_click
    
.position_changed:
    ; ��������������� ��� �� ������ �����������
    stdcall restore_cursor_background, [prev_x], [prev_y]
    
    ; ��������� ���������� ���������� ����� ����������� ������ ����
    mov ax, [cursor_x]
    mov [prev_x], ax
    mov ax, [cursor_y]
    mov [prev_y], ax
    
    ; ��������� ����� ��� � ������ ������
    stdcall save_cursor_background, [cursor_x], [cursor_y]
    stdcall draw_cursor, [cursor_x], [cursor_y]
    
.check_click:
    ; ��������� ������ ����
    test bl, 0FFh
    jz .update_prev_button
    
    ; ��������� ������� ������ (������ ��� ����� �������)
    _if byte[prev_button] == NONE
        ; ��������� ������ � ������������ ����
        mov [mouse_button], bl
        stdcall click_handle
    _end
    
.update_prev_button:
    ; ��������� ��������� ���������� ������
    mov [prev_button], bl
    
    ret
endp

; ��������� ���� �� ����� �� ������������

; ������� �������
proc hide_cursor
    cmp [cursor_visible],CURSOR_N_VISIBLE
    je .already_hidden
    
    stdcall restore_cursor_background, [cursor_x],[cursor_y]  ; �������������� ����
    mov [cursor_visible],CURSOR_N_VISIBLE
    
.already_hidden:
    ret
endp

; ����� �������
proc show_cursor
    cmp [cursor_visible],CURSOR_VISIBLE
    je .already_visible
    
    stdcall save_cursor_background, [cursor_x],[cursor_y]  ; ���������� ����
    stdcall draw_cursor, [cursor_x],[cursor_y]             ; ��������� �������
    mov [cursor_visible],CURSOR_VISIBLE
    
.already_visible:
    ret
endp