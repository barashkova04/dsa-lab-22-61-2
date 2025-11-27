#!/bin/bash

# Проверка количества аргументов
if [ $# -ne 3 ]; then
    echo "Ошибка: Необходимо указать три аргумента: число1 оператор число2"
    echo "Пример: $0 5 + 3"
    exit 1
fi

num1="$1"
operator="$2"
num2="$3"

# Проверка, что аргументы - числа
if ! [[ "$num1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || ! [[ "$num2" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Ошибка: Первый и третий аргументы должны быть числами"
    exit 1
fi

# Выполнение операции
case "$operator" in
    "+")
        result=$(echo "$num1 + $num2" | bc)
        ;;
    "-")
        result=$(echo "$num1 - $num2" | bc)
        ;;
    "*")
        result=$(echo "$num1 * $num2" | bc)
        ;;
    "/")
        if [ "$(echo "$num2 == 0" | bc)" -eq 1 ]; then
            echo "Ошибка: Деление на ноль невозможно"
            exit 1
        fi
        result=$(echo "scale=2; $num1 / $num2" | bc)
        ;;
    *)
        echo "Ошибка: Неподдерживаемый оператор '$operator'"
        echo "Поддерживаемые операторы: +, -, *, /"
        exit 1
        ;;
esac

echo "Результат: $result"

#./calculator.sh 10 + 5