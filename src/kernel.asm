[BITS 32] ; empezamos en 32 de una porque estamos en el kernel

global _start

extern k_main

_start: 
	
	call k_main
	jmp $

times 512-($ - $$) db 0 ;  rellenar los bytes hasta 512 con 0
