proc keyboard_handle
	mov ax,0C06h
	mov dl,0FFh
	int 21h
	
	_if al == 27 
		mov al,GAME_EXIT
		mov [game_state],al
	_end
	ret
endp