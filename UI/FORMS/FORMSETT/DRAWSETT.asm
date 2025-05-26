proc draw_fm_options
	_mcall fm_options:draw
	_mcall fm_options.bt_easy:draw
	_mcall fm_options.bt_medium:draw
	_mcall fm_options.bt_hard:draw
	_mcall fm_options.bt_custom:draw
	_mcall fm_options.bt_back:draw
	ret
endp