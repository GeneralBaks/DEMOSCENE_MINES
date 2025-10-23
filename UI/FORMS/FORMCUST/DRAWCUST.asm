proc draw_fm_custom_options
    _mcall fm_custom_options:draw
    _mcall fm_custom_options.lb_cols:draw
    _mcall fm_custom_options.lb_rows:draw
    _mcall fm_custom_options.lb_mines:draw
    
    _mcall fm_custom_options.bt_back:draw
    _mcall fm_custom_options.bt_ok:draw
    
    _mcall fm_custom_options.ed_cols:draw
    _mcall fm_custom_options.ed_rows:draw
    _mcall fm_custom_options.ed_mines:draw
    ret
endp
