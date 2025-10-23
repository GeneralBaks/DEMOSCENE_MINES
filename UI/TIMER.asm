; Проверка, изменилась ли текущая секунда системного времени
proc is_time_changed
    mov ah,2Ch                ; Получить системное время (INT 21h, AH=2Ch)
    int 21h

    _if byte[sys_sec_time] ~= dh    ; Если секунда изменилась
        mov byte[sys_sec_time],dh   ; Обновить сохранённую секунду
    _end							
    setne ah                  ; AH = 1, если время изменилось; 0 — если нет

    ret
endp

; Отображение текущего времени игры
proc draw_cur_time \
    string, label
    stdcall word_to_str_time, [game_time], [string]  ; Преобразовать время в строку
    stdcall draw_label, [label]                      ; Отрисовать метку
    ret
endp

; Обновление таймера игры (раз в секунду)
proc update_timer \
    label

    stdcall is_time_changed          ; Проверка, изменилась ли секунда
    _if ah == 1                      ; Если да — обновить таймер
        inc word[game_time]         ; Увеличить игровое время
        stdcall draw_cur_time, str_timer, [label]  ; Перерисовать метку времени
    _end

    ret
endp

; Сброс игрового таймера и установка начального состояния
proc reset_timer
    mov byte[game_state], GAME_WAIT ; Установить состояние ожидания
    mov word[game_time], 0          ; Обнулить игровое время

    ; Обнулить строку отображения времени: "000"
    mov bx, str_timer
    mov byte[bx], '0'
    mov byte[bx+1], '0'
    mov byte[bx+2], '0'

    ret
endp
