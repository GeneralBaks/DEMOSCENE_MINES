struct PanelControl Panel
	lb_mines   Label
	lb_timer   Label
	bt_exit    Button
	bt_options Button
	bt_reset Button
ends

struct PanelField Panel
	gr_field Grid
	centralize_grid dw ?
ends

struct FormMain Form
	pn_control PanelControl
	pn_field PanelField
ends

_generate_cord 0:0:2
pn_up_x = 2 + inner_x
pn_up_y = 2 + inner_y

lb_m_x = 2 + pn_up_x
lb_m_y = 2 + pn_up_y  
lb_t_x = 2 + pn_up_x
lb_t_y = 16 + pn_up_y
 
bt_ex_x = pn_up_x + 308 - 54 
bt_ex_y = lb_t_y

bt_op_x = pn_up_x + 308 - 54
bt_op_y = lb_m_y

pn_fl_x = 2 + inner_x
pn_fl_y = 33 + inner_y
gr_fl_x = 1 + pn_fl_x
gr_fl_y = 1 + pn_fl_y

fm_main FormMain \
	x, y, SCR_W, SCR_H, CL_GREY_0, \
	bw, 35h, auto_draw_form, \
	<pn_up_x, pn_up_y, 308, 29, CL_GREY_1, FRM_REV, auto_draw_panel, \
	<lb_m_x, lb_m_y, 16, 11, CL_BLACK, FRM_REV, str_mines_num, CL_RED_1, draw_label>, \
	<lb_t_x, lb_t_y, 23, 11, CL_BLACK, FRM_REV, str_timer, CL_BLUE_1, draw_label>, \
	<bt_ex_x, bt_ex_y, 51, STD_LBL_HT, CL_GREY_1, FRM_STD, str_exit, CL_BLACK, BTN_NORM, draw_button, fm_main_exit_button_click>, \
	<bt_op_x,bt_op_y, 51, STD_LBL_HT, CL_GREY_1, FRM_STD, str_options, CL_BLACK, BTN_NORM, draw_button, fm_main_options_button_click>, \
	<NONE, NONE, 58, STD_LBL_HT, CL_GREY_1, FRM_STD, str_reset, CL_BLACK, BTN_NORM, draw_button, fm_main_reset_button_click>>, \
	<pn_fl_x, pn_fl_y, 308, 157, CL_GREY_1, FRM_REV, auto_draw_panel, \
	<gr_fl_x, gr_fl_y, 308, 157, CL_GREY_0, FRM_REV, MAX_COLS, MAX_ROWS, NONE, \
	change_cell_size, draw_grid, open_cells, fill_grid, update_grid_dimensions, fm_main_grid_button_click>, centralize_grid_cord>
	
fm_main_clickables:
	db 4
	Clickable fm_main.pn_control.bt_exit.x, fm_main.pn_control.bt_exit.y, \
	fm_main.pn_control.bt_exit.wt, fm_main.pn_control.bt_exit.ht, \
	fm_main.pn_control.bt_exit.on_click
	
	Clickable fm_main.pn_field.gr_field.x, fm_main.pn_field.gr_field.y, \
	fm_main.pn_field.gr_field.wt, fm_main.pn_field.gr_field.ht, \
	fm_main.pn_field.gr_field.on_click
	
	Clickable fm_main.pn_control.bt_options.x,fm_main.pn_control.bt_options.y, \
	fm_main.pn_control.bt_options.wt, fm_main.pn_control.bt_options.ht, \
	fm_main.pn_control.bt_options.on_click
	
	Clickable fm_main.pn_control.bt_reset.x, fm_main.pn_control.bt_reset.y, \
	fm_main.pn_control.bt_reset.wt, fm_main.pn_control.bt_reset.ht, \
	fm_main.pn_control.bt_reset.on_click