; ���������� ���� ��� ��������
proc save_cursor_background uses si di, \
    x, y
    mov di,arr_cursor_back ; ��������� �� ����� ��� ���������� ����
    imul si,[y],SCR_W   ; ��������� ��������� �������� 
    add si,[x]
    push es ds ds es ; �����... �! ���� � ����������
    pop ds es ; ������� �������� ��������� ES � DS
    
    ; ��������� ������� CURSOR_SIZE x CURSOR_SIZE
    _loop CURSOR_SIZE
        push cx di si
        mov cx,CURSOR_SIZE
        rep movsb ; �������� ������ �� DS:SI � ES:DI      
        pop si di cx
    
        add si,SCR_W ; ��������� � ��������� ������
        add di,CURSOR_SIZE
    _end
    pop ds es ; ��������������� �������� ��������� ES � DS
    
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

proc draw_cursor uses bx, \
    x, y
    
    locals
        hor_lim db 0
        ver_lim db 0
    endl
    
    ; ����������� �������������� ����� ����� �������, ������� ������� �� �����
    mov ax,CURSOR_SIZE
    add ax,[x]
    sub ax,SCR_W
    ; ��������� hor_lim, ���� ���� ����� ������� ������� �� �����
    jl @f
        mov [hor_lim],al
    @@:
    
    ; ����������� ������������ ����� ����� �������, ������� ������� �� �����
    mov ax,CURSOR_SIZE
    add ax,[y]
    sub ax,SCR_H
    ; ��������� ver_lim, ���� ���� ����� ������� ������� �� �����
    jl @f
        mov [ver_lim],al 
    @@:
    
    _calc_offset [x],[y],bx ; ����������� �������� ��� ��������� ����� ���������

    mov cx,CURSOR_SIZE
    sub cl,[hor_lim]
    stdcall draw_line, bx,cx,DIR_HOR,CL_BLACK   ; ������ ������� �����
    
    mov cx,CURSOR_SIZE
    sub cl,[ver_lim]
    stdcall draw_line, bx,cx,DIR_VER,CL_BLACK  ; ������ ����� �����
    
    mov byte[es:bx],CL_GOLD  ; ������������ ������� ������
    
    ; ������� ����� ��������� �� ��������� �����
    inc bx
    add bx,SCR_W    
    
    mov dl,CURSOR_SIZE-1    ; ��������� ����� �������������� ����� �����
    
    mov cx,CURSOR_SIZE-1    ; ��������� ���������� ����������
    
    ; ����������� ���������� ���������� ��� �������������� �����
    _if byte[ver_lim]>2     
        sub cl,[ver_lim]
    _else
        sub cl,2
    _end
    
    mov dh,2 ; DH ���������� ��� ������������ ���������� �������������� �����
    inc cl   
    
    ; ��������� ��������� �����
    _loop 
        push cx 
        
        ; ���������� ����� ����� �����
        movzx cx,dl
        _if byte[hor_lim]>dh
            sub cl,[hor_lim]
        _else
            sub cl,dh
        _end
        
        mov di,bx                
        mov al,CL_WHITE_0
        rep stosb                ; ��������� ����� �����

        ; ��������� ����� ������ ���������, 
        ; ���� �������������� ����� �� ������� �� �����
        _if dh>byte[hor_lim]
            mov byte[es:di],CL_BLACK 
        _end
        
        add bx,SCR_W ; ��������� ����
        inc dh       ; ��������� ����� ����� �����
        pop cx
    _end

    ret
endp