#!/bin/bash

# El usuario necesita ser root
if [ "$EUID" -ne 0 ]
	then echo "[x] Necesita ser root"
	exit
fi

# Checkear si se ha introducido la ruta a copiar los logs
if [ -z "$1" ]; then
	echo "[i] Introduce la ruta para copiar todos los logs"
	echo "[i] Uso: $0 /ruta/a/copiar"
	exit
fi

# Comprobar si existe
if [ ! -d "$1" ]; then
	echo "[x] El directorio $1 no existe"
	exit
fi

# Cuidado con el Path Hijacking
files=$(/usr/bin/find / -type f -name "*.log.*" 2>/dev/null || /usr/bin/find / -type f -name "*.log" 2>/dev/null)

# Peso total en KB
total_weight=0

IFS=$'\n' # Establece el separador de campos como un salto de línea

for file in $files; do
    	weight=$(du -sh "$file" --block-size=K | awk '{print $1}' | sed 's/.$//')
	total_weight=$total_weight+$weight
done

total_weight=$(echo $total_weight | /usr/bin/bc)

echo "[i] El peso total de todos los logs encontrados es de:"
echo "$total_weight KB"

echo ""
echo "[0] Exportar los Logs"
echo "[1] Salir del programa"
read choice
/usr/bin/clear

if [ ! "$choice" -eq "0" ]; then
	exit
fi

for file in $files; do
	echo "Copiando... $file"
	$(/usr/bin/cp -f "$file" "$1" 2>/dev/null)
done

echo "[✔️] ¡Logs copiados exitosamente!"
