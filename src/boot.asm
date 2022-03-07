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

mov edi, 0x1000; 读取到内存0x1000的位置
mov ecx, 0; 起始扇区
mov bl, 1; 读的扇区数量
call read_disk

xchg bx, bx

jmp $ ; 阻塞

read_disk:
    ;设置读写扇区的数量
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    inc dx; 0x1f3
    mov al, cl ;起始扇区的前8位，ecx里第0个扇区因此实际上全是0
    out dx, al

    inc dx; 0x1f4
    shr ecx, 8
    mov al, cl ;起始扇区的中8位
    out dx, al

    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl ;起始扇区的高8位
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111 ;将高4位置为0

    mov al, 0b1110_0000
    or al, cl
    out dx, al ;主盘 LBA模式

    inc dx; 0x1f7
    mov al, 0x20 ;0x1f7为控制端口，0x20表示读硬盘操作
    out dx, al

    xor ecx, ecx; 清空ecx
    mov bl, cl; 得到读写扇区的数量
    .read:
        push cx
        call .waits ;等待数据准备完毕
        call .reads
        pop cx
        loop .read ;读取一个扇区

    ret
    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2 ;一点延迟
            jmp $+2
            jmp $+2
            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check
        ret

    .reads:
        mov dx, 0x1f0
        mov cx, 256; 一个扇区256个word
        .readw:
            in ax, dx
            jmp $+2 ;一点延迟
            jmp $+2
            jmp $+2
            mov [edi], ax;移动到目标内存0x1000
            add edi, 2
            loop .readw
        ret
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