# SPEC-050 — Player DP state layout (v0.1)

## Scopo
Stabilire un layout stabile (offset e significato) delle variabili del player memorizzate su Direct Page (DP) del 6809.

## Selezione DP
- DP viene impostato a runtime tramite `_audioDPPage` in `asm_player_init` e `asm_player_frame`.
- Tutti gli accessi a stato player usano addressing `<...` (direct).

## Layout (offset in byte)
Offset | Label | Size | Descrizione
---|---|---:|---
0  | `ACC1` | 2 | Phase accumulator ch1
2  | `ACC2` | 2 | Phase accumulator ch2
4  | `INC1` | 2 | Phase increment ch1 (da note)
6  | `INC2` | 2 | Phase increment ch2
8  | `DINC1` | 2 | Delta increment ch1 (v0.1: 0)
10 | `DINC2` | 2 | Delta increment ch2 (v0.1: 0)
12 | `INST1P` | 2 | Pointer wavetable ch1
14 | `INST2P` | 2 | Pointer wavetable ch2
16 | `VOL1P` | 2 | Pointer volume lookup ch1
18 | `VOL2P` | 2 | Pointer volume lookup ch2
20 | `SPT` | 2 | Samples per tick (loop interno)
22 | `TICKCNT` | 1 | Tick counter per row
24 | `SONGBASE` | 2 | Base address song payload
26 | `TRACKPOS` | 2 | Offset corrente in byte (multiplo di 10)
28 | `TRACKLINES` | 2 | Ultimo offset valido (wrap quando superato)
30 | `INCTABP` | 2 | Pointer tabella incrementi
32 | `INSTTABP` | 2 | Pointer tabella strumenti/puntatori wavetable
34 | `VOLTABP` | 2 | Pointer tabella volumi/puntatori
36 | `TMP1` | 1 | Temporaneo (mix ch1)

## Invarianti
- Gli offset devono rimanere identici tra init e frame.
- `TRACKPOS` avanza di +10 ogni frame (una row) e fa wrap a 0 quando supera `TRACKLINES`.

## Acceptance Criteria
- AC-050-01: `asm_player_init` inizializza `ACC1/ACC2` a $8000 e azzera `INC*` e `DINC*`.
- AC-050-02: `asm_player_init` scrive `SONGBASE = _addr + _headerLen`.
- AC-050-03: `asm_player_frame` usa `SONGBASE + TRACKPOS` per leggere 10 byte e aggiorna `TRACKPOS += 10` con wrap.
- AC-050-04: Un cambio agli offset richiede modifica coordinata di init+frame e bump versione SPEC.

