proc init_random
     mov        ah, 2Ch
     int        21h
     mov        [rand_prev], dx
     ret
endp

proc random_get\
     min, max

     mov        ax, [rand_prev]
     rol        ax, 7
	 xor        ax, 0A7h
     adc        ax, 23
     mov        [rand_prev], ax

     mov        cx, [max]
     sub        cx, [min]
     inc        cx
     xor        dx, dx
     div        cx

     add        dx, [min]
     xchg       ax, dx
     ret
endp