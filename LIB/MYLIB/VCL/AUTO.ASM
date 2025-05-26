proc auto_draw_string \
	_component_
	mov bx,[_component_] ;x, y, string, color
	_calc_offset [bx],[bx+2],ax
	stdcall draw_string, ax,[bx+4],[bx+6]
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


proc auto_copy_str \
	src_str, dst_str
	_set_seg es to ds
	stdcall arr_len, [src_str]
	mov dx,cx
	stdcall arr_len, [dst_str]
	_if dx > cx
		mov cx,dx
	_end
	stdcall copy_str, [src_str],[dst_str],cx
	_unset_seg
	ret
endp