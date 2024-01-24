; Programa: Nr.4 
; Uzduoties salyga: Programa, kurios pirmasis parametras - skaičius, visi kiti - failų vardai. Visus failus suskaidome į gabalus, kuriuos sudedame į failus, o jų pavadinimų priekyje įrašome bloko pavadinimą. Pvz.: jei eilutė yra split 200 failas.dat, tuomet failą failas.dat skaldomas po 200 simbolių ir sukuriami failai 1failas.dat, 2failas.dat, ir t.t
; Atliko: Ugne Baublyte

.model small
.stack 100H
JUMPS 
.data
apie db 'Programa suskaido viena tekstini faila po x simboliu', 13, 10, 9, 'antras.asm [/?] symbolAmount [ sourceFile1 [sourceFile2] [..]]', 13, 10, 13, 10, 9, '/? - pagalba', 13, 10, '$'
err_s    	db 'Source failo nepavyko atidaryti skaitymui',13,10,'$'
err_d    	db 'Destination failo nepavyko sukurti ir atidaryti rasymui',13,10,'$'
sourceF   	db 12 dup (0)
sourceFHandle	dw ?

destF   	db 13 dup (0)
destFHandle 	dw ?
	
buffer  	db 20 dup (?)
simbolis 	db ?

symbol		db 20 dup (?)
kelintas dw 0

.code
start:
	mov	ax, @data
	mov	es, ax			; es kad galetume naudot stosb funkcija: Store AL at address ES:(E)DI
 
	mov	si, 81h        		; programos paleidimo parametrai rasomi segmente es pradedant 129 (arba 81h) baitu        
 
	call	skip_spaces
	
	mov	al, byte ptr ds:[si]	; nuskaityti pirma parametro simboli
	cmp	al, 13			; jei nera parametru
	je	help			; tai isvesti pagalba
	;; ar reikia isvesti pagalba
	mov	ax, word ptr ds:[si]
	cmp	ax, 3F2Fh        	; jei nuskaityta "/?" - 3F = '?'; 2F = '/'
	je	help                 	; rastas "/?", vadinasi reikia isvesti pagalba

	call convert_symbol
	;cmp	byte ptr es:[symbol]
	push	ds si
	;lea di, sourceF
	;call	read_filename
readSourceFile:
	pop	si ds
	;; source failo pavadinimas
	lea	di, sourceF
	call	read_filename		; perkelti is parametro i eilute

	push	ds si

	mov	ax, @data
	mov	ds, ax
	
	cmp	byte ptr ds:[sourceF], '$' ; jei nieko nenuskaite
	jne	startConverting
	jmp	closeF	
startConverting:
	;; atidarom
	mov	ax, @data
	mov ds, ax
	cmp	byte ptr ds:[sourceF], '$' ; jei nieko nenuskaite
	jne	source_from_file
	
	mov	sourceFHandle, 0
	jmp	skaitom	
source_from_file:
	mov	dx, offset sourceF	; failo pavadinimas
	mov	ah, 3dh                	; atidaro faila - komandos kodas
	mov	al, 0                  	; 0 - reading, 1-writing, 2-abu
	int	21h			; INT 21h / AH= 3Dh - open existing file
	jc	err_source		; CF set on error AX = error code.
	mov	sourceFHandle, ax	; issaugojam filehandle
skaitom:
    call newFile
	mov	bx, sourceFHandle
	mov cx, 0
	mov	dx, offset buffer       ; address of buffer in dx
	mov	cl, symbol         		; kiek baitu nuskaitysim
	mov	ah, 3fh         	; function 3Fh - read from file
	int	21h
	
	mov	cx, ax          	; bytes actually read
	cmp	ax, 0			; jei nenuskaite
	jne	_6			; tai ne pabaiga

	mov	bx, sourceFHandle	; pabaiga skaitomo failo
	mov	ah, 3eh			; uzdaryti
	int	21h
	jmp	readSourceFile		; atidaryti kita skaitoma faila, jei yra
_6:
	mov	si, offset buffer	; skaitoma is cia
	mov	bx, destFHandle		; rasoma i cia

	cmp	sourceFHandle, 0
	jne	_7
	cmp	byte ptr ds:[si], 13
	je	closeF
_7:
; atrenka:
	; lodsb  				; Load byte at address DS:(E)SI into AL
	; push	cx			; pasidedam cx
	; call	replace
	; mov	ah, 40h			; INT 21h / AH= 40h - write to file
	; int	21h
	; pop	cx
	; jc	help			; CF set on error; AX = error code.
	

	; jmp	skaitom

help:
	mov	ax, @data
	mov	ds, ax
	
	mov	dx, offset apie         
	mov	ah, 09h
	int	21h

	jmp	_end
	
closeF:
	;; uzdaryti dest
	mov	ah, 3eh			; uzdaryti
	mov	bx, destFHandle
	int	21h

_end:
	mov	ax, 4c00h
	int	21h  

err_source:
	mov	ax, @data
	mov	ds, ax
	
	mov	dx, offset err_s        
	mov	ah, 09h
	int	21h

	mov	dx, offset sourceF
	int	21h
	
	mov	ax, 4c01h
	int	21h  
	
err_destination:
	mov	ax, @data
	mov	ds, ax
	
	mov	dx, offset err_d         
	mov	ah, 09h
	int	21h

	mov	dx, offset destF
	int	21h
	
	mov	ax, 4c02h
	int	21h  
	
newFile PROC near
	push ax dx bx cx
    inc kelintas
	mov ax, kelintas
	mov dx, 0
	mov bx, 10
	mov cx, 0
newFile_loop:
	div bx
	push dx
	inc cx
	cmp ax, 0
	jne newFile_loop
	
	mov di, offset destF
newFile_output:
	pop dx
	add dl, 48
	mov [di], dl
	inc di
	loop newFile_output
	
	mov si, offset sourceF
newFile_dest:
	mov al, [si]
	mov [di], al
	inc si
	inc di
	cmp byte ptr [si], '$'
	jne newFile_dest
	mov byte ptr[di], 0
	pop cx bx dx ax
	ret
newFile ENDP	

convert_symbol PROC near
	xor ax, ax
convert_loop:
	mov cl, [si]
	inc si
	cmp cl, '0'
	jb convert_end
	cmp cl, '9'
	ja convert_end
	sub cl, '0'
	mov ch, 10
	mul ch
	xor ch, ch
	add ax, cx
	jmp convert_loop
convert_end:
	ret
convert_symbol ENDP

	
skip_spaces PROC near
 
skip_spaces_loop:
	cmp byte ptr ds:[si], ' '
	jne skip_spaces_end
	inc si
	jmp skip_spaces_loop
skip_spaces_end:
	ret
	
skip_spaces ENDP

read_filename PROC near

	push	ax
	call	skip_spaces
read_filename_start:
	cmp	byte ptr ds:[si], 13	; jei nera parametru
	je	read_filename_end	; tai taip, tai baigtas failo vedimas
	cmp	byte ptr ds:[si], ' '	; jei tarpas
	jne	read_filename_next	; tai praleisti visus tarpus, ir sokti prie kito parametro
read_filename_end:
	mov	al, '$'			; irasyti '$' gale
	stosb               ; Store AL at address ES:(E)DI, di = di + 1
	pop	ax
	ret
read_filename_next:
	lodsb				; uzkrauna kita simboli
	stosb                           ; Store AL at address ES:(E)DI, di = di + 1
	jmp read_filename_start

read_filename ENDP
end start