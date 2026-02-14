# SPEC-020 — Memory & I/O map (v0.1)

## Scopo
Documentare l’uso di:
- Direct Page (DP) per lo stato del player.
- Banking per leggere la song banked.
- Registri I/O usati per banking e DAC.

## Componenti e simboli (dal codice)
- `_audioDPPage`, `_audioDPBase`: calcolati in BASIC in `audioDeepPage.bas`. [file:121]
- `_songBank`: bank in cui risiede il file song caricato BANKED. [file:126]
- `_rowBuf`: buffer di 10 byte in RAM per decodifica row. [file:126]
- `DP`: impostato in ASM con `TFR A,DP` usando `_audioDPPage`. [file:128][file:126]

## Direct Page (DP)
### Regola di allocazione
- `audioDeepPage.bas` alloca `audioDP(512)` e calcola una pagina **allineata** a 256 byte (xx00). [file:121]
- `_audioDPPage` è `VARPTR(audioDP)/$100`, incrementato di 1 se `VARPTR(audioDP) MOD $100 != 0`. [file:121]
- `_audioDPBase = _audioDPPage * $100`. [file:121]

### Contratto con l’ASM
- `asm_player_init` e `asm_player_frame` devono sempre eseguire:
  - `LDA _audioDPPage`
  - `TFR A,DP` [file:128][file:126]
- Il layout DP vero e proprio è definito in `SPEC-050` e deve restare stabile. [file:128][file:126]

## Banking per lettura song
### Registro di banking (v0.1)
- L’ASM scrive `_songBank` in `$A7E5` prima di leggere i 10 byte della row. [file:126]
- Dopo aver copiato la row in `_rowBuf`, il codice **può** ripristinare il bank “normale” del programma (nota: nel file attuale il ripristino è commentato). [file:126]

### Contratto
- La lettura banked viene fatta **solo** per la sorgente song; la decodifica avviene su `_rowBuf` in RAM normale. [file:126]

## DAC I/O
### Init
- `config.bas` inizializza il DAC leggendo `$A7CF`, mascherando con `#$FB`, scrivendo `$A7CF`, scrivendo `#$3F` su `$A7CD`, poi impostando il bit `#$04` su `$A7CF`. [file:129]

### Output
- Il loop audio scrive il sample finale su `$A7CD`. [file:126]

## Acceptance Criteria
- AC

