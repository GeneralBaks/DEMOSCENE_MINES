proc clear_field
	_set_seg es to ds ; переходим в сегмент с полем
	
	_unset_seg
	ret
endp
; расстановка мин на поле
proc generate_field uses si di bx \
			first_x, first_y

        ; Занулить поле
        mov     di, Field.elements
        mov     cx, [Field.size]
        xor     al, al
        rep     stosb

        ; Вычисляем индекс первой клетки
        mov     ax, firstY
        dec     ax
        mul     [Field.cols]
        add     ax, firstX
        dec     ax
        mov     si, ax              ; SI = запрещенный индекс

        ; Установка счетчика мин
        mov     di, mine_count      ; DI = оставшиеся мины

.loop_mine:
        ; Генерируем случайный индекс
        push    0                   ; min = 0
        push    [Field.size]        ; max = размер поля
        call    random_get
        add     sp, 4

        ; Проверка на запрещенную клетку
        cmp     ax, si
        je      .loop_mine

        ; Проверяем наличие мины
        mov     bx, ax
        cmp     [Field.elements + bx], CELL_HIDDEN
        jne     .loop_mine

        ; Устанавливаем мину
        mov     [Field.elements + bx], CELL_EXPLODED ; Помечаем мину
        dec     di
        jnz     .loop_mine
	ret
endp

;field_matrix.size
;field_matrix.mines_amount