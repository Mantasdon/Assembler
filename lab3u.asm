; 
; Naudojame su kontr3.com rezidentu 


%include 'yasmmac.inc'     
;------------------------------------------------------------------------
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 

   startas:                     ; nuo cia vykdomas kodas
   ; iki int'o
   mov ah, 09
   mov dx, pranesimas
   int 0x21

   ; int'as:
   	macPutString 'Ivesk skaitomo failo varda: ', crlf, '$'
	mov al, 255                  ; ilgiausia eilutė
	mov dx, file_in     ; 
	call procGetStr              
	macNewLine
	
	mov dx, file_in
    call procFOpenForReading
	mov word [file_handle], bx
	
	mov cx, 1
	
	loop1:
	push cx
	mov dx, string
    mov ah, 0x3F
	int 0x21

   ; po int'o
   mov dx, cx
   call procPutStr
   macNewLine
   pop cx
   loop loop1


   mov ah, 0x4c                  ; tiesiog bagiame
   int 0x21
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .data                   ; duomenys

   pranesimas:
      db 'LABAS, bAndome nAudoti int 0x21... ', 0x0D, 0x0A, '$', 00
	file_in:
		times 255 db 00
	string:
		times 255 db 00
	file_handle:
		dw 0


%include 'yasmlib.asm'   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


