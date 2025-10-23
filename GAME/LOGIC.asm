proc generate_mines uses bx si di, \
    mtrx, avoid_col, avoid_row, rand_seed
    
    locals
        avoid_offset dw ?
        base_ptr     dw ?
    endl
    
    mov si, [mtrx]
    mov [base_ptr], si      ; ��������� ������� ���������
    
    movzx cx,byte[si]
    ;����������� ������ � ������� ������������ ������
    _calc_mtrx_offset [avoid_col],[avoid_row],cx
    mov [avoid_offset],ax

    movzx cx,byte[si+2]
    _loop
        push cx
        @@:
        ; �������� ��������� ������� � �������
        mov si,[base_ptr]
        stdcall random_get, 0,[si+3]  ; �� 0 �� ������� ����
        
        ; ���������, �� ��������� �� � ������������ ��������
        cmp ax,[avoid_offset]
        je @b 
        
        ; ��������� �������� ����� ������
        add si, 5               
        add si, ax              
        
        ; ���������, �������� �� ������
        test byte[si], MASK_MINE
        jne @b                  
        
        ; ������������� ����
        mov byte[si], MASK_MINE
        stdcall generate_neighbours, si,[mtrx]
        
        pop cx
    _end
    
    ret
endp


proc generate_neighbours uses bx di si, \
    pos, mtrx
    locals
        last_pos dw ?
        first_pos dw ?
        cols db ?
        rows db ?
        current_row dw ?
        current_col dw ?
    endl
    
    mov bx, [mtrx]
    mov si, bx
    add si, 5                    ; ������ ������ �������
    mov [first_pos], si
    
    ; ��������� ������� �������
    mov al, byte[bx]             ; cols
    mov [cols], al
    mov al, byte[bx+1]           ; rows
    mov [rows], al
    
    mov ax, si
    mov dx, word[bx+3]        
    add ax, dx
    dec ax                       ; ��������� ������ �������
    mov [last_pos], ax
    
    mov di, [pos]
    
    ; ��������� ������� ���������� ������� ����
    mov ax, di
    sub ax, [first_pos]          ; offset �� ������ �������
    
    ; row = offset / cols
    movzx bx,[cols]
    xor dx, dx
    div bx                       ; AX = row, DX = col
    mov [current_row], ax        ; ��������� row
    mov [current_col], dx        ; ��������� col
    
    ; ������� ��� �������� ������ (-1,-1) �� (1,1) 
    _for si=-1 : si<=1 : 1       ; row_offset
        _for di=-1 : di<=1 : 1   ; col_offset
            ; ���������� ����������� ������ (0,0)
            _if si == 0
                _if di == 0
                    jmp @f       ; ������� � ����� ������� ��������
                _end
            _end
            
            ; ��������� ����� ����������
            movzx ax, [rows]
            mov dx, [current_row]    
            add dx, si               ; + row_offset
            _if dx < 0 jmp @f        
            _if dx >= ax jmp @f      
            
            movzx ax, [cols]   
            mov bx, [current_col]    
            add bx, di               ; + col_offset
            _if bx < 0 jmp @f              
            _if bx >= ax jmp @f     
            
            ; ��������� ����� ������: first_pos + row*cols + col
            mov ax, dx               
            movzx cx, [cols]         
            imul ax, cx              ; row * cols
            add ax, bx               ; + col
            add ax, [first_pos]      ; + base address
            
            ; ���������, ��� ����� � ���������� ��������
            _if ax < [first_pos] jmp @f  
            _if ax > [last_pos] jmp @f  
                    
            mov bx,ax               ; ����� �������� ������
            
            ; ���� �� ���� - ����������� �������
            test byte[bx], MASK_MINE
            jnz .skip_inc
            
            inc byte[bx]

.skip_inc:

            @@:
        _end
    _end
    
    ret
endp

proc open_cells uses bx si di, \
    grid, mtrx, col_0, row_0   
    
    mov bx,[grid]
    mov si,[mtrx]
    mov al,byte[col_0]
    mov ah,byte[row_0]
    ; ��������� ������� ����
    _if al < 0 jmp .end_proc
    _if al >= byte[si] jmp .end_proc
    _if ah < 0 jmp .end_proc
    _if ah >= byte[si+1] jmp .end_proc
    
                        ;����� � ������� � ������ ���������� ���������� � 0
    mov cx,[bx+16]      ;cx = cell_size
    inc cx              ;cell_size + 1 ��� ����� ����������� 
     
    mov ax,[bx]         ;ax = grid.x
    mov dx,[col_0]      ;dx = cur_col
    imul dx,cx          ;dx(shift) = cur_col  * (cell_size + 1)
    add ax,dx           ;cell_x = grid.x + shift
    
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
    
    test byte[si],MASK_OPENED
    jnz .end_proc
    
    test byte[si],MASK_FLAG
    jnz .end_proc
    
    test byte[si],MASK_MINE
    jz .not_mine
        mov [game_state],GAME_LOSE
        or byte[si],MASK_OPENED
        jmp .end_proc
    .not_mine:
    
    dec word[save_cells_left]
    mov ax,word[save_cells_left]
    _if ax == 0
        mov [game_state],GAME_WIN   
    _end
    
    stdcall draw_rect, di,[bx+16],[bx+16],CL_GREY_0
    or byte[si],MASK_OPENED
    
    movzx dx, byte[si]
    and dl, MASK_COUNT      ; ��������� ������� �������� ���
    _if dl > 0 
        stdcall select_num_color, dx
        add dl,'0'
        stdcall draw_centered_char, di,[bx+16],[bx+16],dx,ax
        jmp .end_proc 
    _end
    
    _if byte[game_state] == GAME_WIN jmp .end_proc
    _for cl=-1:cl<=1:1
        _for ch=-1:ch<=1:1
            push cx
            xor dx,dx
            xor ax,ax
            
            mov dl, byte[col_0]
            mov al, byte[row_0]
            add dl,cl
            add al,ch
            
            stdcall open_cells, [grid],[mtrx],dx,ax
            pop cx
        _end
    _end    
.end_proc:  
    ret
endp

proc select_num_color \
    mine_count
    
    _switch byte[mine_count]
    _case 1
        mov ax, CL_BLUE_0
    _case 2
        mov ax, CL_GREEN_0
    _case 3
        mov ax, CL_RED_0
    _case 4
        mov ax, CL_MAGENTA_0
    _case 5
        mov ax, CL_BROWN
    _case 6
        mov ax, CL_CYAN_0
    _case 7
        mov ax, CL_BLACK
    _case 8
        mov ax, CL_GREY_1
    _end
    ret
endp
    