; ========== SYNTAX OVERVIEW ==========
; Поддержка циклов (_cycle, _for, _while, _repeat), условий (_if, _elseif, _else), switch/case
; Все конструкции завершаются _end или спец. макросами (_endfor, _endif и т.п.)
; Поддержка _break для выхода из любого(почти) цикла
;=========SYNTAX=============
;_cycle number 
;... 
;_endncycle(_end) +_break
;- - - - - - - - - - - - - 
;_for reg/mem = val : cond : step
;... 
;_endfor(_end) +_break
;- - - - - - - - - - - - - 
;_for reg/mem = val to/downto val
;... 
;_endfor(_end) +_break
;- - - - - - - - - - - - - 
;_if cond
;... 
;_elseif cond
;... 
;_else 
;... 
;_endif(_end)
;- - - - - - - - - - - - - 
;_if cond jmp lable
;- - - - - - - - - - - - - 
;_while cond
;... 
;_endwhile(_end) +break
;- - - - - - - - - - - - - 
;_repeat 
;... 
;_until cond +break
;- - - - - - - - - - - - - 
;_switch val 
;_case a 
;... 
;_case b 
;... 
;_endswitch(_end)
;- - - - - - - - - - - - - 
;_mcall obj:method
;==========FACTS============
; 1)for all cond: 
; a > b, a <= b, a != b, ...
; transform to instructions
; cmp a,b j(cond) lable

loop_depth = 0 ; вложеность _cycle

; ========== BASIC CYCLE MACRO ==========
; Реализует loop
; Использует регистр CX как счетчик
macro _loop iter {
	local ..end
	lst_loop_end equ ..end ; Для _break
	
	loop_depth = loop_depth + 1 ; Увеличиваем счетчик вложенности
	
	if loop_depth > 1
		push cx ; Сохраняем cx при вложенности
	end if 
	
	if ~ iter eq
		mov cx,iter
	end if
	
	local .loop
	curloop equ .loop ; Для команды loop
	
	curloop: ; Начало цикла
	
	_end_ equ _loop_ ; Для универсального _end
}

macro _endloop {
	loop curloop ; Повтор цикла
	
	if loop_depth > 1 ; Восстанавливаем CX если был сохранен
		pop cx
	end if
	
	loop_depth = loop_depth - 1 ; Уменьшаем вложенность
	 
	lst_loop_end: ; Метка выхода
	
	; Очищаем временные метки
	restore lst_loop_end
	restore curloop
	restore _end_
}

; ========= FOR =============
; Только С стиль
macro _for param* {
	local ..begpos, ..endpos
	beg equ ..begpos ; Метка начала цикла
	lst_loop_end equ ..endpos ; Метка выхода
	
	define definstr 0
	define defvar 0
	
	match assign:cond:step, param \{
		match var == num, assign \\{
			mov var,num
			for_var equ var
			define defvar 1
		\\}
		
		match =0 var,defvar assign \\{
			for_var equ var
			define defvar 1
		\\}
	
		beg:
		
		gen_cmp_jmp_rev cond,lst_loop_end
		
		match =0 =- =1, definstr step \\{
			define definstr dec
		\\}
		
		match =0 =1, definstr step \\{
			define definstr inc
		\\}
		
		match =0 =- num, definstr step \\{
			define definstr sub
			for_num equ num
		\\}
		
		match =0 num, definstr step \\{
			define definstr add
			for_num equ num
		\\}
	\}

	_end_ equ _for_ ; Для универсального _end
}

macro _endfor {
	match =inc,definstr \{
		inc for_var
	\}
	
	match =dec,definstr \{
		dec for_var
	\}
	
	match =sub,definstr \{
		sub for_var,for_num
		restore for_num
	\}
	
	match =add,definstr \{
		add for_var,for_num
		restore for_num
	\}
	
	jmp beg			; Следующая итерация
	lst_loop_end:   ; Выход
	
	restore for_var
	restore beg
	restore lst_loop_end
	restore _end_
}

; ========== PRINT ==========
macro _print [string] {
		mov ah,9
		if ~ string eq
			mov dx,string
		end if
		int 21h
}

; ========== COMPARE GENERATORS ==========
; Простая генерация сравнения и перехода
; Реализация сравнений: ==, ~=, >=, <=, >, <
; с генерацией соответствующих jmp-инструкций
macro gen_cmp_jmp param,lbl {
	local def
	define def 0
	
	match =0 =zf ==== =1,def param \{
		jz lbl
		define def 1
	\}
	
	match =0 =zf ==== =0,def param \{
		jnz lbl
		define def 1
	\}
	
	match =0 arg1 ==== arg2,def param \{
		cmp arg1, arg2
		je lbl
		define def 1
	\}
	
	match =0 arg1 =~== arg2,def param \{
		cmp arg1, arg2
		jne lbl
		define def 1
	\}
	
	match =0 arg1 >== arg2,def param \{
		cmp arg1, arg2
		jge lbl
		define def 1
	\}
	
	match =0 arg1 <== arg2,def param \{
		cmp arg1, arg2
		jle lbl
		define def 1
	\}
	
	match =0 arg1 => arg2,def param \{
		cmp arg1, arg2
		jg lbl
		define def 1
	\}
	
	match =0 arg1 =< arg2,def param \{
		cmp arg1, arg2
		jl lbl
		define def 1
	\}
}

; Инвертированная версия (для if и условий в цикле)
macro gen_cmp_jmp_rev param,lbl {
	local def
	define def 0
	
	match =0 =zf ==== =1,def param \{
		jnz lbl
		define def 1
	\}
	
	match =0 =zf ==== =0,def param \{
		jz lbl
		define def 1
	\}
	
	match =0 arg1 ==== arg2,def param \{
		cmp arg1, arg2
		jne lbl
		define def 1
	\}
	
	match =0 arg1 >== arg2,def param \{
		cmp arg1, arg2
		jl lbl
		define def 1
	\}
	
	match =0 arg1 <== arg2,def param \{
		cmp arg1, arg2
		jg lbl
		define def 1
	\}
	
	match =0 arg1 =~== arg2,def param \{
		cmp arg1, arg2
		je lbl
		define def 1
	\}
	
	match =0 arg1 > arg2, def param \{
		cmp arg1, arg2
		jle lbl
		define def 1
	\}
	
	match =0 arg1 < arg2, def param \{
		cmp arg1, arg2
		jge lbl
		define def 1
	\}
}

; ========== IF / ELSE / ELSEIF ==========
; Простая поддержка if/elseif/else
macro _if param* {
	local ..end, ..if_local, isdef
	
	if_fin equ ..end	 ; Метка конца блока
	curif equ ..if_local ; Текущая метка
	 
	define has_else 0
	define isdef 0
	; Форма с переходом: _if cond jmp label
	match =0 cond =jmp lbl, isdef param \{
		gen_cmp_jmp cond,lbl
		
		define isdef 1
	\}
	
	; Обычная форма if
	match =0 cond, isdef param \{
		gen_cmp_jmp_rev cond,curif ; Инвертированное условие
		_end_ equ _if_
		
		define isdef 1
	\}
}

; Блок else
macro _else {
	jmp if_fin ; Пропускаем блок else
	curif:	   ; Продолжение if
	restore curif
	
	define has_else 1
}

; Блок elseif
macro _elseif param* {
	jmp if_fin ; Пропускаем следующий блок
	
	curif:
	restore curif
	
	local ..if_local
	curif equ ..if_local
	
	match cond ,param \{
		gen_cmp_jmp_rev cond,curif ; Проверка нового условия
	\}
}

; Конец условного блока
macro _endif {
	match =0, has_else \{
		curif:
		restore curif
	\}
	
	if_fin:
	restore if_fin
	restore _end_
}

; ========== WHILE LOOP ==========
macro _while param* {
	local ..beg,..end
	bwhl equ ..beg 
	lst_loop_end equ ..end
	
	bwhl:
	match cond,param \{
		gen_cmp_jmp_rev cond,lst_loop_end
	\}	
	_end_ equ _while_
}

; End while loop
macro _endwhile {
	jmp bwhl
	lst_loop_end:
	
	restore bwhl
	restore lst_loop_end
	restore _end_
}

; ========== REPEAT-UNTIL ==========
macro _repeat {
	local ..rep, ..end	
	rep_beg equ ..rep 
	lst_loop_end equ ..end
	
	rep_beg:
}

macro _until param* {
	match cond,param \{
		gen_cmp_jmp_rev cond,rep_beg
	\}
	
	lst_loop_end:
	
	restore rep_beg
	restore lst_loop_end 
}

; ========== SWITCH-CASE ==========
macro _switch arg* {
	define sw_depth 0
	
	local ..curcase, ..end
	case_lbl equ ..curcase
	sw_end equ ..end 
	
	solution equ arg
	_end_ equ _switch_
}

macro _case val* {
	match =1 , sw_depth \{
		jmp sw_end
	\}

	define sw_depth 1

	case_lbl:
	restore case_lbl
	
	local ..curcase
	case_lbl equ ..curcase
	
	cmp solution, val
	jne case_lbl
}

macro _endswitch {
	case_lbl:
	sw_end:	
	
	restore case_lbl
	restore solution
	restore sw_end
	restore _end_
}

; ========== GENERIC END ==========
macro _end {
	local def
	define def 0
	match =0 =_loop_, def _end_ \{
		_endloop
		define def 1
	\}
	match =0 =_for_, def _end_ \{
		_endfor
		define def 1
	\}
	match =0 =_if_, def _end_ \{
		_endif 
		define def 1
	\}
	match =0 =_switch_, def _end_ \{
		_endswitch
		define def 1
	\}
	match =0 =_while_, def _end_ \{
		_endwhile
		define def 1
	\}
}

; ========== BREAK ==========
macro _break { jmp lst_loop_end }  ; Выход из цикла

; ========== UTILS ==========
struc pasc_str data{
	local .length
	. db .length, data
	.length = $ - . - 1
}

macro _clear [arg] {xor arg,arg}

macro _set_seg param {
	match seg1 =to seg2, param \{
		push seg1 seg2 
		pop seg1
		glob_seg equ seg1
	\}
}

macro _unset_seg {
	pop glob_seg
	restore glob_seg
}

macro _center_play_field scr_size, obj_size, offset, dest {
	mov ax, scr_size
	sub ax, [obj_size]
	add ax, offset
	shr ax, 1
	mov [dest], ax
}

macro _generate_matrix _cols, _rows {
	local elem
	cols = _cols
	rows = _rows
	.cols dw _cols
	.rows dw _rows
	
	elem = _cols * _rows
	.size dw elem
	.elements db elem dup (0)
}



; ========== STRUCTURE HELPERS ==========
macro mcall obj, method, var{
	if ~ var eq
		stdcall [obj#.#method], obj, var
	else
		stdcall [obj#.#method], obj
	end if
}

macro _mcall param,var {
	match obj:method , param \{
		mcall obj, method, <var>
	\}
}

struc array len {
	db len dup (0)
}


;Костыль для подсчёта внутреннего X и Y
;до определения формы
; Рассчитывает внутренние координаты элементов
; на основе внешних координат и толщины рамки
macro _generate_cord param {
	match  _x : _y : border_w ,param \{
		x = _x
		y = _y
		bw = border_w
		inner_x = _x + 2 + border_w
		inner_y = _y + 2 + border_w
	\}
}

macro _init_component name, type, [field:value] {
	
}
	
macro _calc_offset x,y,reg {
	if ~ reg in <ax,cx,dx,bx,si,di>
		display "last variable should be reg"
		err
	end if
	imul reg,y,SCR_W
	add reg,x
}