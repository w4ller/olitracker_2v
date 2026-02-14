# SPEC-060 — Row encoding (2ch × 5 bytes) (v0.1)

## Scopo
Definire la semantica dei 10 byte che rappresentano una row della song (2 canali, 5 byte/canale), così che decoder ASM e exporter restino coerenti.

## Contesto
- Ogni row è lunga 10 byte ed è copiata in `_rowBuf` prima della decodifica. [file:126]
- Il core decodifica esplicitamente i campi ai seguenti offset: CH1: 0,1,2; CH2: 5,6,7. [file:126]
- Gli altri byte (3,4,8,9) in v0.1 sono **riservati** (pass-through / non usati dal player). [file:126]

## Layout row (10 byte)
Offset | Canale | Nome | Uso nel player (v0.1)
---|---|---|---
0 | CH1 | `note1` | Nota/sentinel → calcolo `INC1` via `_incTable` oppure skip/0. [file:126]
1 | CH1 | `inst1` | Indice strumento → risolve `INST1P` via `_instruments`. [file:126]
2 | CH1 | `vol1` | Indice volume → risolve `VOL1P` via `_volumeTableAddr`. [file:126]
3 | CH1 | `fx1_a` | Riservato (non letto dal core). [file:126]
4 | CH1 | `fx1_b` | Riservato (non letto dal core). [file:126]
5 | CH2 | `note2` | Nota/sentinel → calcolo `INC2` via `_incTable` oppure skip/0. [file:126]
6 | CH2 | `inst2` | Indice strumento → risolve `INST2P` via `_instruments`. [file:126]
7 | CH2 | `vol2` | Indice volume → risolve `VOL2P` via `_volumeTableAddr`. [file:126]
8 | CH2 | `fx2_a` | Riservato (non letto dal core). [file:126]
9 | CH2 | `fx2_b` | Riservato (non letto dal core). [file:126]

## Semantica note (v0.1)
### Valori speciali (sentinel)
Il core tratta i seguenti valori speciali:
- `96` = **pause**: setta `INCx = 0` (silenzio/hold di fase a seconda dell’accumulatore). [file:126]
- `97` = **repeat ch1**: il core salta l’aggiornamento di `INC1` (mantiene l’incremento precedente). [file:126]
- `98` = **repeat ch2**: il core salta l’aggiornamento di `INC2` (mantiene l’incremento precedente). [file:126]

### Note “normali”
- Se `note` non è sentinel, l’ASM calcola `D = note * 2` e legge un WORD da `_incTable` per ottenere `INCx`. [file:126]

## Semantica inst/vol (v0.1)
- `instx` è un indice che viene trasformato in offset `instx*2` per leggere un puntatore WORD dalla tabella `_instruments`, e quel puntatore diventa `INSTxP`. [file:126]
- `volx` è un indice che viene trasformato in offset `volx*2` per leggere un puntatore WORD dalla tabella `_volumeTableAddr`, e quel puntatore diventa `VOLxP`. [file:126]

## Vincoli
- La row deve essere sempre lunga 10 byte; il player avanza `TRACKPOS += 10` per passare alla row successiva. [file:126]
- In v0.1, i campi fx (offset 3,4,8,9) non devono influire sul suono (sono ignorati dal core). [file:126]

## Acceptance Criteria
- AC-060-01: Il decoder usa `note1/inst1/vol1` agli offset 0/1/2 e `note2/inst2/vol2` agli offset 5/6/7. [file:126]
- AC-060-02: `note=96` produce `INCx=0`; `note=97/98` mantengono l’INC precedente del canale. [file:126]
- AC-060-03: I campi riservati (3,4,8,9) non vengono letti dal core (v0.1). [file:126]
- AC-060-04: Per note non-sentinel, `INCx` viene risolto tramite `_incTable[note]` (lookup WORD con indice `note*2`). [file:126]
- AC-080-05: Per `note=97`/`98` il core non esegue il lookup su `_incTable` e mantiene l’`INCx` precedente (repeat). [file:126]

