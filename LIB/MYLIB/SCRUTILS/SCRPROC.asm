; ������������ � ���������� 13h � ��������� �������� �����������
proc set_video_mod_to_13h 
    ; ���������� �������� ������ � �������� ��������
    mov ah, 0Fh
    int 10h
    
    mov [prev_mode], al
    mov [prev_page], bh
    
    ; ��������� ����������� 13h 
    mov ax, 13h
    int 10h
    
    ; ��������� �������� �������� 0
    mov ah, 5
    mov al, 0
    int 10h
    
    ; ��������� ES �� ������� �����������
    push 0A000h
    pop es
    
    ret
endp

; �������������� ��������� �����������
proc restore_video_mod
    ; �������������� ����������� �����������
    mov al, [prev_mode]
    mov ah, 0
    int 10h

    ; �������������� �������� ��������
    mov ah, 5
    mov al, [prev_page]
    int 10h
    ret
endp