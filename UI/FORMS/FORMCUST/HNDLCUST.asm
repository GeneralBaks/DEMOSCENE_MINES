proc check_char
	_if al < '0' jmp  .incorrect
	_if al > '9' jmp  .incorrect
	mov dl,1
	jmp .end_proc
.incorrect:
	mov dl,0
.end_proc:
	ret
endp

proc edit_keyboard_handler uses si, \
	edit, max_len
	mov bx,[edit]
	mov si,[bx+12]
	
	_set_seg es to ds
	stdcall arr_len, si
	_unset_seg
	
	add si,cx
	dec si
	
	_repeat
		_clear dh
		
		mov ah,01h
		int 16h
		
		jz .no_key
		
		mov ah, 00h
		int 16h	
		
		_if al == 0 jmp .no_key
		
		_switch al 
			_case 0Dh
				_break
				
			_case 08h
				_if cx > 0
					mov byte[si],00h
					dec si
					dec cx
					inc dh
				_end
				
			_standart
				_if cx < [max_len]	
				stdcall check_char
					_if dl == 1
						inc si
						mov byte[si],al
						inc cx
						inc dh
					_end
				_end
		_end
		
		_if dh == 1
			push cx
			stdcall word[bx+16], bx
			pop cx
		_end
		.no_key:
	_until al == 0Dh
	ret
endp 

proc edit_cols_on_click 
	stdcall edit_on_click, fm_custom_options.ed_cols,2
	ret
endp

proc edit_rows_on_click
	stdcall edit_on_click, fm_custom_options.ed_rows,2
	ret
endp

proc edit_mines_on_click
	stdcall edit_on_click, fm_custom_options.ed_mines,2
	ret
endp

proc edit_on_click \
	edit, len
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		stdcall restore_cursor_background, [cursor_x],[cursor_y]
		stdcall edit_keyboard_handler, [edit],[len]
		stdcall save_cursor_background, [cursor_x],[cursor_y]
		stdcall draw_cursor, [cursor_x],[cursor_y]
	_end
	ret
endp

proc fm_custom_options_ok_button_click 
	test [mouse_button],BTN_LEFT
	_if zf == 1 jmp .end_proc 
	
		stdcall get_custom_set
		jc .invalid_data
			push ax ax cx dx
			_mcall field_matrix:clear
			pop dx cx ax
			stdcall update_field_matrix, cx,dx,ax
			pop ax
			stdcall word_to_str, ax,str_mines_num
		
		stdcall reset_timer
		.invalid_data:
		mov [active_form_index],ACTIVE_MAIN
		
		stdcall restore_cursor_background, [cursor_x],[cursor_y]
		stdcall draw_fm_main
		stdcall save_cursor_background, [cursor_x],[cursor_y]
		stdcall draw_cursor, [cursor_x],[cursor_y]
		
.end_proc:
	ret
endp

proc get_custom_set	
	locals
		temp_cols db ?
		temp_rows db ?
	endl
	
	_set_seg es to ds
	stdcall arr_len, str_ed_cols
	_unset_seg
	
	stdcall try_str_to_word, str_ed_cols,cx
	_if ax < MIN_COLS jmp .invalid_data
	_if ax > MAX_COLS jmp .invalid_data
	mov [temp_cols],al

	_set_seg es to ds
	stdcall arr_len, str_ed_rows
	_unset_seg
	
	stdcall try_str_to_word, str_ed_rows,cx
	_if ax < MIN_ROWS jmp .invalid_data
	_if ax > MAX_ROWS jmp .invalid_data
	mov [temp_rows],al

	_set_seg es to ds
	stdcall arr_len, str_ed_mines
	_unset_seg
	
	stdcall try_str_to_word, str_ed_mines,cx
	
	movzx dx,[temp_cols]
	movzx cx,[temp_rows]
	imul cx,dx
	
	_if ax < 1 jmp .invalid_data
	_if ax > cx jmp .invalid_data

	movzx cx,[temp_cols]
	movzx dx,[temp_rows]
	
	clc
	jmp .end_proc
.invalid_data:
	stc
.end_proc:	
	ret
endp


proc fm_custom_options_back_button_click
	test [mouse_button],BTN_LEFT
	_if zf == 0 
		mov [active_form_index],ACTIVE_OPTIONS
		stdcall restore_cursor_background, [cursor_x],[cursor_y]
		stdcall draw_fm_options
		stdcall save_cursor_background, [cursor_x],[cursor_y]
		stdcall draw_cursor, [cursor_x],[cursor_y]
	_end
	ret
endp