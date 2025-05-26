proc is_time_changed

	mov ah,2Ch
	int 21h

	_if byte[sys_sec_time] ~= dh
		mov byte[sys_sec_time],dh
	_end
	setne ah
	
	ret
endp

proc draw_cur_time \
	string, label
	stdcall word_to_str_time, [game_time],[string]
	stdcall draw_label, [label]
	ret
endp

proc update_timer \
	label
	
	stdcall is_time_changed
	_if ah == 1
		inc word[game_time]
		stdcall draw_cur_time, str_timer,[label]
	_end
	
	ret
endp

proc reset_timer

	mov byte[game_state],GAME_WAIT
	mov word[game_time],0
	
	mov bx,str_timer
	mov byte[bx],'0'
	mov byte[bx+1],'0'
	mov byte[bx+2],'0'
	
	ret
endp