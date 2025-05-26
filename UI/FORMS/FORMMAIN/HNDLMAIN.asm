proc fm_main_exit_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		stdcall draw_fm_exit
		mov [active_form_index], ACTIVE_EXIT
	_end
	ret
endp

proc reset_field
	movzx ax,[field_matrix.mines_total]
	mov [mines_left],al
	
	mov dx,[field_matrix.size]
	sub dx,ax
	mov [save_cells_left],dx
	
	stdcall word_to_str, ax,str_mines_num
	_mcall field_matrix:clear
	ret
endp

proc fm_main_reset_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		stdcall restore_cursor_background, [cursor_x],[cursor_y]
		stdcall set_to_default_bt_reset
		stdcall save_cursor_background, [cursor_x],[cursor_y]
		stdcall draw_cursor, [cursor_x],[cursor_y]
		
		mov [game_state], GAME_WAIT
		
		stdcall reset_field
		stdcall reset_timer
		
		_mcall fm_main.pn_control.lb_timer:draw
		_mcall fm_main.pn_control.lb_mines:draw
		_mcall fm_main.pn_field.gr_field:draw
		_mcall fm_main.pn_field.gr_field:fill_grid, <field_matrix>
	_end
	ret
endp

proc set_to_default_bt_reset
	_if byte[game_state] == GAME_WIN
		stdcall change_br_reset_to_normal
		_mcall fm_main.pn_control.bt_reset:draw
	_elseif byte[game_state] == GAME_LOSE
		stdcall change_br_reset_to_normal
		_mcall fm_main.pn_control.bt_reset:draw
	_end	
	ret
endp

proc find_clicked_cell \
	grid
	mov bx,[grid]
	mov ax,[bx]
	mov dx,[bx+2]
	_loop [bx+14]
		_loop [bx+12]
			push ax dx
			
			_if [cursor_x] < ax jmp .skip
			_if [cursor_y] < dx jmp .skip
			
			add ax,[bx+16]
			_if [cursor_x] > ax jmp .skip
			
			add dx,[bx+16]
			_if [cursor_y] > dx jmp .skip
			
			pop dx ax
			
			mov ax,[bx+12]
			sub ax,cx
			inc ax
			
			mov dx,[bx+14]
			pop cx
			sub dx,cx
			inc dx
			jmp .end_proc
			
			.skip:
			pop dx ax
			add ax,[bx+16]
			inc ax
		_end
		sub ax,[bx+4]
		
		add dx,[bx+16]
		inc dx
	_end
.end_proc:	
	ret
endp

proc fm_main_grid_button_click
	stdcall find_clicked_cell, fm_main.pn_field.gr_field
	_if cx == 0 jmp .end_proc
	_if [game_state] == GAME_WIN jmp .end_proc
	_if [game_state] == GAME_LOSE jmp .end_proc

	dec ax     ; ax = col (0-based)
	dec dx     ; dx = row (0-based)
	stdcall restore_cursor_background, [cursor_x],[cursor_y]
	_if byte[mouse_button] == BTN_LEFT
		; Переводим в 0-based индексы
		push ax dx
		_if [game_state] == GAME_WAIT
			mov byte[game_state],GAME_PLAY
			stdcall generate_mines, field_matrix,ax,dx,[rand_prev]
		_end
		pop dx ax
		_mcall fm_main.pn_field.gr_field:open_cell, <field_matrix,ax,dx>
	_elseif byte[mouse_button] == BTN_RIGHT
		stdcall set_cell_char, fm_main.pn_field.gr_field,field_matrix,ax,dx 
	_end
	
	_if byte[game_state] == GAME_WIN
		stdcall change_br_reset_to_win
		_mcall fm_main.pn_control.bt_reset:draw
	_elseif byte[game_state] == GAME_LOSE
		stdcall change_br_reset_to_lose
		_mcall fm_main.pn_control.bt_reset:draw
		_mcall fm_main.pn_field.gr_field:fill_grid, <field_matrix>
	_end
	stdcall save_cursor_background, [cursor_x],[cursor_y]
	stdcall draw_cursor, [cursor_x],[cursor_y]
		
.end_proc:
    ret
endp

proc change_br_reset_to_win
	mov word[fm_main.pn_control.bt_reset.color],CL_GREEN_0
	mov word[fm_main.pn_control.bt_reset.text],str_win
	mov word[fm_main.pn_control.bt_reset.frame],CL_GOLD
	ret
endp

proc change_br_reset_to_lose
	mov word[fm_main.pn_control.bt_reset.color],CL_RED_0
	mov word[fm_main.pn_control.bt_reset.text],str_lose
	mov word[fm_main.pn_control.bt_reset.frame],CL_BLACK
	ret
endp

proc change_br_reset_to_normal
	mov word[fm_main.pn_control.bt_reset.color],CL_GREY_1
	mov word[fm_main.pn_control.bt_reset.text],str_reset
	mov word[fm_main.pn_control.bt_reset.frame],FRM_STD
	ret
endp

proc fm_main_options_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		stdcall draw_fm_options
		mov [active_form_index], ACTIVE_OPTIONS
	_end
	ret
endp

 