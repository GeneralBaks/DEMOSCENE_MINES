cursor_x dw 100    ; ��������� X-������� ������� 
cursor_y dw 100    ; ��������� Y-������� ������� 
prev_x   dw 160    ; ���������� X-�������
prev_y   dw 100    ; ���������� Y-�������
cursor_visible db 1 ; ���� ��������� �������
arr_cursor_back array CURSOR_SIZE * CURSOR_SIZE
mouse_button db 0
prev_button db 0
cursor_dump \
	db 2Bh,10h,10h,10h,10h,10h,10h,10h
	db 10h,0Fh,0Fh,0Fh,0Fh,0Fh,10h
	db 10h,0Fh,0Fh,0Fh,0Fh,10h
	db 10h,0Fh,0Fh,0Fh,10h
	db 10h,0Fh,0Fh,10h
	db 10h,0Fh,10h
	db 10h,10h
	db 10h
	