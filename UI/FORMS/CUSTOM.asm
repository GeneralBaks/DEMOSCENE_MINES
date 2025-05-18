struct FormCustomOptions Form
	lb_cols Label
	lb_rows Label
	lb_mines Label
	bt_back Button
	
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

bt_x = lb_cols_x
bt_y = 26 + STD_LBL_HT + lb_mines_y

fm_custom_options FormCustomOptions \ 
	x, y, 90, 100, CL_GREY_0, \
	bw, 22h, auto_draw_form, \
	<lb_cols_x, lb_cols_y, 16, STD_LBL_HT, NONE, NONE, str_cols, 07h, draw_label>, \
	<lb_rows_x, lb_rows_y, 23, STD_LBL_HT, NONE, NONE, str_rows, 07h, draw_label>, \
	<lb_mines_x, lb_mines_y, 16, STD_LBL_HT, NONE, NONE, str_mines, 07h, draw_label>, \
	<bt_back_x, bt_back_y, 56, STD_LBL_HT, CL_GREY_1, FRM_STD, str_back, CL_BLACK, BTN_NORM, auto_draw_button, fm_custom_options_back_button_click>, \
	<ed_cols_x, ed_cols_y, 23, STD_LBL_HT, CL_WHITE_1, FRM_REV, str_ed_cols, CL_BLACK, draw_label>, \
	<ed_rows_x, ed_rows_y, 23, STD_LBL_HT, CL_WHITE_1, FRM_REV, str_ed_rows, CL_BLACK, draw_label>, \
	<ed_mines_x, ed_mines_y, 23, STD_LBL_HT, CL_WHITE_1, FRM_REV, str_ed_mines, CL_BLACK, draw_label>
	
	fm_cutom_options_cklickables:
		db 1
		
		Clickable fm_custom_options.bt_back.x, fm_custom_options.bt_back.y, \
		fm_custom_options.bt_back.wt, fm_custom_options.bt_back.ht, \
		fm_custom_options.bt_back.on_click