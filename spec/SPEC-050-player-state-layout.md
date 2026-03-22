# SPEC-050 — Player DP state layout (v0.2)

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
12 | `INST1P` | 2 | Pointer wavetable ch1 → punta a `instRam + 0 + 128` (RAM normale, aggiornato ogni row)
14 | `INST2P` | 2 | Pointer wavetable ch2 → punta a `instRam + 256 + 128` (RAM normale, aggiornato ogni row)
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

## Contratto INST1P / INST2P (v0.2)
Prima di ogni chiamata a `asm_player_frame`, il loop BASIC in `playTicksAsm.bas` esegue:
1. Lettura row da BANK → `rowBuf` (via ASM stub `songCopy`).
2. `inst1 = rowBuf(1)`, `inst2 = rowBuf(6)`.
3. `BANK READ songBank FROM instruments(inst1) TO VARPTR(instRam) SIZE 256`
4. `BANK READ songBank FROM instruments(inst2) TO VARPTR(instRam) + 256 SIZE 256`

Quindi:
- `asm_player_frame` legge le wavetable da **RAM normale** (`instRam`), non direttamente da BANK.
- `INST1P` punta a `VARPTR(instRam) + 128`.
- `INST2P` punta a `VARPTR(instRam) + 256 + 128`.
- I puntatori sono centrati (+128) per consentire indicizzazione con il byte alto del phase accumulator (±128).
- Il BANK READ è responsabilità del loop BASIC; l'ASM non accede mai direttamente al BANK per le wavetable.

## Invarianti
- Gli offset devono rimanere identici tra init e frame.
- `TRACKPOS` avanza di +10 ogni frame (una row) e fa wrap a 0 quando supera `TRACKLINES`.
- `INST1P`/`INST2P` puntano **sempre** a RAM normale; il BANK READ è responsabilità del loop BASIC, non dell'ASM.

## Acceptance Criteria
- AC-050-01: `asm_player_init` inizializza `ACC1/ACC2` a $8000 e azzera `INC*` e `DINC*`.
- AC-050-02: `asm_player_init` scrive `SONGBASE = _addr + _headerLen`.
- AC-050-03: `asm_player_frame` usa `SONGBASE + TRACKPOS` per leggere 10 byte e aggiorna `TRACKPOS += 10` con wrap.
- AC-050-04: Un cambio agli offset richiede modifica coordinata di init+frame e bump versione SPEC.
- AC-050-05: Prima di ogni `asm_player_frame`, il loop BASIC ha eseguito il BANK READ delle wavetable `inst1`/`inst2` in `instRam[0]` e `instRam[256]` rispettivamente.