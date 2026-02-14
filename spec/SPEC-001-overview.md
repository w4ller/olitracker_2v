# SPEC-010 — Song binary format (v0.1)

## Scopo
Definire un contratto stabile per il file `assets/binarisong.bin` (o equivalente), usato dal player.

## Glossario (termini)
- Row: una riga della song.
- Channel: canale logico (2 canali).
- Event: 5 byte per canale dentro una row.
- Wavetable: 256 byte per strumento.

## Layout binario
### Header (5 byte)
Offset | Size | Nome | Tipo | Note
---|---:|---|---|---
0 | 2 | `rows_total` | uint16 | Numero totale di row (vedi Endianness)
2 | 1 | `bpm` | uint8 | BPM (letto dal player)
3 | 1 | `ticks_per_row` | uint8 | Atteso = 6 (v0.1)
4 | 1 | `instruments_count` | uint8 | Numero strumenti (wavetable)

> Nota: nel codice attuale `headerLen = 5`.

### Song payload
- Inizia subito dopo l’header, quindi a offset `headerLen` (5).
- Ogni row occupa 10 byte: 2 canali × 5 byte/canale.
- Lunghezza totale song payload = `rows_total * 10`.

### Wavetable block
- Inizia subito dopo il payload song.
- Lunghezza totale wavetable = `instruments_count * 256`.
- Ogni wavetable è esattamente 256 byte.

### Dimensione file attesa
`file_size = headerLen + (rows_total * 10) + (instruments_count * 256)`

## Endianness
- `rows_total` è un uint16.
- v0.1: **little-endian** (low byte, poi high byte).
- Se si decide diversamente, bisogna aggiornare il loader (o l’exporter) e incrementare la versione di questa spec.

## Contratti “player-facing”
- `row_len` è sempre 10 byte.
- I byte della row vengono copiati in un buffer temporaneo (`rowBuf`) prima del decode.

## Error handling (minimo)
- Se `file_size < headerLen` → errore: header incompleto.
- Se `file_size < headerLen + rows_total*10` → errore: payload song incompleto.
- Se `file_size < headerLen + rows_total*10 + instruments_count*256` → errore: wavetable incompleto.

## Acceptance Criteria
- AC-010-01: Il loader legge esattamente 5 byte di header e interpreta `rows_total`, `bpm`, `ticks_per_row`, `instruments_count`.
- AC-010-02: L’offset di inizio song payload è sempre `headerLen=5`.
- AC-010-03: Ogni row è 10 byte e viene letta/copiata atomica (nessun read parziale).
- AC-010-04: Il blocco wavetable inizia a `headerLen + rows_total*10` e contiene `instruments_count` wavetable da 256 byte.
- AC-010-05: `ticks_per_row` diverso da 6 è rifiutato o gestito esplicitamente (vedi SPEC-030).

