' @spec SPEC-050,SPEC-010,SPEC-030
' @covers AC-050-01,AC-050-02
' @notes Gli offset DP (ACC1..VOLTABP) sono ABI interna e devono matchare asm_player_frame.



PROCEDURE asm_player_init
ON CPU6809 BEGIN ASM

; --- offsets (incollali uguali qui) ---
ACC1 EQU 0
ACC2 EQU 2
INC1 EQU 4
INC2 EQU 6
DINC1 EQU 8
DINC2 EQU 10
INST1P EQU 12
INST2P EQU 14
VOL1P EQU 16
VOL2P EQU 18
SPT EQU 20
TICKCNT EQU 22
SONGBASE EQU 24
TRACKPOS EQU 26
TRACKLINES EQU 28
INCTABP EQU 30
INSTTABP EQU 32
VOLTABP EQU 34

   PSHS DP   

   LDA  _audioDPPage
   TFR  A,DP

    ; init audio
    LDD  #$8000
    STD  <ACC1
    STD  <ACC2
    LDD  #$0000
    STD  <INC1
    STD  <INC2
    STD  <DINC1
    STD  <DINC2

    ; cache tables base addresses
    LDD  #_incTable
    STD  <INCTABP
    LDD  #_instruments
    STD  <INSTTABP
    LDD  #_volumeTableAddr
    STD  <VOLTABP

    ; trackpos = 0
    LDD  #$0000
    STD  <TRACKPOS

    ; tracklines = (songSize-1) * (channelLen*2)  (come fai ora in BASIC)
    ; per ora leggiamo il valore già calcolato in _trackLines e lo copiamo
    LDD  _trackLines
    STD  <TRACKLINES

    ; samplesPerTick = index (già calcolato in BASIC)
    LDD  _index
    STD  <SPT

    PULS DP 

END ASM ON CPU6809
END PROCEDURE
