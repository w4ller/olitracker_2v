' @spec SPEC-050,SPEC-010,SPEC-030,SPEC-060
' @covers AC-050-03,AC-010-03,AC-030-03,AC-060-01,AC-060-02,AC-060-04
' @notes Decode rowBuf[0..9]; note sentinel 96/97/98; TRACKPOS += $000A; tickcnt=6 (v0.1).


PROCEDURE asm_player_frame
ON CPU6809 BEGIN ASM
   PSHS DP
    LDA _audioDPPage
    TFR A,DP



    LDX  #_rowBuf

; ---------- CH1 note -> INC1 ----------
    LDA  0,X
    CMPA #97          ; repeat ch1?
    BEQ  ch1_skip_inc
    CMPA #96          ; pause?
    BNE  ch1_lookup_inc
    LDD  #$0000
    STD  <INC1
    STD  <ACC1        ; reset ACC1 per pausa
    BRA  ch1_done_inc
ch1_lookup_inc:
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INCTABP
    LDD  D,U
    STD  <INC1
    LDD  #$0000
    STD  <ACC1        ; reset ACC1 per nuova nota
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
    STD  <ACC2        ; reset ACC2 per pausa
    BRA  ch2_done_inc
ch2_lookup_inc:
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INCTABP
    LDD  D,U
    STD  <INC2
    LDD  #$0000
    STD  <ACC2        ; reset ACC2 per nuova nota
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
    JMP  fx_done        ; se tickidx=0, salta gli FX
fx_do:
    JSR  do_fx_sub      ; esegue gli FX (subroutine)
    JMP  fx_done        ; torna al flusso principale
; ------------------------------------------------------------------
; Subroutine FX (separata per evitare errori di range)
; ------------------------------------------------------------------
do_fx_sub:

; ===== CH1 (semplificato) =====
    LDA  <SL1
    BEQ  ch1_end
    BPL  ch1_up
    ; slide down
    LDA  <SL1
    NEGA
    TFR  A,B
    LDX  #_deltaPitchTable
    LSLB
    ABX
    LDD  ,X
    STD  <DELTA
    LDD  <INC1
    SUBD <DELTA
    STD  <INC1
    JMP  ch1_end
ch1_up:
    ; slide up
    LDA  <SL1
    TFR  A,B
    LDX  #_deltaPitchTable
    LSLB
    ABX
    LDD  ,X
    STD  <DELTA
    LDD  <INC1
    ADDD <DELTA
    STD  <INC1
ch1_end:

; ===== CH2 (semplificato) =====
    LDA  <SL2
    BEQ  ch2_end
    BPL  ch2_up
    ; slide down
    LDA  <SL2
    NEGA
    TFR  A,B
    LDX  #_deltaPitchTable
    LSLB
    ABX
    LDD  ,X
    STD  <DELTA
    LDD  <INC2
    SUBD <DELTA
    STD  <INC2
    JMP  ch2_end
ch2_up:
    ; slide up
    LDA  <SL2
    TFR  A,B
    LDX  #_deltaPitchTable
    LSLB
    ABX
    LDD  ,X
    STD  <DELTA
    LDD  <INC2
    ADDD <DELTA
    STD  <INC2
ch2_end:

    RTS

fx_done:
    LDY  <SPT
    BNE  spt_ok
    JMP  tickDone        ; SPT = 0 → salta sampleLoop
spt_ok:

sampleLoop:
    ; === CAMPIONE N ===
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

    ; === CAMPIONE N+1 ===
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

    ; === CAMPIONE N+2 ===
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

    ; === CAMPIONE N+3 ===
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

    ; decremento di 4
    LEAY -4,Y
    LBNE  sampleLoop

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