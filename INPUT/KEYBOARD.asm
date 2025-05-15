proc keyboard_handle
	mov ax,0C06h
	mov dl,0FFh
	int 21h
	
	_if al == 27 
		mov ax,COMPLETE
	_else
		mov ax,NOT_COMPLETE
	_end
	ret
endp