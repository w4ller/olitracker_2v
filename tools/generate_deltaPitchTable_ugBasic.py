# generate_deltaPitchTable_ugbasic.py

K = 0x0008          # scala base (prova anche 0x0004 o 0x0010)
PER_LINE = 8        # quante word per riga

vals = [(i * K) & 0xFFFF for i in range(256)]

print("DIM deltaPitchTable AS WORD(256) FOR BANK READ = {")
for i in range(0, 256, PER_LINE):
    chunk = vals[i:i+PER_LINE]
    line = ", ".join(f"${v:04X}" for v in chunk)
    comma = "," if (i + PER_LINE) < 256 else ""
    print(f"    {line}{comma}")
print("}")
