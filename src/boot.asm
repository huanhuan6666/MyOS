[org 0x7c00] ; MBR加载到0x7c00的位置

; 设置屏幕为文本模式并清除屏幕

mov ax, 3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00


; 数据段初始化到屏幕显示区域0xb8000
mov ax, 0xb800
mov ds, ax 
mov byte [0], 'H'
jmp $ ; 阻塞

; 当前行$ 开头$$ 也就是说除去末尾的55AA和之前的代码，中间全部填充成0
times 510 - ($ - $$) db 0
; 主引导扇区最后固定为55AA
db 0x55, 0xaa