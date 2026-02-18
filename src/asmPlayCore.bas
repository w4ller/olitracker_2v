' @spec SPEC-050,SPEC-010,SPEC-030,SPEC-060
' @covers AC-050-03,AC-010-03,AC-030-03,AC-060-01,AC-060-02,AC-060-04
' @notes Decode rowBuf[0..9]; note sentinel 96/97/98; TRACKPOS += $000A; tickcnt=6 (v0.1).


PROCEDURE asm_player_frame
ON CPU6809 BEGIN ASM
   PSHS DP
    LDA _audioDPPage
    TFR A,DP

; --- offsets (match asm_player_init) ---
TMP1   EQU 43   ; byte temporaneo (zona SIGNW/DELTAW libera)

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
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <VOLTABP
    LDD  D,U
    STD  <VOL1P

; ---------- CH1 FX -> SL1 (signed) ----------
    LDA  3,X          ; FX1A
    CMPA #1
    BEQ  fx1_up
    CMPA #2
    BEQ  fx1_down
    CLR  <SL1
    BRA  fx1_done
fx1_up:
    LDA  4,X          ; FX1B
    STA  <SL1         ; positivo
    BRA  fx1_done
fx1_down:
    LDA  4,X
    NEGA
    STA  <SL1         ; negativo
fx1_done:

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
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INSTTABP
    LDD  D,U
    STD  <INST2P

; ---------- CH2 vol -> VOL2P ----------
    LDA  7,X
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <VOLTABP
    LDD  D,U
    STD  <VOL2P

; ---------- CH2 FX -> SL2 (signed) ----------
    LDA  8,X          ; FX2A
    CMPA #1
    BEQ  fx2_up
    CMPA #2
    BEQ  fx2_down
    CLR  <SL2
    BRA  fx2_done
fx2_up:
    LDA  9,X          ; FX2B
    STA  <SL2
    BRA  fx2_done
fx2_down:
    LDA  9,X
    NEGA
    STA  <SL2
fx2_done:

; ---------- PLAY (dac loop + FX tick 1..5) ----------
    LDA  #6
    STA  <TICKCNT
    CLR  <TICKIDX          ; tick index 0..5

tickLoop:
    ; ---- tickidx update ----
    INC  <TICKIDX
    LDA  <TICKIDX
    CMPA #6
    BLO  tickidx_ok
    CLR  <TICKIDX
tickidx_ok:

    ; ---- per-tick detune (DINC) ----
    LDD  <INC1
    ADDD <DINC1
    STD  <INC1
    LDD  <INC2
    ADDD <DINC2
    STD  <INC2

    ; ---- FX: solo tick 1..5 ----
    LDA  <TICKIDX
    BNE  fx_do
    BRA  fx_done
fx_do:

; ===== CH1: portamento su INC1 (SL1 signed) =====
    LDA  <SL1
    STA  <MAG1
    BPL  ch1_mag_ok
    NEGA
    STA  <MAG1
ch1_mag_ok:
    ; delta = ((INC1 >> 4) * MAG1) >> 1   => ~ INC1 * MAG1 / 32
    ; (taratura: per MAG1=1 è abbastanza udibile)
    LDD  <INC1
    LSRA
    RORB
    LSRA
    RORB
    LSRA
    RORB
    LSRA
    RORB              ; D = INC1 >> 4
    ; ora usa solo il byte basso di D (più grande del vecchio INC_hi)
    TFR  B,A          ; A = low byte of (INC1>>4)
    LDB  <MAG1
    MUL               ; D = A * MAG1
    LSRA
    RORB              ; >>1
    STD  <DELTAW


    LDA  <SL1
    BPL  ch1_add
    LDD  <INC1
    SUBD <DELTAW
    STD  <INC1
    BRA  ch1_done
ch1_add:
    LDD  <INC1
    ADDD <DELTAW
    STD  <INC1
ch1_done:

; ===== CH2: portamento su INC2 (SL2 signed) =====
    LDA  <SL2
    STA  <MAG2
    BPL  ch2_mag_ok
    NEGA
    STA  <MAG2
ch2_mag_ok:
    LDA  <INC2
    LDB  <MAG2
    MUL
    LSRA
    RORB
    STD  <DELTAW

    LDA  <SL2
    BPL  ch2_add
    LDD  <INC2
    SUBD <DELTAW
    STD  <INC2
    BRA  ch2_done
ch2_add:
    LDD  <INC2
    ADDD <DELTAW
    STD  <INC2
ch2_done:

fx_done:
    LDY  <SPT
    BNE  spt_ok
    JMP  tickDone        ; SPT = 0 → salta sampleLoop
spt_ok:

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
    BEQ  after_tick_loop
    JMP  tickLoop        ; salto a 16 bit
after_tick_loop:

; ---------- advance trackPos ----------
    LDD  <TRACKPOS
    ADDD #$000A
    CMPD <TRACKLINES
    BLS  storePos
    LDD  #$0000
storePos:
    STD  <TRACKPOS
    STD  _trackPos
    PULS DP
END ASM ON CPU6809
END PROCEDURE