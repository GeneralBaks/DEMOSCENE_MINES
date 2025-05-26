; ÷ентрирование пол€ по центру панели
proc centralize_grid_cord \
	panel
;		panel_x[bx], panel_y[bx+2], panel_wt[bx+4], panel_ht[bx+6]
;		cols[bx+26], rows[bx+28], cell_size[bx+30]
		
	locals
		new_grid_x dw ?
		new_grid_y dw ?
		new_grid_wt dw ?
		new_grid_ht dw ?
	endl
	
	mov bx,[panel]
	
	mov ax,[bx+30]
	imul ax,[bx+26]
	add ax,[bx+26]
	mov [new_grid_wt],ax
	
	mov ax,[bx+4]
	sub ax,[new_grid_wt]
	shr ax,1
	add ax,5
	inc ax
	mov [new_grid_x],ax
	
	mov ax,[bx+30]
	imul ax,[bx+28]
	add ax,[bx+28]
	inc ax
	mov [new_grid_ht],ax
	
	mov ax,[bx+6]
	sub ax,[new_grid_ht]
	shr ax,1
	add ax,[bx+2]
	inc ax
	mov [new_grid_y],ax
	
	mov ax,[new_grid_x]
	mov cx,[new_grid_y]
	mov dx,[new_grid_wt]
	
	add bx,14
	mov [bx],ax
	mov [bx+2],cx
	mov [bx+4],dx
	
	mov ax,[new_grid_ht]
	mov [bx+6],ax
	
	ret
endp

; јвтоматический подбор размера клетки под количество €чеек
proc change_cell_size \
	grid
		
	mov bx,[grid]
	
	mov ax,13
	_if word[bx+12] > 28
		mov ax,7
	_elseif word[bx+12] > 21
		mov ax,10
	_end
	
	mov dx,13
	_if word[bx+14] > 14
		mov dx,7
	_elseif word[bx+14] > 9
		mov dx,10
	_end
	
	_if ax > dx
		mov ax,dx 
	_end
	
	mov word[bx+16],ax
	
	ret
endp

; обновление строк и столбцов
proc update_grid_dimensions \
	grid, new_cols:byte, new_rows:byte
	mov bx,[grid]
	mov al,[new_cols]
	mov ah,[new_rows]
	mov [bx+12],al
	mov [bx+14],ah
	ret
endp

;очистка матрицы (заполн€ем нул€ми)
proc clear_matrix \
	mtrx
	mov bx,[mtrx]
	mov ax,[bx+3]
	inc ax
	add bx,5
	
	_set_seg es to ds
	stdcall clr_arr, bx,ax
	_unset_seg
	
	ret
endp

proc update_field_matrix \
	cols:byte, rows:byte, mines:byte
	mov al,[cols]
	mov ah,[rows]
	mov byte[fm_main.pn_field.gr_field.cols],al
	mov [field_matrix.cols],al
	mov byte[fm_main.pn_field.gr_field.rows],ah
	mov [field_matrix.rows],ah
	
	mul ah
	mov [field_matrix.size],ax
	movzx dx,[mines]
	sub ax,dx
	mov [save_cells_left],ax
	
	mov [field_matrix.mines_total],dl
	mov [mines_left],dl
	
	ret
endp