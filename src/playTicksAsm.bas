' @spec SPEC-010,SPEC-030
' @covers AC-030-01,AC-030-02
' @notes bpm = PEEK(VARPTR(header)+2); index = samplesPerTick; speed=6; sample_rate=11497 (v0.1).

DIM songCopy AS BYTE (22) FOR BANK READ
songCopy(0) = $B7
songCopy(1) = $a7 
songCopy(2) = $e5 
songCopy(3) = $ce 
songCopy(4) = $00 
songCopy(5) = $0a 
songCopy(6) = $a6 
songCopy(7) = $80 
songCopy(8) = $a7 
songCopy(9) = $a0 


songCopy(10) = $33 
songCopy(11) = $5f 
songCopy(12) = $11
songCopy(13) = $83 

songCopy(14) = $00 
songCopy(15) = $00 
songCopy(16) = $26 
songCopy(17) = $f4 
songCopy(18) = $f7 
songCopy(19) = $a7 
songCopy(20) = $e5
songCopy(21) = $39 

songCopyAddr = VARPTR(songCopy)
GLOBAL songCopyAddr

PRINT "song copy addr "; HEX$(songCopyAddr)


DIM bpm AS WORD
bpm = PEEK(VARPTR(header) +2) + 8
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

DIM defBank AS BYTE = 7
GLOBAL defBank

PROCEDURE play_loop
    CALL asm_player_init
    DO
        SYS songCopyAddr WITH REG(A)=songBank, REG(B)=defBank, REG(X)=(trackBase+trackPos), REG(Y)=VARPTR(rowBuf) ON CPU6809
        CALL asm_player_frame
    LOOP
END PROCEDURE
