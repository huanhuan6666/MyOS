[org 0x1000]

; 手写一个简单的loader内核加载器
dw 0x55aa ; 自定义一个魔数嘻嘻

mov si, loading
call print

; xchg bx, bx
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

    jmp prepare_protected_mode; 检测内存完成之后开启保护模式
 
prepare_protected_mode:
    xchg bx, bx
    cli; 关中断
    ;开启A20总线
    in al, 0x92
    or al, 0b10
    out 0x92, al
    ;加载GDT
    lgdt [gdt_ptr]
    ;启动保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    ;通过jmp指令修改CS段寄存器成选择子,CS只能这样修改
    jmp dword code_selector:protected_mode

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


[bits 32]
protected_mode: ;保护模式代码
    ;修改剩下的段寄存器成选择子
    xchg bx, bx
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax ;初始化段寄存器

    mov esp, 0x10000 ;修改栈顶

    mov byte [0xb8000], 'p' ;直接使用1M以外的内存

jmp $

memory_base equ 0 ;内存基地址
memory_limit equ ((1024 * 1024 * 1024 * 4) / (1024*4)) - 1 ;内存界限4G/4K - 1
code_selector equ(1<<3) ;代码段选择子
data_selector equ(2<<3) ;数据段选择子

gdt_ptr: ;GDT指针
    dw (gdt_end - gdt_base) - 1
    dd gdt_base

gdt_base: ;设置GDT 3个描述符
    dd 0, 0 ;第0个dummy描述符
gdt_code: ;代码段
    dw memory_limit & 0xffff ;段界限0-15位
    dw memory_base & 0xffff; 基地址0-16位
    db (memory_base >> 16) & 0xff ; 基地址17-23位
    db 0b_1_00_1_1_0_1_0; 存在 dpl=0 代码段 非依从 未访问
    db 0b1_1_0_0_0000 | (memory_limit >> 16)&0xf; 4k 32位 不是64位 段界限
    db (memory_base >> 24) & 0xff; 段基址
gdt_data: ;数据段
    dw memory_limit & 0xffff ;段界限0-15位
    dw memory_base & 0xffff; 基地址0-16位
    db (memory_base >> 16) & 0xff ; 基地址17-23位
    db 0b_1_00_1_0_0_1_0; 存在 dpl=0 数据段 向上 可写
    db 0b1_1_0_0_0000 | (memory_limit >> 16)&0xf; 4k 32位 不是64位 段界限
    db (memory_base >> 24) & 0xff; 段基址    
gdt_end:

ards_count:
    dw 0

ards_buffer:
