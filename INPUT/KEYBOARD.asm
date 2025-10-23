; ��������� ������������� �����
proc keyboard_handle

    ; ��������: ���� �� ������� ������� 
    mov ah,01h
    int 16h
    
    jz .no_key           ; ���� ������ ��� � ����� �� ���������

    ; ������ ���� ������� �� ������
    mov ah,00h
    int 16h
    
    ; ���������� ����������� ������� 
    _if al == 0
        jmp .no_key
    _end

    ; ���� ������ ������� ESC 
    _if al == 27
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_fm_exit
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]
        mov [active_form_index],ACTIVE_EXIT
    _end

.no_key:
    ret
endp
