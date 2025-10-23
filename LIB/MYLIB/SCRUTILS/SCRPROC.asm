; Переключение в видеорежим 13h и установка сегмента видеопамяти
proc set_video_mod_to_13h 
    ; Сохранение текущего режима и активной страницы
    mov ah, 0Fh
    int 10h
    
    mov [prev_mode], al
    mov [prev_page], bh
    
    ; Установка видеорежима 13h 
    mov ax, 13h
    int 10h
    
    ; Установка активной страницы 0
    mov ah, 5
    mov al, 0
    int 10h
    
    ; Настройка ES на сегмент видеопамяти
    push 0A000h
    pop es
    
    ret
endp

; Восстановление исходного видеорежима
proc restore_video_mod
    ; Восстановление предыдущего видеорежима
    mov al, [prev_mode]
    mov ah, 0
    int 10h

    ; Восстановление активной страницы
    mov ah, 5
    mov al, [prev_page]
    int 10h
    ret
endp