; Форма подтверждения выхода
struct FormOptions Form
	lb_confirm Label
	bt_yes Button
	bt_no Button 
ends

;_generate_cord (SCR_W - 81) / 2: (SCR_H - 60) / 2 : 5
;lb_x = 1 + inner_x
;lb_y = 5 + inner_y
;bt_yes_x = 5 + inner_x 
;bt_yes_y = 20 + inner_y
;bt_no_x = 11 + bt_yes_x + 23 
;bt_no_y = 20 + inner_y 

;fm_exit FormExit \
;	x, y, 81, 50, CL_GREY_0, \
;	bw, CL_RED_1, auto_draw_form, \
;	<lb_x, lb_y, 65, STD_LBL_H, CL_BLACK, FRM_REV, str_exit_confirm, CL_CYAN_1, auto_draw_label>, \
;	<bt_yes_x, bt_yes_y, 23, STD_LBL_H, CL_GREY_1, FRM_STD, str_exit_yes, CL_CYAN_0, BTN_NORM, auto_draw_button,fm_exit_yes_button_click>, \
;	<bt_no_x, bt_no_y, 23, STD_LBL_H, CL_GREY_1, FRM_STD, str_exit_no, CL_CYAN_0, BTN_NORM, auto_draw_button,fm_exit_no_button_click>
;	
;fm_exit_clickables:
;	db 2
;	Clickable fm_exit.bt_yes.x, fm_exit.bt_yes.y, \
;	fm_exit.bt_yes.w, fm_exit.bt_yes.h, fm_exit.bt_yes.on_click 
;	
;	Clickable fm_exit.bt_no.x, fm_exit.bt_no.y, \
;	fm_exit.bt_no.w, fm_exit.bt_no.h, fm_exit.bt_no.on_click 