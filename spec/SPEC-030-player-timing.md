# SPEC-030 — Timing & tick model (v0.1)

## Scopo
Definire come il player traduce BPM e tick in “numero di sample” da inviare al DAC per ogni tick.

## Input
- `bpm` (uint8) viene letto dall’header della song a offset 2 (SPEC-010).
- `ticks_per_row` (uint8) a offset 3: v0.1 assume 6.

## Costanti (v0.1)
- `sample_rate = 11497`
- `speed = 6`  (ticks per row)

## Funzioni (come implementazione di riferimento)
### samplesPerRow (row = sedicesimo)
Dato `bpm`, si calcola:
- `q = sample_rate / bpm`
- `r = sample_rate MOD bpm`
- `samples_per_row = (q * 15) + ((r * 15) / bpm)`

### samplesPerTick
- `samples_per_tick = (samples_per_row + (speed/2)) / speed`
- Questo valore viene salvato in `index` e passato al player ASM come `SPT`.

## Contratto con l’ASM
- `SPT` è il contatore di sample nel loop interno: se `SPT = 0` il tick non produce output.
- `TICKCNT` per row è 6 (hardcoded in v0.1).

## Limitazioni note (v0.1)
- Il campo `ticks_per_row` nel file binario non è ancora usato come parametro dinamico: deve valere 6.

## Acceptance Criteria
- AC-030-01: `bpm` è letto dall’header e influenza il calcolo di `samples_per_tick`.
- AC-030-02: `index` viene impostato a `samples_per_tick` e copiato in `SPT` in `asm_player_init`.
- AC-030-03: Il core ripete esattamente 6 tick per row (finché non si rende dinamico).
- AC-030-04: Se `bpm = 0` (dato invalido), il player non deve andare in divisione per zero (errore o clamp documentato).

