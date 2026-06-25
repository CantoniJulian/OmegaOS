[BITS 16]
[ORG 0x7C00]

CODE_OFFSET equ 0x08
DATA_OFFSET equ 0x10
K_LOAD_SEG equ 0x1000
K_START_ADDR equ 0x10000

BOOT:
    cli ; uwu saca las interrupciones
    cld; clear direction flag
    mov ax, 0x00 ; acá empieza el stack, se setea en el ax, porque no se puede mover un número a los registros de segmento.
    mov ds, ax
    mov ss, ax
    mov bx, 0x0000

    mov sp, 0x7c00 ; el puntero que dice dónde termina el stack uwu
    
    sti ; uwu activa las interrupciones
    mov es, ax;

    mov bh, 0x00
    mov dh, 0x00
    mov dl, 0x00
    mov ah, 0x02
    int 0x10
	
    mov ah, 0x03
    int 0x10
    
    
    jmp RMODE_CLEAR

RMODE_CLEAR:
    mov ax, 0x0003
    int 0x10
    jmp OSOUT

OSOUT:
    mov ah, 0x13
    mov al, 0x01 ; modo escritura y mueve cursor (solo string)
    mov bl, 0x03 ; color de letra
    mov cx,  0x1B ; largo 27
    mov bp, MSG_16
    int 0x10
    mov ax, 0x00
    mov bx, ax
    mov cx, ax
    mov dx, ax
    jmp K_LOAD

K_LOAD:
    ; Tenemos que cargar el kernel acá porque se carga en modo REAL via Cylinder-Head-Sector
    mov ax, K_LOAD_SEG
    mov es, ax
    mov bx, 0x0000
    mov dh, 0x00 ; dh es el data register en los primeros 4 bits (head)
    mov dl, 0x80 ;  este valor implica el primer hard drive 
    
    mov ch, 0x00 ; c contador (cylinder)
    mov cl, 0x02 ; (sector) es el segundo sector, porque el primero es el bootloader

    mov ah, 0x02 ; a acumulador (0x02 es para operación de lectura, 0x03 sería escritura)
    mov al, 8 ;  número de sectores, tamaño del kernel
    
    int 0x13 ; interrupción de BIOS que accede al almacenamiento 
    
    jc DISK_ERROR
    jmp PMODE_START

DISK_ERROR:
    cli
    hlt 
    
PMODE_START:
    cli
    lgdt [GDT_DESCRIPTOR]
    
    mov eax, cr0 ; parte de los registros de control crx. El registro 0 es para habilitar el protected mode
    or al, 1; el primer bit de cr0 se pone en 1
    mov cr0, eax
    jmp CODE_OFFSET:PMODE_MAIN ; este es un far jmp, que permite hacer flush de la pipeline de "prelectura del procesador"

    [BITS 32] 

PMODE_MAIN:
    
    mov ax, DATA_OFFSET
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ss, ax

    mov ebp, 0x9C00 ; tiene que estar lo suficientemente lejos del stack del bootloader para que no haga overflow
    mov esp, ebp

    in al, 0x92
    or al, 2
    out 0x92, al
    mov esi, MSG_32 ;esi es para cadenas
    mov edx, 0xB80A0 ; lo pongo acá unu para que ya quede cargado
    jmp PMODE_PRINT 

PMODE_PRINT:
    lodsb
    cmp al, 0
    je K_JUMP
    mov ah, 0x02
    mov [edx], ax
    add edx, 2 ; avanza para el siguiente espacio en la VGA. (son 2 bytes por caracter)
    jmp PMODE_PRINT

K_JUMP:
    
    jmp CODE_OFFSET:K_START_ADDR

FINISH:
    cli
    hlt ; frena alaverga :v

; -----------------------------------------
; GDT y Datos
; -----------------------------------------

GDT_BOOT:
    ; Primera entrada GDTR nula de la GDT :3
    dd 0x0
    dd 0x0

    ; Code Segment descriptor
    dw 0xFFFF ; hasta donde llega el segmento
    dw 0x0000; base
    db 0x00 ;base
    db 10011010b ; Este es el ACCES BYTE. Tiene:
    ; P setteado en 1 implica que es segmento válido (primer bit). DPL toma dos bits
    ; S: en 1 define que es un segmento de datos o código.
     ; E: Bit de ejecutable. define en 1 que es un segmento de código.
    ; DC como estamos definiendo segmento de código DC = conforming bit. 0 limita la ejecución al ring 0
    ; se interpreta como READABLE BIT y en 1 significa que está permitido leer el bit.
    ; access bit:  en 0 significa que no fue accedido por la CPU. Se suele dejar en 1
    ; b significa que es en binario 7u7
    db 11001111b ; acá van las flags.
    ; G granularidad: escalado del límite. 1 es para page granularity, lo que significa que los saltos son de 4kib y el segmento abarca 4GB
    ; DB: flag de tamaño. 1 implica definir un segmento de 32 bits en modo protegido de la GDT.
    ; L: long mode. Siempre se empieza en 32.
    ; los últimos 4 bytes corresponden a los 4 bytes restantes del límite de 20 de la GDT
    db 0x00 ; la base de las flags.

    ; Data Segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b ; accessbyte del data sd
    ; el DC cambia, lógicamente, porque es data segment en vez de code
    db 11001111b ; acá van las flags.
    db 0x00

GDT_END:

GDT_DESCRIPTOR:
    dw GDT_END - GDT_BOOT -1; el espacio que sobre (entiendo) de la GDT
    dd GDT_BOOT ; la dirección de la GDT

MSG_16: db 'Hola, Furrazo desde 16 bits'
MSG_32: db 'Hola, Putote desde 32 bits', 0

times 510 - ($ - $$) db 0
dw 0xAA55 ; "Define word"
