' @spec SPEC-010,SPEC-050
' @covers AC-010-01,AC-010-02,AC-010-03
' @notes headerLen=5; rowBuf=10 bytes; song banked in binarySong (VARBANK/VARBANKPTR).

DIM songSize AS WORD
GLOBAL songSize

DIM headerLen
GLOBAL headerLen
headerLen = 5

DIM channelLen 
GLOBAL channelLen
channelLen = 5

DIM header(5) AS BYTE FOR BANK READ
GLOBAL header
PRINT "header: " ;HEX$(VARPTR(header))



' binary song banked
binarySong := LOAD("olitracker_2v/future1.bin") BANKED
addr = VARBANKPTR(binarySong)
songBank = VARBANK(binarySong)
GLOBAL addr

PRINT HEX$(addr)
PRINT songBank





' copy song header from banked binary song
BANK READ songBank FROM addr TO VARPTR(header) SIZE 5

songSize = PEEKW(VARPTR(header))


'PRINT "song bank: " ;HEX$(addr)


' una riga = 10 byte (2 canali * 5)
DIM rowBuf(10) AS BYTE
GLOBAL rowBuf

' base track nel file banked: addr + headerLen
DIM trackBase AS WORD
GLOBAL trackBase
trackBase = addr + headerLen


INCLUDE "olitracker_2v/instruments.bas"
INCLUDE "olitracker_2v/config.bas"
INCLUDE "olitracker_2v/incrementTable.bas"
INCLUDE "olitracker_2v/volumeTable.bas"
INCLUDE "olitracker_2v/audioDeepPage.bas"
INCLUDE "olitracker_2v/asmPlayerInit.bas"

baseBank = BANK()
GLOBAL baseBank

INCLUDE "olitracker_2v/asmPlayCore.bas
INCLUDE "olitracker_2v/playTicksAsm.bas"


CALL inizialize_dac





'PRINT HEX$(addr)
'PRINT "Play songxxxx"
'CALL play_loop
