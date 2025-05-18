proc auto_centralize \
		_panel_
	mov si,[_panel_] ;panel_x, panel_y, panel_w, panel_h, cols, rows, cell_size	
	stdcall centralize_grid_cord, [si], [si+2], [si+4], [si+6], \
		[si+26], [si+28], [si+30]

	add si,14
	mov [si],ax
	mov [si+2],cx
	mov [si+4],dx
	mov [si+6],bx
	
	ret	
endp

proc auto_draw_string \
	_component_
	mov bx,[_component_] ;x, y, string, color
	_calc_offset [bx],[bx+2],ax
	stdcall draw_string, ax,[bx+4],[bx+6]
	ret
endp

proc auto_draw_button \
	_button_
	mov bx,[_button_]
	stdcall auto_draw_panel, bx
	mov bx,[_button_] 
	
	mov dx,[bx+12]
	_set_seg es to ds
	stdcall arr_len, dx
	_unset_seg
	
	mov ax,cx
	mov dx,5
	mul dx
	dec cx
	imul cx,2
	add ax,cx
	
	mov cx,[bx]
	inc cx
	mov dx,[bx+4]
	sub dx,2
	
	stdcall centralize_cord, cx,dx,ax
	
	mov cx,[bx+2]
	add cx,2
	_calc_offset ax,cx,dx	
	stdcall draw_string, dx,[bx+12],[bx+14]
	ret
endp

proc auto_resize \
		_grid_
	mov bx,[_grid_]
	stdcall change_cell_size, [bx+12],[bx+14],[bx+16]
	mov [bx+16],ax
	ret
endp 
	
proc auto_draw_grid \
		_grid_
	mov bx,[_grid_]   
	_calc_offset [bx],[bx+2],ax	
	stdcall draw_grid, ax,[bx+12],[bx+14],[bx+16]
	ret
endp	

proc auto_draw_panel \
		_panel_
	mov bx,[_panel_]    ;x,   y,     w,     h,    color, frm_cond   
	_calc_offset [bx],[bx+2],ax
	stdcall draw_panel, ax,[bx+4],[bx+6],[bx+8],[bx+10]
	ret
endp

proc auto_draw_form \
		_form_
	mov bx,[_form_]	   ;x,  y,     w,     h,    back_col, bw, board_col
	_calc_offset [bx],[bx+2],ax
	stdcall draw_form, ax,[bx+4],[bx+6],[bx+8],[bx+10],[bx+12]
	ret
endp

proc auto_draw_cell \
		_grid_, col_0, row_0, state
	mov bx,[_grid_]    
						;здесь у столбца и строки индексация начинается с 0
	mov cx,[bx+16]		;cx = cell_size
	inc cx			    ;cell_size + 1 для учёта разделителя 
	 
	mov ax,[bx]			;ax = grid.x
	mov dx,[col_0]		;dx = cur_col
	imul dx,cx  		;dx(shift) = cur_col  * (cell_size + 1)
	add ax,dx			;cell_x = grid.x + shift
	
	push ax
	
	mov ax,[bx+2]       ;ax = grid.y
	mov dx,[row_0]      ;dx = cur_row
	imul dx,cx          ;dx(shift) = cur_row  * (cell_size + 1)
	add ax,dx           ;cell_y = grid.y + shift	
	
	pop cx
	
	_calc_offset cx,ax,dx

	_switch byte[state]
	_case CELL_HIDDEN
		stdcall draw_cell, dx,[bx+16]
	_case CELL_OPENED
		stdcall draw_rect, dx,[bx+16],[bx+16],CL_GREY_0 
	_end
	
	ret
endp

proc auto_fill_grid uses si di, \
	grid,mtrx ;_grid_, col, row, state
	mov bx,[grid]
	mov si,[mtrx]
	add si,6
	
	_calc_offset [bx],[bx+2],di
	
	_loop [bx+14]
		_loop [bx+12]
			push cx
			_switch byte[si]
			_case CELL_HIDDEN
				stdcall draw_cell, di,[bx+16]
			_case CELL_OPENED
				stdcall draw_rect, di,[bx+16],[bx+16],CL_GREY_0 
			_end
			add di,[bx+16]
			inc di
			inc si
			pop cx
		_end
		imul ax,[bx+16],SCR_W
		add di,ax
		add di,SCR_W
		sub di,[bx+4]
	_end
	ret
endp

