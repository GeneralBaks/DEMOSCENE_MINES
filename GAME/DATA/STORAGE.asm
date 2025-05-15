field_matrix: 
	.cols dw COLS
	.rows dw ROWS
    .size dw COLS * ROWS
	.elements db COLS * ROWS dup(0)
	
arr_cursor_back array CURSOR_SIZE * CURSOR_SIZE

timer dw 0
mines_amount dw ?

game_state db 0