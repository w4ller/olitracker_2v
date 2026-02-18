
INCLUDE "olitracker_2v/instruments.bas"
INCLUDE "olitracker_2v/config.bas"
'INCLUDE "olitracker_2v/playCore.bas"
INCLUDE "olitracker_2v/incrementTable.bas"
INCLUDE "olitracker_2v/volumeTable.bas"
INCLUDE "olitracker_2v/audioDeepPage.bas"
INCLUDE "olitracker_2v/asmPlayerInit.bas"
INCLUDE "olitracker_2v/asmPlayCore.bas
INCLUDE "olitracker_2v/playTicksAsm.bas"

PRINT (3000 MOD 13) 
DIM bpm AS WORD
GLOBAL bpm
bpm = 20

DIM samplesPerRow AS WORD
GLOBAL samplesPerRow
samplesPerRow = 0

DIM sampleRate AS WORD
GLOBAL sampleRate
sampleRate = 0

PROCEDURE calibrateSampleRateWithTicksPAL[ samplesPerTick, speed ]

    ' n = samplesPerTick * speed  (campioni generati da UNA chiamata ASM)
    n = samplesPerTick * speed
    CALL asm_player_init
    t0 = TI
    CALL asm_player_frame
    t1 = TI
    PRINT "T1: ";t1;" T0: ";t0
    dt = t1 - t0
    PRINT "Delta time: ";dt
    IF dt = 0 THEN
        RETURN  0
    ENDIF

    ' Evita overflow: (n*50)/dt usando quoziente+resto
    q = n / dt
    r = (n MOD dt)
    PRINT "Q: ";q
    PRINT "R: ";r;" ";n;"/";dt;(n MOD dt)
    result = (q * 50) + ((r * 50) / dt)
    PRINT "Result: ";result
    RETURN result

END PROCEDURE




' --- 2) BPM -> campioni per riga (1 riga = 1/16, BPM sul quarto) ---
PROCEDURE samplesPerRowFromBPM_RowIsSixteenth[ sampleRate, bpm ]
    RETURN (sampleRate * 15 + (bpm / 2)) / bpm
END PROCEDURE

PROCEDURE samplesPerTickFromRow[ samplesPerRow, speed ]
    RETURN (samplesPerRow + (speed/2)) / speed
END PROCEDURE

' INIZIO CALCOLO

samplesPerTick = $2AAA
PRINT "BPM: ";bpm
PRINT "Sample per tick iniziali: ";samplesPerTick

sampleRate = calibrateSampleRateWithTicksPAL[samplesPerTick, 6]
PRINT "sampleRate: ";sampleRate

samplesPerRow = samplesPerRowFromBPM_RowIsSixteenth[sampleRate, bpm]
PRINT "samplesPerRow: ";samplesPerRow
samplesPerTick = samplesPerTickFromRow[samplesPerRow, 6]
PRINT "samplesPerTick: ";samplesPerTick
PRINT "samplePerRow finale senza resto: ";(samplesPerTick * 6)