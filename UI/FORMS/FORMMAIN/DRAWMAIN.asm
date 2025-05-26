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