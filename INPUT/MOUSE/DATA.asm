cursor_x dw 100    ; Начальная X-позиция курсора 
cursor_y dw 100    ; Начальная Y-позиция курсора 
prev_x   dw 160    ; Предыдущая X-позиция
prev_y   dw 100    ; Предыдущая Y-позиция
cursor_visible db 1 ; Флаг видимости курсора
arr_cursor_back array CURSOR_SIZE * CURSOR_SIZE
mouse_button db 0
prev_button db 0
cursor_dump \
	db 2Bh,10h,10h,10h,10h,10h,10h,10h
	db 10h,0Fh,0Fh,0Fh,0Fh,0Fh,10h
	db 10h,0Fh,0Fh,0Fh,0Fh,10h
	db 10h,0Fh,0Fh,0Fh,10h
	db 10h,0Fh,0Fh,10h
	db 10h,0Fh,10h
	db 10h,10h
	db 10h
	