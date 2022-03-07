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

mov si, booting
call print

jmp $ ; 阻塞

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret
booting:
    db "Booting MyOS...", 10, 13, 0 ;最后三个数字依次代表/n /r /0的ASCII码

; 当前行$ 开头$$ 也就是说除去末尾的55AA和之前的代码，中间全部填充成0
times 510 - ($ - $$) db 0
; 主引导扇区最后固定为55AA
db 0x55, 0xaa