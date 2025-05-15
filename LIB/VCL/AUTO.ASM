proc auto_centralize \
		_panel_
	mov si,[_panel_] ;panel_x, panel_y, panel_w, panel_h, cols, rows, cell_size	
	stdcall centralize_cord, [si], [si+2], [si+4], [si+6], \
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
	stdcall draw_string, [bx],[bx+2],[bx+4],[bx+6]
	ret
endp

proc auto_draw_button \
	_button_
	mov bx,[_button_]
	stdcall auto_draw_panel, bx
	mov bx,[_button_]
	mov ax,[bx]
	add ax,2
	mov cx,[bx+2]
	add cx,2
	stdcall draw_string, ax,cx,[bx+12],[bx+14]
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
	stdcall draw_grid, [bx], [bx+2], [bx+12], [bx+14], [bx+16]
	ret
endp	

proc auto_draw_panel \
		_panel_
	mov bx,[_panel_]    ;x,   y,     w,     h,    color, frm_cond   
	stdcall draw_panel, [bx],[bx+2],[bx+4],[bx+6],[bx+8],[bx+10]
	ret
endp

proc auto_draw_form \
		_form_
	mov bx,[_form_]	   ;x,  y,     w,     h,    back_col, bw, board_col
	stdcall draw_form, [bx],[bx+2],[bx+4],[bx+6],[bx+8],[bx+10],[bx+12]
	ret
endp

proc auto_draw_label \
		_label_
	mov bx,[_label_]	;x, y, w, h, back_color, frm_cond, string, string_color 
	stdcall draw_label, [bx],[bx+2],[bx+4],[bx+6],[bx+8],[bx+10],[bx+12],[bx+14]
	ret
endp

proc auto_draw_cell \
		_grid_, col, row, state
	mov bx,[_grid_]    ;x, y, size
	mov ax,[bx]
	mov cx,[bx+2]
	
	mov cx,[bx+16]
	mov ax,[col]
	dec ax
	mul cx
	imul dx,[col],1
	add ax,dx
	
	push ax
	
	mov ax,[row]
	dec ax
	mul cx
	imul dx,[row],1
	add ax,dx
	
	mov dx,[bx+2]
	add dx,ax
	
	pop ax
	mov cx,[bx]
	add cx,ax
	
	_switch [state]
	_case CELL_HIDDEN
		stdcall draw_cell, cx,dx,[bx+16]
	_case CELL_OPENED
		stdcall draw_rect, cx,dx,[bx+16],[bx+16],CL_GREY_0 
	_end
	
	ret
endp

proc auto_fill_grid \
	_grid_
	mov bx,[_grid_]
	_for ax=[bx+14] downto 1
		_for cx=[bx+12] downto 1
			push ax cx bx
			stdcall auto_draw_cell, bx,cx,ax,CELL_HIDDEN 
			pop bx cx ax
		_end
	_end
	ret
endp