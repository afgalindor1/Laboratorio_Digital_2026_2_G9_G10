#!/usr/bin/env python3
"""
bin2hex.py — Convierte el binario del programa en firmware.hex

firmware.hex tiene una palabra de 32 bits (8 dígitos hexadecimales) por línea,
que es el formato que lee $readmemh en Memory.v.

RISC-V es "little endian": el byte de la dirección más baja es el menos
significativo de la palabra. Por eso los 4 bytes se leen en ese orden.

Uso: python3 bin2hex.py firmware.bin firmware.hex 8192
"""
import sys

entrada, salida, palabras = sys.argv[1], sys.argv[2], int(sys.argv[3])

with open(entrada, "rb") as f:
    datos = f.read()

datos += b"\x00" * (-len(datos) % 4)          # completar a múltiplo de 4 bytes
usadas = len(datos) // 4

if usadas > palabras:
    sys.exit(f"ERROR: el programa ocupa {usadas} palabras y la RAM tiene {palabras}.")

with open(salida, "w") as f:
    for i in range(palabras):
        if i < usadas:
            palabra = int.from_bytes(datos[4 * i:4 * i + 4], "little")
        else:
            palabra = 0
        f.write(f"{palabra:08x}\n")

print(f"firmware.hex: {usadas} de {palabras} palabras usadas ({100 * usadas / palabras:.1f} %)")
