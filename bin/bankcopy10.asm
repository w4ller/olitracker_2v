GATE    EQU   $A7E5


    STA   GATE        ; seleziona bank sorgente (A)
    LDU   #10        ; contatore = 10
loop:
    LDA   ,X+
    STA   ,Y+
    LEAU  -1,U
    CMPU  #0
    BNE   loop

    STB   GATE        ; ripristina bank originale (B = 5)
    RTS
