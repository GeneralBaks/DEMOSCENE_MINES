; Центрирование поля по центру панели
proc centralize_grid_cord \
		panel_x, panel_y, panel_wt, panel_ht, \
		cols, rows, cell_size
		
	locals
		new_grid_x dw ?
		new_grid_y dw ?
		new_grid_wt dw ?
		new_grid_ht dw ?
	endl
		
	mov ax,[cell_size]
	imul ax,[cols]
	add ax,[cols]
	mov [new_grid_wt],ax
	
	mov ax,[panel_wt]
	sub ax,[new_grid_wt]
	shr ax,1
	add ax,5
	inc ax
	mov [new_grid_x],ax
	
	mov ax,[cell_size]
	imul ax,[rows]
	add ax,[rows]
	inc ax
	mov [new_grid_ht],ax
	
	mov ax,[panel_ht]
	sub ax,[new_grid_ht]
	shr ax,1
	add ax,[panel_y]
	inc ax
	mov [new_grid_y],ax
	
	mov ax,[new_grid_x]
	mov cx,[new_grid_y]
	mov dx,[new_grid_wt]
	mov bx,[new_grid_ht]
	
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