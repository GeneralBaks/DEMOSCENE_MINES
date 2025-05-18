proc draw_fm_exit
	_mcall fm_exit:draw
    _mcall fm_exit.lb_confirm:draw
	_mcall fm_exit.bt_yes:draw
	_mcall fm_exit.bt_no:draw
	ret
endp

proc draw_fm_main
    _mcall fm_main:draw                     
    _mcall fm_main.pn_control:draw          
    _mcall fm_main.pn_control.lb_mines:draw 
    _mcall fm_main.pn_control.lb_timer:draw 
	_mcall fm_main.pn_control.bt_exit:draw
	_mcall fm_main.pn_control.bt_options:draw
	_mcall fm_main.pn_control.bt_reset:draw

    _mcall fm_main.pn_field.gr_field:resize_cell   
    _mcall fm_main.pn_field:centralize_grid        
    _mcall fm_main.pn_field:draw
    _mcall fm_main.pn_field.gr_field:draw
	_mcall fm_main.pn_field.gr_field:fill_grid, <field_matrix> 
	ret
endp

proc draw_fm_options
	_mcall fm_options:draw
	_mcall fm_options.bt_easy:draw
	_mcall fm_options.bt_medium:draw
	_mcall fm_options.bt_hard:draw
	_mcall fm_options.bt_custom:draw
	_mcall fm_options.bt_back:draw
	ret
endp

proc draw_fm_custom_options
	_mcall fm_custom_options:draw
	_mcall fm_custom_options.lb_cols:draw
	_mcall fm_custom_options.lb_rows:draw
	_mcall fm_custom_options.lb_mines:draw
	_mcall fm_custom_options.bt_back:draw
	_mcall fm_custom_options.ed_cols:draw
	_mcall fm_custom_options.ed_rows:draw
	_mcall fm_custom_options.ed_mines:draw
	ret
endp