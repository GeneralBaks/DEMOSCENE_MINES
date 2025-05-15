proc draw_fm_exit
	_mcall fm_exit:draw
    _mcall fm_exit.lb_confirm:draw
	_mcall fm_exit.bt_yes:draw
	_mcall fm_exit.bt_no:draw
	ret
endp

proc draw_fm_main
	; Отрисовка главной формы и панелей управления
    _mcall fm_main:draw                            ; отрисовка формы
    _mcall fm_main.pn_control:draw           ; отрисовка верхней панели
    _mcall fm_main.pn_control.lb_mines:draw  ; счётчик мин
    _mcall fm_main.pn_control.lb_timer:draw  ; таймер
	_mcall fm_main.pn_control.bt_exit:draw

    ; Настройка размеров и позиционирование игрового поля (сетка)
    _mcall fm_main.pn_field.gr_field:resize_cell   ; подстройка размера ячейки
    _mcall fm_main.pn_field:centralize_grid        ; выравнивание поля внутри панели
    ; Отрисовка панели поля и самой сетки
    _mcall fm_main.pn_field:draw
    _mcall fm_main.pn_field.gr_field:draw
	_mcall fm_main.pn_field.gr_field:fill_grid 
	ret
endp