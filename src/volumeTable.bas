' @spec SPEC-080
' @covers AC-080-02,AC-080-03
' @notes volumeTableAddr(n) = VARPTR(volumeTable) + 22*n per n=0..15 (v0.1).


DIM volumeTable AS BYTE(352) FOR BANK READ
volumeTableBanked := LOAD("assets/volumetables.bin")  BANKED
'songSize = SIZE(binarySong)

bankVol = VARBANK(volumeTableBanked)
addrVol = VARBANKPTR(volumeTableBanked)

BANK READ bankVol FROM addrVol TO VARPTR(volumeTable) SIZE 352

DIM volumeTableAddr(16) AS WORD FOR BANK READ
GLOBAL volumeTableAddr
FOR n = 0 TO 15
 volumeTableAddr(n) = VARPTR(volumeTable) + (22 * n)
NEXT

PRINT "vol: ";HEX$(VARPTR(volumeTable))


