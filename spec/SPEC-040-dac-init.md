# SPEC-040 — DAC init & output (v0.1)

## Scopo
Definire il contratto minimo per inizializzare il DAC e inviare sample.

## Registri I/O usati
- `$A7CF`: registro di controllo (bitmask applicata in init).
- `$A7CD`: registro dati DAC (scrittura sample). [file:129][file:126]

## Sequenza di inizializzazione (riferimento implementativo)
La procedura `inizialize_dac` esegue:
1) `LDA $A7CF`
2) `ANDA #$FB`
3) `STA $A7CF`
4) `LDB #$3F`
5) `STB $A7CD`
6) `ORA #$04`
7) `STA $A7CF` [file:129]

## Output sample
- Nel core player, ad ogni sample viene scritto un byte su `$A7CD`. [file:126]

## Acceptance Criteria
- AC-040-01: La routine di init effettua esattamente la sequenza di maschera/scrittura sui registri `$A7CF/$A7CD` (v0.1). [file:129]
- AC-040-02: Il loop audio scrive il sample su `$A7CD` almeno una volta per tick quando `SPT > 0`. [file:126]

