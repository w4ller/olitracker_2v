# SPEC-080 — Lookup tables (increment & volume) (v0.1)

## Scopo
Definire il contratto delle tabelle usate dall’ASM:
- `_incTable`: note → phase increment (16-bit).
- `_volumeTableAddr`: volume index → pointer a tabella di mapping sample/volume.

## Increment table (`_incTable`)
### Definizione
- `_incTable` è un array di WORD indicizzato da un valore-note (byte). [file:125][file:126]
- Il core ASM calcola un offset `D = note*2` e poi legge `LDD D,U` con `U = _incTable`. [file:126]

### Casi speciali (v0.1)
- `note = 96` (pause) ⇒ incremento 0. [file:125][file:126]
- `note = 97`/`98` (repeat semantic) ⇒ in tabella sono 0, ma in ASM sono anche gestiti come sentinel (skip/branch). [file:125][file:126]

## Volume tables (`_volumeTableAddr`)
### Definizione
- `volumeTable` è caricato da `volumetables.bin`. [file:123]
- `_volumeTableAddr` è un array di 16 WORD costruito così:
  - `_volumeTableAddr(n) = VARPTR(volumeTable) + (22 * n)` per `n=0..15`. [file:123]

### Uso nel core ASM
- `VOL1P`/`VOL2P` ricevono un puntatore da `_volumeTableAddr` usando `vol*2` come indice. [file:126][file:128]
- Poi il core fa: `LDA B,U` dove `B` è il sample letto dalla wavetable. [file:126]
Quindi v0.1 assume che:
- i valori di sample presenti nella wavetable siano compatibili con l’indicizzazione della tabella volume (policy di range/clip da formalizzare se necessario). [file:126]

## Acceptance Criteria
- AC-080-01: `_incTable` è accessibile dall’ASM come base pointer e la lettura usa indice `note*2` (WORD). [file:126][file:125]
- AC-080-02: `incTable(96) = 0` e una nota “pause” produce incremento 0 nel core. [file:125][file:126]
- AC-080-03: `_volumeTableAddr` definisce 16 puntatori con stride 22 e viene usato dall’ASM per risolvere `VOL1P/VOL2P`. [file:123][file:126][file:128]
- AC-080-04: La wavetable letta da `INSTxP` produce valori che non mandano fuori range `LDA B,U` (o viene definita una strategia di clamp). [file:126][file:123]

### 97/98 (repeat) — nota importante
- `note = 97` (repeat CH1) e `note = 98` (repeat CH2) sono trattati dal decoder ASM come sentinel: il core **non aggiorna** `INC1`/`INC2` e quindi mantiene l’incremento precedente del canale. [file:126]
- In `incTable`, gli indici 97 e 98 sono definiti a 0 **solo come valore di fallback**, ma non vengono usati nel percorso “repeat” perché l’ASM branch-a prima del lookup. [file:126][file:125]

