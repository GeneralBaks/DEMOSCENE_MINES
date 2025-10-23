struct FormCustomOptions Form
	lb_cols Label
	lb_rows Label
	lb_mines Label
	
	bt_back Button
	bt_ok Button
	
	ed_cols Edit
	ed_rows Edit
	ed_mines Edit
ends
_generate_cord (SCR_W - 100) / 2: (SCR_H - 120) / 2 : 5
lb_cols_x = 5 + inner_x 
lb_cols_y = 7 + inner_y

lb_rows_x = lb_cols_x
lb_rows_y = 7 + STD_LBL_HT + lb_cols_y

lb_mines_x = lb_cols_x
lb_mines_y = 7 + STD_LBL_HT + lb_rows_y

ed_cols_x = 46 + inner_x  
ed_cols_y = lb_cols_y - 2

ed_rows_x = ed_cols_x 
ed_rows_y = lb_rows_y - 2

ed_mines_x = ed_rows_x 
ed_mines_y = lb_mines_y - 2

bt_back_x = 15 + 20 + inner_x  
bt_back_y = 10 + STD_LBL_HT + lb_mines_y

bt_ok_x = 5 + inner_x
bt_ok_y = 10 + STD_LBL_HT + lb_mines_y

fm_custom_options FormCustomOptions \ 
    x, y, 90, 100, CL_GREY_0, \
    bw, 22h, auto_draw_form, \
    <lb_cols_x, lb_cols_y, 16, STD_LBL_HT, NONE, NONE, str_cols, 07h, draw_label>, \
    <lb_rows_x, lb_rows_y, 23, STD_LBL_HT, NONE, NONE, str_rows, 07h, draw_label>, \
    <lb_mines_x, lb_mines_y, 16, STD_LBL_HT, NONE, NONE, str_mines, 07h, draw_label>, \
    <bt_back_x, bt_back_y, 34, STD_LBL_HT, CL_GREY_1, FRM_STD, str_back, CL_BLACK, BTN_NORM, draw_button, fm_custom_options_back_button_click>, \
    <bt_ok_x, bt_ok_y, 20, STD_LBL_HT, CL_GREY_1, FRM_STD, str_ok, CL_BLACK, BTN_NORM, draw_button, fm_custom_options_ok_button_click>, \
    <ed_cols_x, ed_cols_y, 23, STD_LBL_HT, CL_WHITE_1, FRM_REV, str_ed_cols, CL_BLACK, draw_label, edit_cols_on_click>, \
    <ed_rows_x, ed_rows_y, 23, STD_LBL_HT, CL_WHITE_1, FRM_REV, str_ed_rows, CL_BLACK, draw_label, edit_rows_on_click>, \
    <ed_mines_x, ed_mines_y, 23, STD_LBL_HT, CL_WHITE_1, FRM_REV, str_ed_mines, CL_BLACK, draw_label, edit_mines_on_click>
    
fm_cutom_options_cklickables:
    db 5
    
    Clickable fm_custom_options.bt_back.x, fm_custom_options.bt_back.y, \
    fm_custom_options.bt_back.wt, fm_custom_options.bt_back.ht, \
    fm_custom_options.bt_back.on_click
    
    Clickable fm_custom_options.bt_ok.x, fm_custom_options.bt_ok.y, \
    fm_custom_options.bt_ok.wt, fm_custom_options.bt_ok.ht, \
    fm_custom_options.bt_ok.on_click
    
    Clickable fm_custom_options.ed_cols.x, fm_custom_options.ed_cols.y, \
    fm_custom_options.ed_cols.wt, fm_custom_options.ed_cols.ht, \
    fm_custom_options.ed_cols.on_click 
    
    Clickable fm_custom_options.ed_rows.x, fm_custom_options.ed_rows.y, \
    fm_custom_options.ed_rows.wt, fm_custom_options.ed_rows.ht, \
    fm_custom_options.ed_rows.on_click 
    
    Clickable fm_custom_options.ed_mines.x, fm_custom_options.ed_mines.y, \
    fm_custom_options.ed_mines.wt, fm_custom_options.ed_mines.ht, \
    fm_custom_options.ed_mines.on_click 