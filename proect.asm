; multi-segment executable file template.
;-41d e da go najs redniot broj na BUKVATA od azbukata
;SETX (Set na N brojot)
;XXtext+(xx e reden broj na porakata)
;XX+-(CITA poraka so reden broj XX)
;XX-(Brisi poraka so reden broj XX)
;XX < 20, ottuka sledi XX < 50h


data segment
    ; add your data here!
    pkey db "press any key...$" 
    N dw 100d
    x1 db 0d
    x2 db 0d 
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    ;; Ova funkcionira na nacin vakov : Baraj prva cifra, ako najdes prva cifra baraj vtora cifra, ako najdes proveri dali e komanda nekoja ili vnesuvanje na tekst
    barajprvacifra:
        mov AH,01h
        int 21h
        mov x1,AL
        cmp AL,50h
        jge barajprvacifra  ;; ako prvata cifra e >= 2 ( t.e ako brojot na porakata e >=20) 
        cmp AL,47h        ;; ako e < 0
        jle barajprvacifra 
        mov x1, AL         ; AKO cifrata e 0 ili 1
     
    barajvtoracifra:    
        mov AH,01h
        int 21h
        cmp AL,48h ;; proverka dali e broj vtoratacifra
        jl barajprvacifra
        cmp AL,57h ;; > 9
        jg barajprvacifra
        mov x2,AL        ;; AKO E IzMEGJU 0 i 9
        
   
   procitanidvecifri:
        mov AH,01h
        int 21h
        cmp AL,45h ; DALI E -   
        je izbrisiporaka
        cmp AL,43h ; DALI E + 
        je proveriminusposleplus  
        
        ;AKO NE E NITU + NITU - PROVERKA DALI E TEKST
        cmp AL,065h ;; Asci kod za A
        jl barajprvacifra
        cmp AL,090h
        jg barajprvacifra ;; Ako ne e nitu tekst, nitu +, nitu -, togas baraj novi cifri
        
        
        
   proveriminusposleplus: 
        mov AH,01h      ;; citaj uste eden karakter
        int 21h 
        cmp AL,45h; Proveri dali imame XX+- komanda
        je procitajporaka ;; ako imame odi na delot procitajporaka    
        mov x1,0          ;;Ako nemame XX+-(imame samo XX+C , sto ne znaci nisto, no morame da proverime dali C e 0 ili 1)
        mov x2,0          ;;reset
        
        ;;;;;;;;;;; PROVERKA DALI PROCITANIOT KARAKTER C E BROJ < 2 (BIDEJKI NE E MINUS A VEKJE SME GO PROCITALE)
        cmp AL,50h
        jge barajprvacifra  ;; ako prvata cifra e >= 2 ( t.e ako brojot na porakata e >=20) 
        cmp AL,47h        ;; ako e < 0
        jle barajprvacifra    
        mov x1,AL     
        jmp barajvtoracifra    ;; vlezot bil XX+C, kade C = 0 ili 1 , pa go iskoristuvame da barame nova komanda.
        
        
        
   procitajporaka:
   
   
   
        
        
   izbrisiporaka:                                                
   
       ; OVDE NAJDI JA PORAKATA SO REDEN BROJ X1*10 + X2 i izbrisi ja
          
       mov AH,01h
       int 21h
       cmp AL,45h ; dali imame dva minusi za kraj
       je kraj
   
   
   
   
   
        
        
       
        
        
        
       
    
    kraj:
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
