' @spec SPEC-010,SPEC-030
' @covers AC-030-01,AC-030-02
' @notes bpm = PEEK(VARPTR(header)+2); index = samplesPerTick; speed=6; sample_rate=11497 (v0.1).



DIM bpm AS WORD
bpm = PEEK(VARPTR(header) +2)
PRINT "BPM: ";HEX$(bpm * 2)
DIM tFine AS WORD
DIM octave AS WORD
GLOBAL octave
octave = (60 * 50) / ((bpm) * 4)
'-------------------------------
'Global var for ASM play routine
'-------------------------------
DIM trackPos AS WORD
DIM trackLines AS WORD


'DIM addrPos AS WORD 
'GLOBAL addrPos
' Delcared as global overwhise are not seen while compiling ASM
GLOBAL trackPos
GLOBAL trackLines

' Initiliaze var
trackPos = 0
trackLines = (songSize -1) * (channelLen * 2)


DIM index AS WORD
GLOBAL index
index = 0


DIM samplesPerRow AS WORD
GLOBAL samplesPerRow
samplesPerRow = 0

DIM sampleRate AS WORD
GLOBAL sampleRate
sampleRate = 0

CONST sample_rate = 11497
CONST speed = 6




PROCEDURE samplesPerRow_RowIsSixteenth[ bpm ]
    q = sample_rate / bpm
    r = sample_rate MOD bpm   
    RETURN (q * 15) + ((r * 15) / bpm)
END PROCEDURE


PROCEDURE samplesPerTickFromRow[ spr ]
    RETURN (spr + (speed/2)) / speed
END PROCEDURE

' uso:

samplesPerRow = samplesPerRow_RowIsSixteenth[bpm]
'PRINT "Sample per rowx: ";samplesPerRow
samplesPerTick = samplesPerTickFromRow[samplesPerRow]
'PRINT "Sample per tick: ";samplesPerTick
index = samplesPerTick
'PRINT index

PROCEDURE play_loop
    CALL asm_player_init
    DO
        PRINT "aggiorno row";HEX$(VARPTR(rowBuf));" ";HEX$(trackBase);" ";songBank

        BANK READ songBank FROM (trackBase + trackPos) TO VARPTR(rowBuf) SIZE 10
        CALL asm_player_frame
    LOOP
END PROCEDURE
