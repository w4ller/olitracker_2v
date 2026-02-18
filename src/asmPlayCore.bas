' @spec SPEC-050,SPEC-010,SPEC-030,SPEC-060
' @covers AC-050-03,AC-010-03,AC-030-03,AC-060-01,AC-060-02,AC-060-04
' @notes Decode rowBuf[0..9]; note sentinel 96/97/98; TRACKPOS += $000A; tickcnt=6 (v0.1).


PROCEDURE asm_player_frame
ON CPU6809 BEGIN ASM
   PSHS DP
    LDA _audioDPPage
    TFR A,DP


; --- offsets ---
TMP1 EQU 36

    LDX  #_rowBuf

; ---------- CH1 note -> INC1 ----------
    LDA  0,X
    CMPA #97          ; repeat ch1?
    BEQ  ch1_skip_inc
    CMPA #96          ; pause?
    BNE  ch1_lookup_inc
    LDD  #$0000
    STD  <INC1
    BRA  ch1_done_inc
ch1_lookup_inc:
    ; D = note*2 (16-bit)
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INCTABP
    LDD  D,U
    STD  <INC1
ch1_done_inc:
ch1_skip_inc:

; ---------- CH1 inst -> INST1P ----------
    LDA  1,X
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INSTTABP
    LDD  D,U
    STD  <INST1P

; ---------- CH1 vol -> VOL1P ----------
    LDA  2,X
    ;CLRB
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <VOLTABP
    LDD  D,U
    STD  <VOL1P

; ---------- CH2 note -> INC2 ----------
    LDA  5,X
    CMPA #98          ; repeat ch2?
    BEQ  ch2_skip_inc
    CMPA #96          ; pause?
    BNE  ch2_lookup_inc
    LDD  #$0000
    STD  <INC2
    BRA  ch2_done_inc
ch2_lookup_inc:
    ;CLRB
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INCTABP
    LDD  D,U
    STD  <INC2
ch2_done_inc:
ch2_skip_inc:

; ---------- CH2 inst -> INST2P ----------
    LDA  6,X
    ;CLRB
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INSTTABP
    LDD  D,U
    STD  <INST2P

; ---------- CH2 vol -> VOL2P ----------
    LDA  7,X
    ;CLRB
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <VOLTABP
    LDD  D,U
    STD  <VOL2P

; ---------- PLAY (tuo dac loop, DP version) ----------
    LDA  #6
    STA  <TICKCNT
tickLoop:
    LDD  <INC1
    ADDD <DINC1
    STD  <INC1

    LDD  <INC2
    ADDD <DINC2
    STD  <INC2

    LDY  <SPT
    BEQ  tickDone

sampleLoop:
    LDD  <ACC1
    ADDD <INC1
    STD  <ACC1
    LDX  <INST1P
    LDB  A,X
    LDU  <VOL1P
    LDA  B,U
    STA  <TMP1

    LDD  <ACC2
    ADDD <INC2
    STD  <ACC2
    LDX  <INST2P
    LDB  A,X
    LDU  <VOL2P
    LDA  B,U
    ADDA <TMP1
    STA  $A7CD

    LEAY -1,Y
    BNE  sampleLoop

tickDone:
    DEC  <TICKCNT
    BNE  tickLoop

; ---------- advance trackPos (+=10, wrap) ----------
    LDD  <TRACKPOS
    ADDD #$000A
    CMPD <TRACKLINES
    BLS  storePos
    LDD  #$0000
storePos:
    STD  <TRACKPOS      ; salva in TRACKPOS (direct page)
    STD  _trackPos      ; salva anche in _trackPos (indirizzamento esteso)
    PULS DP
END ASM ON CPU6809
END PROCEDURE
