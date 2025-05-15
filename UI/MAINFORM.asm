; Панель управления (верхняя)
struct PanelControl Panel
	lb_mines Label
	lb_timer Label
	bt_exit  Button
ends

; Панель поля (нижняя), содержит сетку и функцию центрирования
struct PanelField Panel
	gr_field Grid
	centralize_grid dw ?
ends

; Главная форма игры
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
bt_ex_x = pn_up_x + 308 - 33 
bt_ex_y = lb_t_y

pn_fl_x = 2 + inner_x
pn_fl_y = 33 + inner_y
gr_fl_x = 1 + pn_fl_x
gr_fl_y = 1 + pn_fl_y

fm_main FormMain \
	x, y, SCR_W, SCR_H, CL_GREY_1, \
	bw, CL_GREY_1, auto_draw_form, \
	<pn_up_x, pn_up_y, 308, 29, CL_GREY_1, FRM_REV, auto_draw_panel, \
	<lb_m_x, lb_m_y, 20, 11, CL_BLACK, FRM_REV, str_mines_amount, CL_RED_1, auto_draw_label>, \
	<lb_t_x, lb_t_y, 26, 11, CL_BLACK, FRM_REV, str_timer, CL_BLUE_1, auto_draw_label>, \
	<bt_ex_x, bt_ex_y, 30, STD_LBL_H, CL_GREY_1, FRM_STD, str_exit, CL_CYAN_0, BTN_NORM, auto_draw_button, fm_main_exit_button_click>>, \
	<pn_fl_x, pn_fl_y, 308, 157, CL_GREY_1, FRM_REV, auto_draw_panel, \
	<gr_fl_x, gr_fl_y, 308, 157, CL_GREY_0, FRM_REV, COLS, ROWS, NONE, \
	auto_resize, auto_draw_grid, auto_draw_cell,auto_fill_grid, fm_main_grid_button_click>, auto_centralize>
	
fm_main_clickables:
	db 2
	Clickable fm_main.pn_control.bt_exit.x, fm_main.pn_control.bt_exit.y, \
	fm_main.pn_control.bt_exit.w, fm_main.pn_control.bt_exit.h, \
	fm_main.pn_control.bt_exit.on_click
	
	Clickable fm_main.pn_field.gr_field.x, fm_main.pn_field.gr_field.y, \
	fm_main.pn_field.gr_field.w, fm_main.pn_field.gr_field.h, \
	fm_main.pn_field.gr_field.on_click