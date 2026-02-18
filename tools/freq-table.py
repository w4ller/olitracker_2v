import math

# Valore di riferimento per c-3 (indice 36)
REF_INDEX = 36
REF_VALUE = 0x0326

# Numero totale di note
NUM_NOTES = 96

# Calcola tutti i valori
inc_table = [0] * NUM_NOTES

for i in range(NUM_NOTES):
    if i == REF_INDEX:
        inc_table[i] = REF_VALUE
    else:
        semitones_from_ref = i - REF_INDEX
        frequency_ratio = 2.0 ** (semitones_from_ref / 12.0)
        inc_table[i] = int(round(REF_VALUE * frequency_ratio))

# Genera il codice ugBasic
print("' Tabella degli incrementi per le note (c-0 a b-7)")
print("' Valore di riferimento: c-3 (indice 24) = $0326")
print("DIM incTable(95) AS WORD")
print()

# Prima stampa tutti i valori PRIMA dell'indice 24
print("' Note prima di c-2 (indici 0-23)")
for i in range(0, 36):
    hex_val = f"${inc_table[i]:04X}"
    print(f"incTable({i}) = {hex_val}")
print()

# Poi stampa il valore di riferimento
print("' Valore di riferimento - c-3 (indice 36)")
print(f"incTable({REF_INDEX}) = ${REF_VALUE:04X}")
print()

# Infine stampa tutti i valori DOPO l'indice 24
print("' Note dopo c-2 (indici 25-95)")
for i in range(37, NUM_NOTES):
    hex_val = f"${inc_table[i]:04X}"
    print(f"incTable({i}) = {hex_val}")
