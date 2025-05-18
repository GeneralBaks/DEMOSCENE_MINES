field_matrix: 
	.cols dw MAX_COLS
	.rows dw MAX_ROWS
    .size dw MAX_COLS * MAX_ROWS
	.elements db MAX_COLS * MAX_ROWS dup(0)

mines_amount dw ?

game_state db GAME_WAIT