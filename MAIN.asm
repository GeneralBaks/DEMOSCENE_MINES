;MINES - ���� "����" �� ����������
; --------------------------------------------------------------
;                        ��������
; --------------------------------------------------------------
; ��������� - UPPER_SNAKE_CASE
; ����������, �������� � ������ - snake_case � ���������� �� ���� ������ 
;   (��������: str_text) - ���� ����������
; ��������� - PascalCase
; ������� - _snake_case (� �������������� � ������)
; ��������� ���������� ����������� ��� ��������� ����������

;------------------------------------------------------------------------------
;                            ������ �������
;------------------------------------------------------------------------------
; MINES/
; +-- CONFIG.ASM             - ���������
; +-- MAIN.ASM               - ������� ���� ��������� 
; +-- MAIN.COM               
; �
; +-- GAME/                  - ������� ������
; �   +-- DATA/
; �   �    L-- STORAGE.ASM      - ������� ������
; �   +-- RANDOM.ASM   			- ��������� ��������� �����
; �   L-- LOGIC.ASM  			- �������� ������� ������
; �   
; +-- INPUT/                 - ��������� ����������������� �����
; �   +-- KEYBOARD.ASM       - ��������� ������� ����������
; �   L-- MOUSE/
; �       +-- DATA.ASM       - ������ ��������� ���� � �������
; �       +-- DRAW.ASM       - ��������� ������� ����
; �       L-- LOGIC.ASM      - ������ ��������� ������� ����
; �
; +-- LIB/                   - ����������
; �   +-- MYLIB/             - ���������������� ����������
; �   �   +-- VCL/           - ���������� ���������� �����������
; �   �   �   +-- AUTO.ASM       - ������ ��� ������� � �������� ���������
; �   �   �   +-- DEFSTRUC.ASM   - ����������� �������� UI �����������
; �   �   �   +-- DRAW.ASM       - ������� ���������
; �   �   �   L-- METHODS.ASM    - ������ ������ � ������������ UI
; �   �   +-- MACROS.ASM     - ���������������� �������
; �   �   L-- UTILS.ASM      - ��������������� �������
; �   L-- STDLIB/            - ����������� ���������� FASM
; �       +-- PROC16.INC     
; �       L-- STRUCT.INC     
; �
; L-- UI/                    - ���������������� ���������
;     +-- DATA/              - ������ ����������
;     �   +-- CHARS.ASM      - ���������� ������
;     �   +-- CLKDATA.ASM    - ������ ��������� ������ ����
;     �   +-- SCRDATA.ASM    - ������ ������ � �����������
;     �   +-- STRINGS.ASM    - ��������� ��������� ����������
;     �   L-- TIMEDATA.ASM   - ������ ������� �������
;     +-- FORMS/             - ����� ����������
;     �   +-- FORMCUST/      - ����� ���������������� ��������
;     �   �   +-- DRAWCUST.ASM   - ���������
;     �   �   +-- HNDLCUST.ASM   - ����������� ������� 
;     �   �   L-- INITCUST.ASM   - ������������� ������ 
;     �   +-- FORMEXIT/      - ������ ������������� ������
;     �   �   +-- DRAWEXIT.ASM   - ��������� 
;     �   �   +-- HNDLEXIT.ASM   - ����������� ������� 
;     �   �   L-- INITEXIT.ASM   - ������������� ������ 
;     �   +-- FORMMAIN/      - ������� ������� �����
;     �   �   +-- DRAWMAIN.ASM   - ��������� 
;     �   �   +-- HNDLMAIN.ASM   - ����������� ������� 
;     �   �   L-- INITMAIN.ASM   - ������������� ������ 
;     �   L-- FORMSETT/      - ����� ������ ������ ���������
;     �       +-- DRAWSETT.ASM   - ��������� 
;     �       +-- HNDLSETT.ASM   - ����������� ������� 
;     �       L-- INITSETT.ASM   - ������������� ������ 
;     +-- PREPCOMP.ASM       - ��������������� ���������� �����������
;     L-- TIMER.ASM          - ������� �������� �������

include "LIB\STDLIB\PROC16.INC"
include "LIB\STDLIB\STRUCT.INC"
include "LIB\MYLIB\MACROS.ASM"

; --------------------------------------------------------------
;                        ��������
; --------------------------------------------------------------
; ��������� - UPPER_SNAKE_CASE
; ����������, �������� � ������ - snake_case 
; ��������� - PascalCase
; ������� - _snake_case (� �������������� � ������)
; ��������� ���������� ����������� ��� ��������� ����������
; �������������� ������������� �����

include "CONFIG.ASM"
	
; --------------------------------------------------------------
;                        ����� ����� ���������
; --------------------------------------------------------------
org 100h		
start:
    stdcall set_video_mod_to_13h
	
	stdcall fm_main_centralize_buttons
	stdcall fm_options_centralize_buttons
	
    ; ��������� ������� �����
	stdcall draw_fm_main
	; ������������� ����
	stdcall init_mouse
	stdcall init_random
	
    ; �������� ���� ���������
	_repeat
		stdcall mouse_handle    ; ��������� ������� ����
		stdcall keyboard_handle ; ��������� ����������
		_if [game_state] == GAME_PLAY
			_if [active_form_index] == ACTIVE_MAIN
				stdcall update_timer, fm_main.pn_control.lb_timer
				_if word[game_time] == MAX_TIME
					mov [game_state], GAME_LOSE
					stdcall change_br_reset_to_lose
					_mcall fm_main.pn_control.bt_reset:draw
					_mcall fm_main.pn_field.gr_field:fill_grid, <field_matrix>
				_end
			_end
		_end
	_until [game_state] == GAME_EXIT
	
    ; �������������� ��������� �����������
	stdcall restore_video_mod

    ; ���������� ���������
    ret

; --------------------------------------------------------------
;                  ��������� ���������� ������������
; --------------------------------------------------------------

; ������������ � ���������� 13h � ��������� �������� �����������
proc set_video_mod_to_13h 
    ; ���������� �������� ������ � �������� ��������
	mov ah, 0Fh
	int 10h
	
    mov [prev_mode], al
    mov [prev_page], bh
	
    ; ��������� ����������� 13h 
	mov ax, 13h
	int 10h
	
    ; ��������� �������� �������� 0
	mov ah, 5
	mov al, 0
	int 10h
	
    ; ��������� ES �� ������� �����������
	push 0A000h
	pop es
	
	ret
endp

; �������������� ��������� �����������
proc restore_video_mod
    ; �������������� ����������� �����������
    mov al, [prev_mode]
    mov ah, 0
    int 10h

    ; �������������� �������� ��������
    mov ah, 5
    mov al, [prev_page]
    int 10h
	ret
endp

; --------------------------------------------------------------
;                  ����������� ������� ���������
; --------------------------------------------------------------

include "GAME\LOGIC.ASM"
include "GAME\RANDOM.ASM"

include "INPUT\KEYBOARD.ASM"

include "INPUT\MOUSE\LOGIC.ASM"  
include "INPUT\MOUSE\DRAW.ASM"   


include "LIB\MYLIB\VCL\DRAW.ASM"       
include "LIB\MYLIB\VCL\METHODS.ASM"   
include "LIB\MYLIB\VCL\AUTO.ASM"      


include "LIB\MYLIB\UTILS.ASM"
 
include "LIB\MYLIB\VCL\DEFSTRUC.ASM"

include "UI\FORMS\FORMMAIN\DRAWMAIN.ASM"      
include "UI\FORMS\FORMMAIN\HNDLMAIN.ASM"   
    
include "UI\FORMS\FORMEXIT\DRAWEXIT.ASM"      
include "UI\FORMS\FORMEXIT\HNDLEXIT.ASM"  
    
include "UI\FORMS\FORMSETT\DRAWSETT.ASM"      
include "UI\FORMS\FORMSETT\HNDLSETT.ASM"  
  
include "UI\FORMS\FORMCUST\DRAWCUST.ASM"      
include "UI\FORMS\FORMCUST\HNDLCUST.ASM"     

include "UI\TIMER.ASM"
include "UI\PREPCOMP.ASM"

include "UI\FORMS\FORMMAIN\INITMAIN.ASM" 
include "UI\FORMS\FORMEXIT\INITEXIT.ASM"   
include "UI\FORMS\FORMSETT\INITSETT.ASM"  
include "UI\FORMS\FORMCUST\INITCUST.ASM"      
 
include "UI\DATA\CHARS.ASM"					
include "UI\DATA\STRINGS.ASM"
include "UI\DATA\CLKDATA.ASM"
include "UI\DATA\SCRDATA.ASM"
include "UI\DATA\TIMEDATA.ASM"
include "INPUT\MOUSE\DATA.ASM"   
include "GAME\DATA\STORAGE.ASM"  