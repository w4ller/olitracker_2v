' @spec SPEC-010,SPEC-070,SPEC-020
' @covers AC-010-04,AC-070-01,AC-070-02
' @notes wavePosition = _addr + _headerLen + (_songSize * _channelLen * 2); instruments(n) = instRam + n*256 + 128.

' instruments memory space loaded in resident memory
DIM instRam(512) AS BYTE FOR BANK READ
GLOBAL instRam 

DIM wavePosition 
wavePosition = addr + headerLen + (songSize * channelLen * 2)
'PRINT "wave pov ";HEX$(VARPTR(wavePosition))
GLOBAL wavePosition
DIM inst AS BYTE
inst = PEEK(VARPTR(header)+4)
' copy instruments from banked binary song
'SYS copyAddr WITH REG(A)=songBank, REG(B)=VARBANK(instRam), REG(X)=addr, REG(Y)=VARPTR(instRam), REG(U)=inst

BANK READ songBank FROM wavePosition TO VARPTR(instRam) SIZE 512

DIM instruments AS ADDRESS(8)
GLOBAL instruments


'PRINT "inst: ";HEX$(inst)
FOR n = 0 TO inst-1
    src = wavePosition + (n * 256)
    'PRINT HEX$(src)
    dst = VARPTR(instRam) + (n * 256)
    'PRINT HEX$(dst)
    BANK READ songBank FROM src TO dst SIZE 256

    instruments(n) = VARPTR(instRam) + (n * 256) + 128
NEXT
'PRINT "inst loaded in memory: ";HEX$(VARPTR(instRam))
