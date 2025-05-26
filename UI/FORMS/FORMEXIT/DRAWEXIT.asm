proc draw_fm_exit
	_mcall fm_exit:draw
    _mcall fm_exit.lb_confirm:draw
	_mcall fm_exit.bt_yes:draw
	_mcall fm_exit.bt_no:draw
	ret
endp