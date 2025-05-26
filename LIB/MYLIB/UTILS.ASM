;Сравниваем строки
;=================================
;Требуется:
;в di,si 2 строки с концом(00h)	
;Результат:
;ax=0 -> равны|ax=1 -> str1>str2|ax=-1 -> str1<str2	
cmp_str:
		push cx bx si di

		mov bx,di
		call arr_len
		mov ax,cx		
		
		mov bx,di
		call arr_len
		
		cmp cx,ax
		cmova cx,ax
		
		repe cmpsb
		
		ja .s1_above
		jb .s1_below
		
		xor ax,ax
		jmp .epi
		
.s1_above:
		mov ax,1
		jmp .epi
		
.s1_below:
		mov ax,-1
		
.epi:		
		pop di si bx cx
		ret


;============================
;Преобразуем число в строку
;Ввод:
;В AX число(0,255) | BX - куда заносить результат
;Результат:
;Выводит результат в str_num 
byte_to_str:
        push ax dx bx
		
		xor dl,dl	;счётчик
        mov dh,10	;делитель
		
.lp_push_num:			
		xor ah,ah
		div dh    			  
		add ah,'0'		;формируем символ

		push ax			;заносим цифру в стек
		
		inc dl			;сдвигаем положение младшего байта в будущей строке
		
		test al,al			;продолжаем цикл, пока целая часть не 0
		jnz .lp_push_num
		
.lp_gen_num:
		pop ax
		mov [bx],ah
		
		inc bx

		dec dl
		jnz .lp_gen_num
		
		mov byte[bx],'$'
		
        pop bx dx ax
        ret
		
;============================
;Преобразуем число в строку
;В num число(0,65535) | string - куда заносить результат 
proc word_to_str uses bx si, \
		num, string
        
	mov ax,[num]
	mov bx,[string]
	xor si,si

	mov cx,10
	
	_repeat
		xor dx,dx
		div cx    
		
		add dl,'0'
		push dx
		
		inc si
	_until ax == 0

	_while si ~= 0
		pop ax
		mov [bx],al
		inc bx
		
		dec si
	_end	
		
	mov byte[bx],00h
    ret
endp
		
;============================
;?реобразуем число в строку
;DX:AX число(0|4 294 967 295) | DI - куда заносить результат 
dword_to_str:
        push ax cx dx bx di si
		xor si,si
		
        mov bx,10
		
.lp_push_num:			;формируем число
		call div32
		add cl,'0'
		push cx
	
		inc si
		
		test ax,ax			;продолжаем цикл, пока целая часть не 0
		jnz .lp_push_num

.lp_gen_num:
		pop ax
		mov [di],al
		inc di
		
		dec si
		jnz .lp_gen_num
		
		mov byte[di],'$'

.epi:
        pop si di bx dx cx ax
        ret

;============================
;Преобразуем число в строку
;Ввод:
;В AX число(-128,127) | BX - куда заносить результат
;Результат:
;Выводит результат в str_num 
short_int_to_str:
        push ax dx bx
		
		xor dl,dl
		
		test al,1000_0000b		;определяем положительное или отрицательное		

		jns .not_neg
		mov byte[bx],'-'
		neg al
		inc bx		;смещаем стартовую позицию BX влево (при выводе)
.not_neg:

        mov dh,10
		
.lp_push_num:			
		xor ah,ah
		div dh    			  
		add ah,'0'		;формируем символ

		push ax			;заносим цифру в стек
		
		inc dl			;сдвигаем положение младшего байта в будущей строке
		
		test al,al			;продолжаем цикл, пока целая часть не 0
		jnz .lp_push_num
		
.lp_gen_num:
		pop ax
		mov [bx],ah
		
		inc bx

		dec dl
		jnz .lp_gen_num
		
		mov byte[bx],'$'
		
        pop bx dx ax
        ret

;============================
;Преобразуем число в строку
;В AX число(-32768,32767) | BX - куда заносить результат 
small_int_to_str:
        push ax cx dx bx si
		
		xor si,si
		
		test ax,1000_0000_0000_0000b  	;определяем положительное или отрицательное
		jz .isnt_neg
		neg ax
		mov byte[bx],'-'
		inc bx
.isnt_neg:

        mov cx,10
		
.lp_push_num:		
		xor dx,dx
		div cx    
		
		add dl,'0'
		push dx
		
		inc si
		
		test ax,ax			;продолжаем цикл, пока целая часть не 0
		jnz .lp_push_num

.lp_gen_num:
		pop ax
		mov [bx],al
		inc bx
		
		dec si
		jnz .lp_gen_num
		
		mov byte[bx],'$'

.epi:
        pop si bx dx cx ax
        ret
		
		
;============================
;?реобразуем число в строку
;DX:AX число(-2,147,483,648|2,147,483,647) | DI - куда заносить результат 
long_int_to_str:
        push ax cx dx bx di si
		xor si,si
		
		test dx,1000_0000_0000_0000b  
		jz .isnt_neg
		not ax
		not dx
		add ax,1
		adc dx,0
		
		mov byte[di],'-'
		inc di
.isnt_neg:
        mov bx,10
		
.lp_push_num:			;формируем число
		call div32
		add cl,'0'
		push cx
	
		inc si
		
		test ax,ax			;продолжаем цикл, пока целая часть не 0
		jnz .lp_push_num

.lp_gen_num:
		pop ax
		mov [di],al
		inc di
		
		dec si
		jnz .lp_gen_num
		
		mov byte[di],'$'

.epi:
        pop si di bx dx cx ax
        ret
		

;=========================================
;Changes matching characters
;Requires:
;AL - character to search / DI - string
;CX - string length / DL - number to add
;Result:
;Modified string
change_chars:
        push ax cx dx di
        cld     ;direction: left to right
.loop:
        repne scas byte[di]

        jne .search_end

        dec di
        add [di],dl
        inc di

        test cx,cx
        jnz .loop
.search_end:

        pop di dx cx ax
        ret


;================================================
;Attempts to convert string to a one-byte number.
;Requires:
;BX - address of string / CL - length of string
;Result:
;AL - number
;CF = 0 (if valid), otherwise 1
;AH - may change
try_str_to_byte:
        push cx bx

        xor ax,ax
        mov dh,10

.loop_converting:
        mul dh
        mov dl,[bx]

        cmp dl,'0'           ;if character is not a digit, error
        jb .error
        cmp dl,'9'
        ja .error
                             ;steps of converting "123"
        sub dl,'0'           ;1) 000 2) 001 3) 010
        add al,dl            ;4) 012 5) 120 6) 123

        jc .error              ;if overflowed max value -> error

        inc bx
        dec cl
        jnz .loop_converting

        clc                      ;CF = 0 -> all good
        jmp .epi

.error:							 ;CF = 1 -> error
		stc

.epi:
        pop bx cx
        ret
		
;================================================
;Attempts to convert string to a one-byte number.
;Requires:
;BX - address of string / CL - length of string
;Result:
;AX - number
;CF = 0 (if valid), otherwise 1
try_str_to_small_int:
        push cx dx bx si di
		movzx di,cl

        xor ax,ax
        mov si,10
		
		cmp byte[bx],'-'
		pushf
		jne .is_not_neg
		inc bx
		dec di
.is_not_neg:

.loop_converting:
		mov ch,[bx]
		inc bx

        cmp ch,'0'           ;if character is not a digit, error
        jb .error
        cmp ch,'9'
        ja .error
		
		mul si
		jc .error
                             ;steps of converting "123"
        sub ch,'0'           ;1) 000 2) 001 3) 010
        add al,ch            ;4) 012 5) 120 6) 123
		adc ah,0

        jc .error              ;if overflowed max value -> error

        dec di
        jnz .loop_converting
		
		popf
		jne @f
		neg ax
@@:

        clc                      ;CF = 0 -> all good
        jmp .epi

.error:							 ;CF = 1 -> error
		popf
		stc

.epi:
        pop di si bx dx cx
        ret
		
;================================================
;Attempts to convert string to a one-byte number.
;Requires:
;string - address of string / len - length of string
;Result:
;AX - number
;CF = 0 (if valid), otherwise 1
proc try_str_to_word uses bx si di, \
	string, len:byte
		movzx di,[len]
		mov bx,[string]

        xor ax,ax
        mov si,10

.loop_converting:
		mov ch,[bx]
		inc bx

        cmp ch,'0'           ;if character is not a digit, error
        jb .error
        cmp ch,'9'
        ja .error
		
		mul si
		jc .error
                             ;steps of converting "123"
        sub ch,'0'           ;1) 000 2) 001 3) 010
        add al,ch            ;4) 012 5) 120 6) 123
		adc ah,0

        jc .error              ;if overflowed max value -> error

        dec di
        jnz .loop_converting

        clc                      ;CF = 0 -> all good
        jmp .epi

.error:							 ;CF = 1 -> error
		stc

.epi:
        ret
endp


;=======================
;делит 4 байтовое число
;Требуется:
;DX:AX - число, BX - делитель
;Результат:
;DX:AX - число, CX - остаток
div32:
		mov cx,ax	;сохраняем младшую часть
.calc:			
		mov ax,dx	;
		xor dx,dx	; делим старшую часть числа
		div bx		;
				
		xchg cx,ax	; обмениваемся. выходит CX - high, AX - low		
.div_low:
		div bx		; делим младшую часть
		
		xchg cx,dx
.epi:		
		ret

;=============================
;Находит длину массива
;Требуется:
;в arr адрес массива
;Выводит:
;в cx длину массива 
proc arr_len uses di, \
		arr
	; --- Инициализация ---	
	mov di,[arr]	
	xor al,al
	mov cx,0FFFFh
	cld				;сканируем вперёд
	; --- Вычисления ---
	repne scasb
	
	not cx	;находим длину
	dec cx

	ret
endp
		
;=============================
;заполняет строку 00h
;Требуется:
;в arr адрес строки, len - количество элементов
;Результат:
;пустая строка 
proc clr_arr \
	arr, len
	
	mov cx,[len]
	mov di,[arr]
	
	dec cx
	xor ax,ax
	cld
	rep stosb		
	
	ret
endp
		
proc centralize_cord \
	out_cord, out_wt, wt
	
	mov ax,[out_wt]
	sub ax,[wt]
	shr ax,1
	add ax,[out_cord]
	
	ret
endp

;============================
;Преобразуем число в строку
;В num число(0,65535) | string - куда заносить результат 
proc word_to_str_time uses si, \
		num, string
        
	mov ax,[num]
	mov bx,[string]
	xor si,si

	mov cx,10
	
	_repeat
		xor dx,dx
		div cx    
		
		add dl,'0'
		push dx
		
		inc si
	_until ax == 0
	
	mov cx,3
	sub cx,si
	
	_if cx > 0
		_loop
			mov byte[bx],'0'
			inc bx
		_end
	_end

	_while si ~= 0
		pop ax
		mov [bx],al
		inc bx
		
		dec si
	_end	
		
	mov byte[bx],00h
    ret
endp

proc copy_str uses si di, \
	src_str, dst_str, len
	mov si,[src_str]
	mov di,[dst_str]
	mov cx,[len]
	
	cld
	rep movsb
	
	ret
endp
