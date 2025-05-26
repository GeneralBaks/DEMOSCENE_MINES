struct FormOptions Form
	bt_easy Button
	bt_medium Button
	bt_hard Button
	bt_custom Button
	bt_back	Button
ends

_generate_cord (SCR_W - 100) / 2: (SCR_H - 120) / 2 : 5
bt_easy_x = 10 + inner_x 
bt_easy_y = 5 + inner_y

bt_medium_x = bt_easy_x
bt_medium_y = 2 + STD_LBL_HT + bt_easy_y  

bt_hard_x = bt_medium_x
bt_hard_y = 2 + STD_LBL_HT + bt_medium_y 

bt_custom_x = bt_hard_x
bt_custom_y = 2 + STD_LBL_HT + bt_hard_y 

bt_back_x = bt_hard_x
bt_back_y = 10 + STD_LBL_HT + bt_custom_y 


fm_options FormOptions \
	x, y, 90, 100, CL_GREY_0, \
	bw, CL_GREEN_0, auto_draw_form, \
	<bt_easy_x, bt_easy_y, 56, STD_LBL_HT, CL_GREY_1, FRM_STD, str_easy, CL_BLACK, BTN_NORM, draw_button, fm_options_easy_button_click>, \
	<bt_medium_x, bt_medium_y, 56, STD_LBL_HT, CL_GREY_1, FRM_STD, str_medium, CL_BLACK, BTN_NORM, draw_button, fm_options_medium_button_click>, \
	<bt_hard_x, bt_hard_y, 56, STD_LBL_HT, CL_GREY_1, FRM_STD, str_hard, CL_BLACK, BTN_NORM, draw_button, fm_options_hard_button_click>, \
	<bt_custom_x, bt_custom_y, 56, STD_LBL_HT, CL_GREY_1, FRM_STD, str_custom, CL_BLACK, BTN_NORM, draw_button, fm_options_custom_button_click>, \
	<bt_back_x, bt_back_y, 56, STD_LBL_HT, CL_GREY_1, FRM_STD, str_back, CL_BLACK, BTN_NORM, draw_button, fm_options_back_button_click>
	

fm_options_clickables:
	db 5
	Clickable fm_options.bt_easy.x, fm_options.bt_easy.y, \
	fm_options.bt_easy.wt, fm_options.bt_easy.ht, \
	fm_options.bt_easy.on_click
	
	Clickable fm_options.bt_medium.x, fm_options.bt_medium.y, \
	fm_options.bt_medium.wt, fm_options.bt_medium.ht, \
	fm_options.bt_medium.on_click
	
	Clickable fm_options.bt_hard.x, fm_options.bt_hard.y, \
	fm_options.bt_hard.wt, fm_options.bt_hard.ht, \
	fm_options.bt_hard.on_click
	
	Clickable fm_options.bt_custom.x, fm_options.bt_custom.y, \
	fm_options.bt_custom.wt, fm_options.bt_custom.ht, \
	fm_options.bt_custom.on_click
	
	Clickable fm_options.bt_back.x, fm_options.bt_back.y, \
	fm_options.bt_back.wt, fm_options.bt_back.ht, \
	fm_options.bt_back.on_click