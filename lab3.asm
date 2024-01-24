; Rezidentinė programa
; 
; 
; Nustatome 88 pertraukimą
; 
%include 'yasmmac.inc'          ; Pagalbiniai makrosai
;------------------------------------------------------------------------
org 100h                        ; visos COM programos prasideda nuo 100h
                                ; Be to, DS=CS=ES=SS !

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text                   ; kodas prasideda cia 
    Pradzia:
      jmp     Nustatymas                           ;Pirmas paleidimas
    Senas_I21:
      dw      0, 0

    procSkaiciuok:                                 ;Nadosime doroklyje 
      jmp toliau                                  ;Praleidziame teksta
    
    .pagalbiniai:                                  ;nereikalingi, bet atsargai (jei tobulinsime programa)   
      times 100  db   00 
    ; string:
		; times 255 db 00
	; temp: 
		; times 255 db 0
	adress:
		dw 00
	; file_handle:
		; dw 00
    
    toliau:                                     ;Pradedame apdorojima
      ; mov bx, dx
      
	;mov word [adress], dx 						;string kuriame įrašomi žodžiai adresas(jis duodamas iš pagr. programos)
	; mov word [file_handle], bx
	  
	
	mov cx, 4
	pushf
	call far [cs:Senas_I21]
	cmp ax, 4
	jne toliau2
		mov word [cs:adress], dx 	
	toliau2:
	
    ret                                          ; griztame is proceduros
;end procRasyk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
Naujas_I3F:                                            ; Doroklis prasideda cia
                                   
	
	macPushAll
    cmp ah, 0x3F
    jne .ne3F
    
    call procSkaiciuok

	macPopAll
	mov cx, [cs:adress]
    iret
    
	
    .ne3F
	macPopAll
    pushf
    call far [cs:Senas_I21]
	
    iret
;
;
;  Rezidentinio bloko pabaiga
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Nustatymo (po pirmo paleidimo) blokas: jis NELIEKA atmintyje
;
;

 
Nustatymas:
        ; Gauname sena 88h  vektoriu
        push    cs
        pop     ds
        mov     ah, 0x35               ; gauname sena pertraukimo vektoriu
		mov 	al, 0x21  
        int     0x21
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-35
        
        ; Saugome sena vektoriu 
        mov     [cs:Senas_I21], bx             ; issaugome seno doroklio poslinki    
        mov     [cs:Senas_I21 + 2], es         ; issaugome seno doroklio segmenta
        
        ; Nustatome nauja 1Ch (taimerio) vektoriu
        ;lea     dx, [Naujas_I88]
        mov     dx,  Naujas_I3F
        mov     ax, 0x2521                 ; nustatome pertraukimo vektoriu
        int     0x21
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-25
        
        macPutString "OK ...", crlf, '$'
        
        ;lea     dx, [Nustatymas  + 1]       ; dx - kiek baitu  
        mov dx, Nustatymas + 1
        int     0x27                       ; Padarome rezidentu
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-27
%include 'yasmlib.asm'        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


