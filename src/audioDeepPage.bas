' @spec SPEC-050,SPEC-020
' @covers AC-050-00,AC-020-02
' @notes Calcola _audioDPPage e _audioDPBase allineando VARPTR(audioDP) a xx00 (pagina 256B).


' 512 byte per trovare una pagina allineata
DIM audioDP(512) AS BYTE
GLOBAL audioDP

DIM audioDPBase AS WORD
DIM audioDPPage AS WORD
GLOBAL audioDPBase
GLOBAL audioDPPage

DIM p AS WORD
p = VARPTR(audioDP)

DIM byteBasso AS BYTE

' pagina = high byte di p (p/256), ma se p non è xx00 sali di 1 pagina
audioDPPage = p / $100
'PRINT "byte alto: "; HEX$(audioDPPage)
byteBasso = p MOD $100
'PRINT "byte basso: "; HEX$(byteBasso) 
IF byteBasso <> 0 THEN
    audioDPPage = audioDPPage + 1
ENDIF
audioDPBase = audioDPPage * $100

'PRINT "audioDPBase ";HEX$(audioDPBase)



