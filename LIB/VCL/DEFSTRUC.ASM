struct UIElement
    x       dw ?    ; Позиция X
    y       dw ?    ; Позиция Y
    w       dw ?    ; Ширина (для элементов с размером)
    h       dw ?    ; Высота
    color   dw ?    ; Основной цвет
ends

struct Panel UIElement
	frame      dw ?
	draw dw ?
ends

; Текстовая метка
struct Label UIElement
	frame   dw ?
    text    dw ?    ; Указатель на строку
	text_color dw ?
	draw    dw ?    ; Метод отрисовки
ends

; Кнопка (наследуется от Label)
struct Button UIElement
	frame   dw ?
    text    dw ?    ; Указатель на строку
	text_color dw ?
    state   dw ?    ; Состояние (0=normal, 1=pressed)
	draw    dw ?    ; Метод отрисовки
	on_click dw ?
ends

; Сетка
struct Grid UIElement
    frame       dw ?
    cols        dw ?    ; Количество колонок
    rows        dw ?    ; Количество строк
	cell_size   dw ?
	
    resize_cell  dw ?    ; Размер ячейки
	draw         dw ?    ; Метод отрисовки
	draw_cell    dw ?
	fill_grid    dw ?
	on_click     dw ?
ends

; Форма (контейнер)
struct Form UIElement
	bw 			 dw ?
	border_color dw ?
	draw    	 dw ?    ; Метод отрисовки
ends

; данные о кликабельном компоненте
struct Clickable
    x       dw ?
    y       dw ?
    w       dw ?
    h       dw ?
    handler dw ?    ; Указатель на функцию on_click
ends