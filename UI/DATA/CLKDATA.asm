; ������� ���������� �� ������� ������������ ����������� ��� ������ �����
; ������ ������� � ����� ������� ������������ ��������� ��� ��������������� �����
clickables_matrix:
    dw fm_main_clickables             ; [0] ������� ����� (fm_main)
    dw fm_exit_clickables             ; [1] ����� ������ (fm_exit)
    dw fm_options_clickables          ; [2] ����� ������ ��������� (fm_options)
    dw fm_cutom_options_cklickables   ; [3] ����� ���������������� �������� (fm_custom_options)

; ������ �������� ����� � ������� ���� (��������, 0 = fm_main)
active_form_index dw ACTIVE_MAIN     

; �� ������������
difficulty_change db DIFFICULTY_UNCHANGED