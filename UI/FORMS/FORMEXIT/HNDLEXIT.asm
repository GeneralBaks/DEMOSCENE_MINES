proc fm_exit_yes_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		mov [game_state],GAME_EXIT
	_end
	ret
endp

proc fm_exit_no_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 1 jmp .end_proc 
	
	mov [active_form_index],ACTIVE_MAIN
	stdcall restore_cursor_background, [cursor_x],[cursor_y]
	stdcall draw_fm_main
	stdcall save_cursor_background, [cursor_x],[cursor_y]
	stdcall draw_cursor, [cursor_x],[cursor_y]
	
.end_proc: 
	ret
endp