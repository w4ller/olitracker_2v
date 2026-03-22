# SPEC-070 — Instruments & wavetable loading (v0.2)

## Scopo
Definire come vengono caricate le wavetable (256 byte/strumento) dal binario song in RAM residente e come vengono esposti i puntatori `_instruments(n)` usati dall'ASM.

## Dipendenze
- Formato binario: SPEC-010 (headerLen=5; wavetable a fine song).
- Memory/I-O: SPEC-020 (lettura banked).
- Player state: SPEC-050 (contratto INST1P/INST2P).

## Calcolo offset wavetable
Nel codice attuale:
- `wavePosition = _addr + _headerLen + (_songSize * _channelLen * 2)`

Dove:
- `_songSize` è `rows_total` (uint16) letto dall'header.
- `_channelLen = 5` e i canali sono 2 ⇒ `rows_total * 10` byte di payload.

Quindi:
- `wavePosition = _addr + headerLen + (rows_total * 10)`.

## Numero strumenti
- `instruments_count = PEEK(VARPTR(_header) + 4)`.

## Array `instruments(n)` — puntatori BANK
- `instruments` è un array di indirizzi calcolati **a init**, uno per strumento.
- `instruments(n) = wavePosition + (n * 256)` → indirizzo della wavetable nel BANK song.
- Questi indirizzi sono usati dal loop BASIC per il BANK READ per-row, non dall'ASM.

## Buffer `instRam` — caricamento per-row (v0.2)
- `instRam(512)` è un buffer in RAM normale residente (2 wavetable × 256 byte).
- Il caricamento **non è statico**: avviene **ad ogni row** nel loop BASIC di `playTicksAsm.bas`.
- Per ogni frame, il loop legge gli indici strumento dalla row decodificata (`inst1 = rowBuf(1)`, `inst2 = rowBuf(6)`) e poi:
  - `BANK READ songBank FROM instruments(inst1) TO VARPTR(instRam) SIZE 256`
  - `BANK READ songBank FROM instruments(inst2) TO VARPTR(instRam) + 256 SIZE 256`
- Dopo questi due BANK READ, `instRam[0..255]` contiene la wavetable di `inst1` e `instRam[256..511]` quella di `inst2`.

## Puntatori per l'ASM
- `INST1P = VARPTR(instRam) + 128`
- `INST2P = VARPTR(instRam) + 256 + 128`
- Il +128 centra la wavetable per l'indicizzazione con il byte alto del phase accumulator (±128).
- Vedere SPEC-050 per il contratto completo con `asm_player_frame`.

## Acceptance Criteria
- AC-070-01: `instruments_count` è letto da `_header+4` e determina il numero di wavetable caricate.
- AC-070-02: L'offset di inizio wavetable è `wavePosition = _addr + _headerLen + (rows_total * 10)`.
- AC-070-03: Per ogni `n` in `0..instruments_count-1`, il blocco `n` caricato è esattamente 256 byte.
- AC-070-04: `instruments(n)` punta alla wavetable n nel BANK song (usato solo dal loop BASIC per il BANK READ).
- AC-070-05: Ad ogni row, prima di `asm_player_frame`, il loop BASIC esegue BANK READ di `inst1` in `instRam[0]` e `inst2` in `instRam[256]`.