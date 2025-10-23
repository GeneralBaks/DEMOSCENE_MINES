; ћатрица указателей на таблицы кликабельных компонентов дл¤ каждой формы
;  аждый элемент Ч адрес таблицы кликабельных элементов дл¤ соответствующей формы
clickables_matrix:
    dw fm_main_clickables             ; [0] главна¤ форма (fm_main)
    dw fm_exit_clickables             ; [1] форма выхода (fm_exit)
    dw fm_options_clickables          ; [2] форма выбора сложности (fm_options)
    dw fm_cutom_options_cklickables   ; [3] форма пользовательских настроек (fm_custom_options)

; »ндекс активной формы в матрице форм (например, 0 = fm_main)
active_form_index dw ACTIVE_MAIN     

; Ќе используетс¤
difficulty_change db DIFFICULTY_UNCHANGED