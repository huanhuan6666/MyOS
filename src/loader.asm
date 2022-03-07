[org 0x1000]

; 手写一个简单的loader内核加载器
dw 0x55aa ; 自定义一个魔数嘻嘻

mov si, loading
call print
jmp $

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
loading:
    db "Loading MyOS...", 10, 13, 0 ;最后三个数字依次代表/n /r /0的ASCII码
