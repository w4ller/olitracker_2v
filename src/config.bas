' @spec SPEC-040,SPEC-020
' @covers AC-040-01,AC-020-03
' @notes Init DAC: usa registri I/O $A7CF e $A7CD (valori v0.1 definiti in SPEC-040).


' =========================
' INIZIALIZZA DAC
' =========================
PROC inizialize_dac
    ON CPU6809 BEGIN ASM
        LDA   $A7CF
        ANDA  #$FB
        STA   $A7CF
        LDB   #$3F
        STB   $A7CD
        ORA   #$04
        STA   $A7CF
    END ASM ON CPU6809
END PROC
