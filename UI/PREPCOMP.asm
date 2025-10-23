; По хорошему это всё нужно было сделать через макросы т.к.
; все данные известны ещё до запуска программы и они используются в самом начале,
; но мне было впадлу это делать

proc fm_options_centralize_buttons ;out_x, out_wt, wt
    mov bx,fm_options
    mov ax,[bx]
    mov cx,[bx+4]
    mov dx,[bx+20]
    
    stdcall centralize_cord, ax,cx,dx
    
    mov [fm_options.bt_easy.x],ax
    mov [fm_options.bt_medium.x],ax 
    mov [fm_options.bt_hard.x],ax
    mov [fm_options.bt_custom.x],ax
    mov [fm_options.bt_back.x],ax
    ret
endp

proc fm_main_centralize_buttons
    mov ax,[fm_main.pn_control.x]
    mov cx,[fm_main.pn_control.wt]
    mov dx,[fm_main.pn_control.bt_reset.wt]
    
    stdcall centralize_cord, ax,cx,dx
    
    mov [fm_main.pn_control.bt_reset.x],ax
    
    mov ax,[fm_main.pn_control.y]
    mov cx,[fm_main.pn_control.ht]
    mov dx,[fm_main.pn_control.bt_reset.ht]
    
    stdcall centralize_cord, ax,cx,dx
    
    mov [fm_main.pn_control.bt_reset.y],ax
    ret
endp

proc fm_custom_options_centralize_buttons
    mov ax,[fm_custom_options.x]
    mov cx,[fm_custom_options.wt]
    mov dx,[fm_custom_options.bt_back.wt]
    
    stdcall centralize_cord, ax,cx,dx
    
    mov [fm_custom_options.bt_back.x],ax
    ret
endp