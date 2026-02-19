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
    LDA  #96
    STA  <BASE1NOTE
    LDD  #$0000
    STD  <INC1
    STD  <ACC1        ; reset ACC1 per pausa
    BRA  ch1_done_inc
ch1_lookup_inc:
    STA  <BASE1NOTE
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


; ---------- CH1 FX: 00 arpeggio, 01/02 slide ----------
    LDA  3,X          ; FX1A
    BEQ  fx1_arp
    CMPA #1
    BEQ  fx1_up
    CMPA #2
    BEQ  fx1_down
    CLR  <SL1
    CLR  <ARP1P
    BRA  fx1_done
fx1_arp:
    LDA  4,X          ; FX1B (XX)
    STA  <ARP1P
    CLR  <SL1
    TFR  A,B
    ANDB #$0F
    STB  <ARP1L
    LSRA
    LSRA
    LSRA
    LSRA
    STA  <ARP1H
    BRA  fx1_done
fx1_up:
    LDA  4,X          ; FX1B
    STA  <SL1         ; positivo
    CLR  <ARP1P
    BRA  fx1_done
fx1_down:
    LDA  4,X
    NEGA
    STA  <SL1         ; negativo
    CLR  <ARP1P
fx1_done:


; ---------- CH2 note -> INC2 ----------
    LDA  5,X
    CMPA #98          ; repeat ch2?
    BEQ  ch2_skip_inc
    CMPA #96          ; pause?
    BNE  ch2_lookup_inc
    LDA  #96
    STA  <BASE2NOTE
    LDD  #$0000
    STD  <INC2
    STD  <ACC2        ; reset ACC2 per pausa
    BRA  ch2_done_inc
ch2_lookup_inc:
    STA  <BASE2NOTE
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


; ---------- CH2 FX: 00 arpeggio, 01/02 slide ----------
    LDA  8,X          ; FX2A
    BEQ  fx2_arp
    CMPA #1
    BEQ  fx2_up
    CMPA #2
    BEQ  fx2_down
    CLR  <SL2
    CLR  <ARP2P
    BRA  fx2_done
fx2_arp:
    LDA  9,X          ; FX2B (XX)
    STA  <ARP2P
    CLR  <SL2
    TFR  A,B
    ANDB #$0F
    STB  <ARP2L
    LSRA
    LSRA
    LSRA
    LSRA
    STA  <ARP2H
    BRA  fx2_done
fx2_up:
    LDA  9,X          ; FX2B
    STA  <SL2
    CLR  <ARP2P
    BRA  fx2_done
fx2_down:
    LDA  9,X
    NEGA
    STA  <SL2
    CLR  <ARP2P
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


; ===== CH1: ARPEGGIO 00XY =====
    LDA  <ARP1P
    BEQ  ch1_slide
    LDA  <BASE1NOTE
    CMPA #96
    BHS  ch1_slide

    ; a = TICKIDX % 3 (qui TICKIDX è 1..5)
    LDA  <TICKIDX
    CMPA #3
    BLO  arp1_m3_ok
    SUBA #3
arp1_m3_ok:
    BEQ  arp1_off0
    CMPA #1
    BEQ  arp1_offH
    LDA  <ARP1L
    BRA  arp1_haveOff
arp1_offH:
    LDA  <ARP1H
    BRA  arp1_haveOff
arp1_off0:
    CLRA
arp1_haveOff:
    ADDA <BASE1NOTE

    ; clamp su 0..95 (evita sentinel 96/97/98)
    CMPA #95
    BLS  arp1_idx_ok
    SUBA #12
    CMPA #95
    BLS  arp1_idx_ok
    SUBA #12
arp1_idx_ok:

    ; lookup INC1
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INCTABP
    LDD  D,U
    STD  <INC1
    JMP  ch1_end


ch1_slide:
; ===== CH1 SLIDE (come prima) =====
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


; ===== CH2: ARPEGGIO 00XY =====
    LDA  <ARP2P
    BEQ  ch2_slide
    LDA  <BASE2NOTE
    CMPA #96
    BHS  ch2_slide

    ; a = TICKIDX % 3 (qui TICKIDX è 1..5)
    LDA  <TICKIDX
    CMPA #3
    BLO  arp2_m3_ok
    SUBA #3
arp2_m3_ok:
    BEQ  arp2_off0
    CMPA #1
    BEQ  arp2_offH
    LDA  <ARP2L
    BRA  arp2_haveOff
arp2_offH:
    LDA  <ARP2H
    BRA  arp2_haveOff
arp2_off0:
    CLRA
arp2_haveOff:
    ADDA <BASE2NOTE

    ; clamp su 0..95 (evita sentinel 96/97/98)
    CMPA #95
    BLS  arp2_idx_ok
    SUBA #12
    CMPA #95
    BLS  arp2_idx_ok
    SUBA #12
arp2_idx_ok:

    ; lookup INC2
    TFR  A,B
    CLRA
    LSLB
    ROLA
    LDU  <INCTABP
    LDD  D,U
    STD  <INC2
    JMP  ch2_end


ch2_slide:
; ===== CH2 SLIDE (come prima) =====
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


; loop a 4 campioni + coda (gestisce SPT non multipli di 4)
sampleLoop:
    CMPY #4
    BLO  sampleTail

sample4:
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


    LEAY -4,Y
    CMPY #4
    BHS  sample4

sampleTail:
    CMPY #0
    BEQ  tickDone

sample1:
    ; === CAMPIONE (tail) ===
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
    BNE  sample1


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
