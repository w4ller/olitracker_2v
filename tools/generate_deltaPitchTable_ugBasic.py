# generate_deltaPitchTable_ugbasic.py

PER_LINE = 8

def emit_values(K):
    vals = [(i * K) & 0xFFFF for i in range(256)]
    lines = []
    for i in range(0, 256, PER_LINE):
        chunk = vals[i:i+PER_LINE]
        line = ", ".join(f"${v:04X}" for v in chunk)
        # ugBasic continuation like your example
        if i + PER_LINE < 256:
            line += ", _"
        lines.append(line)
    return "\n    ".join(lines)

for K in (0x0004, 0x0002, 0x0001):
    print(f"\n' ---- deltaPitchTable K=${K:04X} ----")
    print("DIM deltaPitchTable AS WORD(256) = #{")
    print("    " + emit_values(K))
    print("} FOR BANK READ")
    print("GLOBAL deltaPitchTable")
