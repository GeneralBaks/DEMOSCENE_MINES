; Центрирование поля по центру панели
proc centralize_cord \
		panel_x, panel_y, panel_w, panel_h, \
		cols, rows, cell_size
		
	locals
		new_grid_x dw ?
		new_grid_y dw ?
		new_grid_w dw ?
		new_grid_h dw ?
	endl
		
	mov ax,[cell_size]
	imul ax,[cols]
	add ax,[cols]
	mov [new_grid_w],ax
	
	mov ax,[panel_w]
	sub ax,[new_grid_w]
	shr ax,1
	add ax,5
	
	mov [new_grid_x],ax
	
	mov ax,[cell_size]
	imul ax,[rows]
	add ax,[rows]
	mov [new_grid_h],ax
	
	mov ax,[panel_h]
	sub ax,[new_grid_h]
	shr ax,1
	add ax,[panel_y]
	
	mov [new_grid_y],ax
	
	mov ax,[new_grid_x]
	mov cx,[new_grid_y]
	mov dx,[new_grid_w]
	mov bx,[new_grid_h]
	
	ret
endp

; Автоматический подбор размера клетки под количество ячеек
proc change_cell_size \
		cols, rows, cell_size
		
	mov ax,13
	_if [cols] > 28
		mov ax,7
	_elseif [cols] > 21
		mov ax,10
	_end
	
	mov dx,13
	_if [rows] > 14
		mov dx,7
	_elseif [rows] > 9
		mov dx,10
	_end
	
	_if ax > dx
		mov ax,dx 
	_end
	
	ret
endp