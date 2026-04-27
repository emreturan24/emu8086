org 100h

jmp start

; -------------------
; DATA
; -------------------
x1 db 35       
y1 db 10       
yonX db 1
yonY db 1

x2 db 38       
y2 db 11       

n1 db 3        
n2 db 2        
skor db 0
hedef db 10
sure db 30

lastTick dw 0

msg_skor db 'SKOR:  $', '$'
msg_hedef db ' HEDEF: $', '$'
msg_sure db ' SURE:  $', '$'
msg_over db ' OYUN BITTI!$', '$'

; -------------------
; FONKS�YONLAR
; -------------------
set_cursor:
    mov ah, 02h
    mov bh, 0
    int 10h
    ret

print_char:
    mov ah, 0Eh
    int 10h
    ret

; Say�y� (negatifse i�aretli) ve tek hane ise s�f�rs�z yazd�ran fonksiyon
print_number:
    push ax
    push cx
    push dx

    ; Say� negatif mi kontrol et (8 bit signed: 128-255 aras� negatiftir)
    cmp al, 0
    jge pozitif_hazirla
    
    push ax
    mov al, '-'         ; Negatifse eksi bas
    call print_char
    pop ax
    neg al              ; Say�y� pozitife �evir

pozitif_hazirla:
    xor ah, ah
    mov cl, 10
    div cl              ; AL = Onlar, AH = Birler
    
    mov dl, ah          ; Birler basama��n� sakla
    
    cmp al, 0           ; Onlar basama�� 0 m�?
    je sadece_birler    ; 0 ise yazd�rma (08 yerine 8 yazmas� i�in)
    
    add al, 30h         ; Onlar basama��n� bas
    call print_char

sadece_birler:
    mov al, dl
    add al, 30h         ; Birler basama��n� bas
    call print_char

    ; Say� bas�ld�ktan sonra arkas�nda kalan izleri silmek i�in bir bo�luk bas
    mov al, ' '
    call print_char

    pop dx
    pop cx
    pop ax
    ret

delay:
    push ax
    push bx
    push dx
    mov ah, 00h
    int 1Ah
    mov bx, dx
w_wait:
    mov ah, 00h
    int 1Ah
    sub dx, bx
    cmp dx, 2      
    jb w_wait
    pop dx
    pop bx
    pop ax
    ret

generate_random:
    mov ah, 2Ch     
    int 21h         
    mov al, dl
    xor ah, ah
    mov cl, 19      
    div cl          
    mov al, ah
    sub al, 9       
    ret

input:
    mov ah, 01h     
    int 16h
    jz no_key       
    mov ah, 00h     
    int 16h         
    cmp al, 'w'
    je move_up
    cmp al, 's'
    je move_down
    cmp al, 'a'
    je move_left
    cmp al, 'd'
    je move_right
    jmp no_key
move_up:    dec y2
    jmp no_key
move_down:  inc y2
    jmp no_key
move_left:  dec x2
    jmp no_key
move_right: inc x2
no_key:
    ret

; -------------------
; START
; -------------------
start:
    mov ax, 3h
    int 10h
    mov ah, 00h
    int 1Ah
    mov lastTick, dx

game_loop:
    ; --- 1. SURE KONTROL ---
    mov ah, 00h
    int 1Ah
    mov ax, dx
    sub ax, lastTick
    cmp ax, 18
    jb skip_time
    mov lastTick, dx
    dec sure
skip_time:
    cmp sure, 0
    jne devam
    mov dh, 12
    mov dl, 30
    call set_cursor
    lea dx, msg_over
    mov ah, 09h
    int 21h
    mov ah, 4Ch
    int 21h

devam:
    ; --- 2. ESKIYI SIL (Geni�letilmi� Silme) ---
    mov dh, y1
    mov dl, x1
    call set_cursor
    mov al, ' '
    call print_char
    call print_char
    call print_char ; Negatif ve 2 hane ihtimaline kar�� 3 bo�luk

    mov dh, y2
    mov dl, x2
    call set_cursor
    mov al, ' '
    call print_char
    call print_char
    call print_char

    ; --- 3. HAREKET VE INPUT ---
    mov al, x1
    add al, yonX
    mov x1, al
    cmp x1, 45      
    jge ch_x
    cmp x1, 32      
    jle ch_x
    jmp m_y
ch_x: neg yonX        
m_y:
    mov al, y1
    add al, yonY
    mov y1, al
    cmp y1, 14      
    jge ch_y
    cmp y1, 8       
    jle ch_y
    jmp drw
ch_y: neg yonY        

drw:
    call input

    ; --- 4. CIZIM ---
    mov dh, y1
    mov dl, x1
    call set_cursor
    mov al, n1
    call print_number

    mov dh, y2
    mov dl, x2
    call set_cursor
    mov al, n2
    call print_number

    ; --- 5. CARPISMA ---
    mov al, x1
    sub al, x2
    jns xp
    neg al
xp: cmp al, 1
    ja p_ui
    mov al, y1
    sub al, y2
    jns yp
    neg al
yp: cmp al, 1
    ja p_ui

    ; Carp�sma oldu
    mov al, n1
    add al, n2
    add skor, al
    mov al, skor
    cmp al, hedef
    jb d2
    add hedef, 5
d2:
    call generate_random
    mov n1, al
    call generate_random
    mov n2, al

p_ui:
    ; --- UI TABELASI ---
    mov dh, 0
    mov dl, 30
    call set_cursor
    lea dx, msg_skor
    mov ah, 09h
    int 21h
    mov al, skor
    call print_number

    mov dh, 1
    mov dl, 30
    call set_cursor
    lea dx, msg_hedef
    mov ah, 09h
    int 21h
    mov al, hedef
    call print_number

    mov dh, 2
    mov dl, 30
    call set_cursor
    lea dx, msg_sure
    mov ah, 09h
    int 21h
    mov al, sure
    call print_number

    call delay
    jmp game_loop

end start