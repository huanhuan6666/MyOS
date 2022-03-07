[org 0x1000]

; 手写一个简单的loader内核加载器
dw 0x55aa ; 自定义一个魔数嘻嘻

mov si, loading
call print

xchg bx, bx
detect_memory:
    xor ebx, ebx;
    
    mov ax, 0
    mov es, ax ;段寄存器不能直接改
    mov edi, ards_buffer ;结果存放位置，就在下文loader靠后的位置

    mov edx, 0x534d4150; 固定签名
.next:
    mov eax, 0xe820 ;子功能号
    mov ecx, 20 ;ARDS的大小
    int 0x15; BIOS中断

    jc error ;CF置位表示出错

    add di, cx
    inc word [ards_count]; 结构体数量加一
    cmp ebx, 0
    jnz .next

    mov si, detecting ;检测结束
    call print

    mov cx, [ards_count] ;ards的数量
    mov si, 0 ;结构体指针
.show:
    mov eax, [ards_buffer + si]
    mov ebx, [ards_buffer + si + 8]
    mov edx, [ards_buffer + si + 16]
    add si, 20
    xchg bx, bx
    loop .show
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
detecting:
    db "Detecting Memory Success...", 10, 13, 0 ;最后三个数字依次代表/n /r /0的ASCII码
    
error:
    mov si, .msg
    call print
    hlt ;让CPU停止
    jmp $ ;阻塞
    .msg: db "Loading Error!!!" , 10, 13, 0

ards_count:
    dw 0

ards_buffer:
