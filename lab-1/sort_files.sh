#!/bin/bash

# Проверка количества аргументов
if [ $# -ne 1 ]; then
    echo "Ошибка: Необходимо указать один аргумент - имя директории"
    exit 1
fi

directory="$1"

# Проверка существования директории
if [ ! -d "$directory" ]; then
    echo "Ошибка: Директория '$directory' не существует"
    exit 1
fi

# Вывод файлов, отсортированных по дате модификации
echo "Файлы в директории '$directory' (отсортированы по дате модификации):"
ls -lt "$directory" | grep -v '^total'

#./sort_files.sh /mnt/c/programapp/dsa-lab-22-61