' @spec SPEC-010,SPEC-070,SPEC-020
' @covers AC-010-04,AC-070-01,AC-070-02
' @notes wavePosition = _addr + _headerLen + (_songSize * _channelLen * 2); instruments(n) = instRam + n*256 + 128.

' instruments memory space loaded in resident memory
DIM instRam(512) AS BYTE FOR BANK READ
GLOBAL instRam 
PRINT "instRam: ";HEX$(VARPTR(instRam))

DIM instRamPtr AS WORD
GLOBAL instRamPtr
instRamPtr = VARPTR(instRam)
PRINT "indirizzo a buf strumenti: "; HEX$(instRamPtr)

DIM wavePosition 
wavePosition = addr + headerLen + (songSize * channelLen * 2)
PRINT "wave pov ";HEX$(wavePosition)
GLOBAL wavePosition
DIM inst AS BYTE
inst = PEEK(VARPTR(header)+4)
' copy instruments from banked binary song
'SYS copyAddr WITH REG(A)=songBank, REG(B)=VARBANK(instRam), REG(X)=addr, REG(Y)=VARPTR(instRam), REG(U)=inst

'BANK READ songBank FROM wavePosition TO VARPTR(instRam) SIZE 3315

DIM instruments AS ADDRESS(16) FOR BANK READ
GLOBAL instruments


'PRINT "inst: ";HEX$(inst)
FOR n = 0 TO inst-1
    'src = wavePosition + (n * 256)
    'PRINT HEX$(src)
    'dst = VARPTR(instRam) + (n * 256)
    'PRINT HEX$(dst)
    'BANK READ songBank FROM src TO dst SIZE 256

    instruments(n) = wavePosition + (n * 256)
    PRINT HEX$(instruments(n))
NEXT
PRINT "inst loaded in memory: ";HEX$(VARPTR(instRam))


PRINT "wave: ";HEX$(wavePosition)
PRINT "inst0: ";HEX$(instruments(0))  
PRINT "inst1: ";HEX$(instruments(1))
PRINT "diff: ";HEX$(instruments(1)-instruments(0))