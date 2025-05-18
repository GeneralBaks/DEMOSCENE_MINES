proc get_time

	mov ah,2Ch
	int 21h
	
	movzx ax,dh
	movzx dx,cl
	imul dx,59
	add ax,dx
	
	ret
endp

proc get_cur_time 
	
	stdcall get_time
	mov dx,[cur_time]
	mov [prev_time],dx
	sub ax,[start_time]
	mov [cur_time],ax
	
	ret
endp

proc get_start_time 

	stdcall get_time
	mov [start_time],ax
	mov [prev_time],0
	mov [cur_time],0
	
	ret
endp

proc draw_cur_time \
	string, label
	stdcall word_to_str_time, [cur_time],[string]
	mov bx,[label]
	mov ax,[string]
	mov [bx+12],ax		
	stdcall draw_label, [label]
	ret
endp

proc update_timer \
	label
	
	stdcall get_cur_time
	_if ax ~= [prev_time]
		stdcall draw_cur_time, str_timer,[label]
	_end
	
	ret
endp

proc reset_timer

	mov byte[game_state],GAME_WAIT
	stdcall get_start_time
	
	mov bx,str_timer
	mov byte[bx],'0'
	mov byte[bx+1],'0'
	mov byte[bx+2],'0'
	
	ret
endp