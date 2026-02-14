' @spec SPEC-080,SPEC-060
' @covers AC-080-01,AC-080-02,AC-060-02,AC-060-04
' @notes Indici speciali: 96=pause, 97=repeat ch1, 98=repeat ch2 (v0.1 inc=0; ASM gestisce 97/98 come "keep previous").
' ### 97/98 (repeat) — nota importante
- `note = 97` (repeat CH1) e `note = 98` (repeat CH2) sono trattati dal decoder ASM come sentinel: il core **non aggiorna** `INC1`/`INC2` e quindi mantiene l’incremento precedente del canale. [file:126]
- In `incTable`, gli indici 97 e 98 sono definiti a 0 **solo come valore di fallback**, ma non vengono usati nel percorso “repeat” perché l’ASM branch-a prima del lookup. [file:126][file:125]


DIM incTable AS WORD (99) FOR BANK READ
GLOBAL incTable


' Tabella degli incrementi per le note (c-0 a b-7)
' Valore di riferimento: c-3 (indice 24) = $0326


' Note prima di c-2 (indici 0-23)
incTable(0) = $0065
incTable(1) = $006B
incTable(2) = $0071
incTable(3) = $0078
incTable(4) = $007F
incTable(5) = $0086
incTable(6) = $008E
incTable(7) = $0097
incTable(8) = $00A0
incTable(9) = $00A9
incTable(10) = $00B4
incTable(11) = $00BE
incTable(12) = $00CA
incTable(13) = $00D5
incTable(14) = $00E2
incTable(15) = $00F0
incTable(16) = $00FE
incTable(17) = $010D
incTable(18) = $011D
incTable(19) = $012E
incTable(20) = $0140
incTable(21) = $0153
incTable(22) = $0167
incTable(23) = $017C
incTable(24) = $0193
incTable(25) = $01AB
incTable(26) = $01C4
incTable(27) = $01DF
incTable(28) = $01FC
incTable(29) = $021A
incTable(30) = $023A
incTable(31) = $025C
incTable(32) = $0280
incTable(33) = $02A6
incTable(34) = $02CE
incTable(35) = $02F9

' Valore di riferimento - c-3 (indice 36)
incTable(36) = $0326

' Note dopo c-2 (indici 25-95)
incTable(37) = $0356
incTable(38) = $0389
incTable(39) = $03BF
incTable(40) = $03F7
incTable(41) = $0434
incTable(42) = $0474
incTable(43) = $04B8
incTable(44) = $04FF
incTable(45) = $054C
incTable(46) = $059C
incTable(47) = $05F2
incTable(48) = $064C
incTable(49) = $06AC
incTable(50) = $0711
incTable(51) = $077D
incTable(52) = $07EF
incTable(53) = $0868
incTable(54) = $08E8
incTable(55) = $096F
incTable(56) = $09FF
incTable(57) = $0A97
incTable(58) = $0B38
incTable(59) = $0BE3
incTable(60) = $0C98
incTable(61) = $0D58
incTable(62) = $0E23
incTable(63) = $0EFA
incTable(64) = $0FDE
incTable(65) = $10D0
incTable(66) = $11CF
incTable(67) = $12DF
incTable(68) = $13FE
incTable(69) = $152E
incTable(70) = $1671
incTable(71) = $17C6
incTable(72) = $1930
incTable(73) = $1AAF
incTable(74) = $1C46
incTable(75) = $1DF4
incTable(76) = $1FBC
incTable(77) = $219F
incTable(78) = $239F
incTable(79) = $25BD
incTable(80) = $27FC
incTable(81) = $2A5C
incTable(82) = $2CE1
incTable(83) = $2F8C
incTable(84) = $3260
incTable(85) = $355F
incTable(86) = $388B
incTable(87) = $3BE8
incTable(88) = $3F78
incTable(89) = $433E
incTable(90) = $473E
incTable(91) = $4B7A
incTable(92) = $4FF7
incTable(93) = $54B8
incTable(94) = $59C2
incTable(95) = $5F18


' pause
incTable(96) = $0000  
' previous note channel 0
incTable(97) = $0000
' previous note channel 1
incTable(98) = $0000
