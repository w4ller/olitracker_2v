' binary song banked
DIM residentMemoryArray AS BYTE(10300)
binarySong := LOAD("assets/80.2..bin") BANKED
binarySong2 := LOAD("assets/80.bin") BANKED
binarySong3 := LOAD("assets/arpeggio.bin") BANKED
addr = VARBANKPTR(binarySong)
songBank = VARBANK(binarySong)
GLOBAL addr
GLOBAL songBank

PRINT HEX$(addr)
PRINT songBank