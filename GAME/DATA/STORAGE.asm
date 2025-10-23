mines_left db MAX_MINES
save_cells_left dw MAX_COLS * MAX_ROWS - MAX_MINES

game_state db GAME_WAIT
rand_prev dw ?

field_matrix: 
    .cols db MAX_COLS
    .rows db MAX_ROWS
    .mines_total db MAX_MINES
    .size dw MAX_COLS * MAX_ROWS
    .elements db MAX_COLS * MAX_ROWS dup(?)