# SPEC-070 — Instruments & wavetable loading (v0.1)

## Scopo
Definire come vengono caricate le wavetable (256 byte/strumento) dal binario song in RAM residente e come vengono esposti i puntatori `_instruments(n)` usati dall’ASM.

## Dipendenze
- Formato binario: SPEC-010 (headerLen=5; wavetable a fine song).
- Memory/I-O: SPEC-020 (lettura banked). [file:122]

## Calcolo offset wavetable (v0.1)
Nel codice attuale:
- `wavePosition = _addr + _headerLen + (_songSize * _channelLen * 2)` [file:122]
Dove:
- `_songSize` è `rows_total` (uint16) letto dall’header. [file:124]
- `_channelLen = 5` e i canali sono 2 ⇒ `rows_total * 10` byte di payload. [file:124][file:122]

Quindi:
- `wavePosition = _addr + headerLen + (rows_total * 10)`.

## Numero strumenti
- `instruments_count = PEEK(VARPTR(_header) + 4)`. [file:122]

## Caricamento in RAM residente
- `instRam(512)` è un buffer in RAM residente. [file:122]
- v0.1: viene fatto un `BANK READ` iniziale di 512 byte da `wavePosition` a `instRam` (prefetch) e poi un loop che legge ogni wavetable 256B nello stesso buffer. [file:122]
- Per ogni strumento `n`, si copia:
  - `src = wavePosition + (n * 256)`
  - `dst = VARPTR(instRam) + (n * 256)`
  - `BANK READ songBank FROM src TO dst SIZE 256`. [file:122]

## Puntatore strumenti per l’ASM
- `_instruments` è un array di indirizzi (`ADDRESS(8)`), uno per strumento. [file:122]
- v0.1: `instruments(n) = VARPTR(instRam) + (n * 256) + 128`. [file:122]
Questo “centra” la wavetable per l’indicizzazione con `A` come offset (phase high byte) nel core ASM. [file:126]

## Acceptance Criteria
- AC-070-01: `instruments_count` è letto da `_header+4` e determina il numero di wavetable caricate. [file:122]
- AC-070-02: L’offset di inizio wavetable è `wavePosition = _addr + _headerLen + (rows_total * 10)` (equivalente alla formula in codice). [file:122][file:124]
- AC-070-03: Per ogni `n` in `0..instruments_count-1`, il blocco `n` caricato è esattamente 256 byte. [file:122]
- AC-070-04: `instruments(n)` punta a `instRam + n*256 + 128` (v0.1) e resta dereferenziabile in `asm_player_frame`. [file:122][file:126]

