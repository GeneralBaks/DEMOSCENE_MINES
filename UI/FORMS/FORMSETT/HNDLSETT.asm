proc difficulty_button_click \
    cols, rows, mines
    
    test [mouse_button],BTN_LEFT
    _if zf == 1 jmp .end_proc 
    stdcall set_to_default_bt_reset
    stdcall clear_matrix, field_matrix
    stdcall update_field_matrix, [cols],[rows],[mines]
    stdcall word_to_str, [mines],str_mines_num
    
    stdcall reset_timer
    
    mov [active_form_index],ACTIVE_MAIN
    stdcall restore_cursor_background, [cursor_x],[cursor_y]
    stdcall draw_fm_main
    stdcall save_cursor_background, [cursor_x],[cursor_y]
    stdcall draw_cursor, [cursor_x],[cursor_y]
    
.end_proc:
    ret
endp

proc fm_options_easy_button_click
    stdcall difficulty_button_click, EASY_COLS, EASY_ROWS, EASY_MINES
    ret
endp

proc fm_options_medium_button_click
    stdcall difficulty_button_click, MEDIUM_COLS, MEDIUM_ROWS, MEDIUM_MINES
    ret
endp

proc fm_options_hard_button_click
    stdcall difficulty_button_click, HARD_COLS, HARD_ROWS, HARD_MINES
    ret
endp

proc fm_options_custom_button_click
    test [mouse_button],BTN_LEFT
    _if zf == 0 
        mov [active_form_index],ACTIVE_CUSTOM_OPTIONS
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_fm_custom_options
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]
    _end
    ret
endp

proc fm_options_back_button_click
    test [mouse_button],BTN_LEFT
    _if zf == 0 
        mov [active_form_index],ACTIVE_MAIN
        stdcall restore_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_fm_main
        stdcall save_cursor_background, [cursor_x],[cursor_y]
        stdcall draw_cursor, [cursor_x],[cursor_y]
    _end
    ret
endp