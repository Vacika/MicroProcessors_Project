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
    nizaporaka dw 20 dup (?) 
    redenbroj dw 0d
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
    
    ;; Ova funkcionira na nacin vakov : Baraj prva cifra, ako najdes prva cifra baraj vtora cifra, ako najdes proveri dali e XXText+, XX+-, XX- ili ostanato.
    barajprvacifra:
    
    ;;RESET
        mov redenbroj,0h
        mov x1,0h
        mov x2,0h
        
        
        
        mov AH,01h
        int 21h
        mov AH,0h 
        sub AL,30h
        cmp AX,2
        jge barajprvacifra  ;; ako prvata cifra e >= 2 ( t.e ako brojot na porakata e >=20) 
        cmp AX,0        ;; ako e < 0
        jl barajprvacifra
         
        mov x1, AL         ; AKO cifrata e 0 ili 1
     
    barajvtoracifra:    
        mov AH,01h
        int 21h
        sub AL,30h 
        
        cmp AL,0 ;; proverka dali e broj vtoratacifra
        jl barajprvacifra
        cmp AL,9 ;; > 9
        jg barajprvacifra
        mov x2,AL        ;; AKO E IzMEGJU 0 i 9
        
        mov AL,x1
        mov BL,10d
        mul BL;; pomnozi prva cifra od redniot broj so 10 
        add AL,x2 ;; dodaj vtorata cifra od redniot broj
        mov redenbroj,AX
        
   
   procitanidvecifri:
        mov AH,01h
        int 21h
    
        cmp AL,2Dh ; DALI E XX-   
        je izbrisiporaka
        cmp AL,2Bh ; DALI E XX+ 
        je proveriminusposleplus  
        
        ;;PROVERKA DALI E BROJ, bidejki ne e -/+
        cmp AL,30h ;; < 0
        jl barajprvacifra
        cmp AL,39h ;; > 9
        jg proveritekst
        
        cmp AL,32h        
        jge barajprvacifra ; brojce>2
         
        ; brojce<2 i brojce>0
        sub AL,30h
        mov x1,AL
        jmp barajvtoracifra  ;AKO E BROJCE posle XX,t.e XXX i e <2 a >=0 togas odi baraj vtora cifra
        
        proveritekst:
        ;AKO NE E NITU + NITU - NITU BROJ, PROVERKA DALI E TEKST
        cmp AL,041h ;; Asci kod za A
        jl barajprvacifra
        cmp AL,5Ah
        jg barajprvacifra ;; Ako ne e nitu tekst, nitu +, nitu -,nitu broj, togas baraj novi cifri 
        
        ;; ZNACI E TEKST  
        
        ;; TODO: kriptiraj character i vnesi vo memorija/stek/niza
        lea BX,nizaporaka
        mov [BX],AL
        add BX,2  
        jmp najdovmetekst
        
   najdovmetekst: 
   
        
        MOV AH,01h
        int 21h 
        
        ; dali e XXtext+
        cmp AL, 2Bh
        je krajtekst
        
        ; dali e XXtextX(proverka dali e vnesen broj izmegju textot, sto bi bilo invalid command)
        cmp AL,39h
        jg proveribukva ;; >9 znaci ne e broj 
        cmp AL,30h        
        jl barajprvacifra   ;;<0 ne e broj nitu bukva(asci kod e > od 48h za bukvite)
        
        
        ;;OVOJ DEL E VO SLUCAJ DA E BROJ, proverka dali e <2:
        cmp AL,32h
        jge barajprvacifra;; ako e>=2 
        sub AL,30h
        mov x1,AL
        jmp barajvtoracifra;; ako e < 2. 
        
        
        proveribukva:
            ;; PROVERKA DALI E BUKVA
            cmp AL,41h ;; C< 65 Asci kod za A  
            jl barajprvacifra
            cmp AL,5Ah
            jg barajprvacifra ;C> 90 ASCII kod za Z
            
            ;;AKO E BUKVA:
            ;;TODO: KRIPTIRAJ CHARACTER I VNESI VO NIZA/MEMORIJA
            mov [BX],AL
            add BX,2
            jmp najdovmetekst  
        
        
         
      
        
        
        
 
       
        
        
        
   proveriminusposleplus: 
        mov AH,01h      ;; citaj uste eden karakter
        int 21h 
        cmp AL,2Dh; Proveri dali imame XX+- komanda
        je procitajporaka ;; ako imame odi na delot procitajporaka    
        mov x1,0          ;;Ako nemame XX+-(imame samo XX+C , sto ne znaci nisto, no morame da proverime dali C e 0 ili 1)
        mov x2,0          ;;reset
        mov redenbroj,0d
        ;;;;;;;;;;; PROVERKA DALI PROCITANIOT KARAKTER C E BROJ < 2 (BIDEJKI NE E MINUS A VEKJE SME GO PROCITALE)
        cmp AL,32h
        jge barajprvacifra  ;; ako prvata cifra e >= 2 ( t.e ako brojot na porakata e >=20) 
        cmp AL,30h        ;; ako e < 0
        jl barajprvacifra    
        sub AL,30h 
        mov x1,AL     
        jmp barajvtoracifra    ;; vlezot bil XX+C, kade C = 0 ili 1 , pa go iskoristuvame da barame nova komanda.
        
        
        
 
   procitajporaka: 
   ;;TODO: PROCITAJ PORAKA
    
   izbrisiporaka:                                                
       ; TODO:OVDE NAJDI JA PORAKATA SO REDEN BROJ X1*10 + X2 i izbrisi ja
       
       mov AH,01h
       int 21h
       cmp AL,2Dh ; dali imame dva minusi za kraj
       je kraj 
       ;; ako ne e kraj(ako ne e XX-- proveri dali e broj izmegju 0 i 2)
       cmp AL,32h
       jge barajprvacifra;; ako e>=2  
       cmp AL,30h
       jl barajprvacifra ;<0
       
       sub AL,30h;odzemame brojceto
       mov x1,AL
       jmp barajvtoracifra;; imame vekje brojce izmegju 0 i 2 :)
       
       
       
       
   
     
     krajtekst: 
        jmp barajprvacifra
        
        
       
        
        
        
       
    
    kraj:
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
