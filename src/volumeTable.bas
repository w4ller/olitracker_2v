' @spec SPEC-080
' @covers AC-080-02,AC-080-03
' @notes volumeTableAddr(n) = VARPTR(volumeTable) + 22*n per n=0..15 (v0.1).


DIM volumeTable AS BUFFER
volumeTable = LOAD("olitracker_2v/volumetables.bin")
'songSize = SIZE(binarySong)


DIM volumeTableAddr(16) AS WORD
GLOBAL volumeTableAddr
FOR n = 0 TO 15
 volumeTableAddr(n) = VARPTR(volumeTable) + (22 * n)
NEXT



