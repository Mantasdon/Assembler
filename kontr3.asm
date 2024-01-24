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
    Senas_I86:
      dw      0, 0

    procSkaiciuok:                                 ;Nadosime doroklyje 
      jmp toliau                                  ;Praleidziame teksta
    
    .pagalbiniai:                                  ;nereikalingi, bet atsargai (jei tobulinsime programa)   
      times 100  db   00 
	count:
		dw 00
    
	
    toliau:                                     ;Pradedame apdorojima
      mov bx, dx
      
    .ciklas: 
      cmp word [bx], 0
      je .pab
	  mov ax, [bx]
	  cmp al, ah
	  jne .tesk
		  add word [cs:count], 1
    .tesk: 
      add bx, 2
      jmp .ciklas
    .pab:
      ret                                     ; griztame is proceduros
; end procRasyk 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
Naujas_I86:                                           ; Doroklis prasideda cia
    
      macPushAll                                       ; Saugome registrus
      call procSkaiciuok
      macPopAll                                        
		
	  xor bx, bx
	  mov bx, [cs:count]
      iret                                              ; Griztame is pertraukimo 

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
        mov     ax, 3586h                 ; gauname sena pertraukimo vektoriu
        int     21h
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-35
        
        ; Saugome sena vektoriu 
        mov     [cs:Senas_I86], bx             ; issaugome seno doroklio poslinki    
        mov     [cs:Senas_I86 + 2], es         ; issaugome seno doroklio segmenta
        
        ; Nustatome nauja 1Ch (taimerio) vektoriu
        ;lea     dx, [Naujas_I88]
        mov     dx,  Naujas_I86
        mov     ax, 2586h                 ; nustatome pertraukimo vektoriu
        int     21h
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-21-25
        
        macPutString "OK ...", crlf, '$'
        
        ;lea     dx, [Nustatymas  + 1]       ; dx - kiek baitu  
        mov dx, Nustatymas + 1
        int     27h                       ; Padarome rezidentu
        ;; Zr. http://helppc.netcore2k.net/interrupt/int-27
%include 'yasmlib.asm'        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss                    ; neinicializuoti duomenys  


