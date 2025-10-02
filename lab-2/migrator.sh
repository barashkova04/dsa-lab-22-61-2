#!/bin/bash

# Параметры подключения
DB_NAME="rpp"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
MIGRATIONS_DIR="./migrations"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Логирование
log_info() { echo -e "${BLUE}  $1${NC}"; }
log_success() { echo -e "${GREEN} $1${NC}"; }
log_warning() { echo -e "${YELLOW}  $1${NC}"; }
log_error() { echo -e "${RED} $1${NC}"; }

# Проверка зависимостей
check_dependencies() {
    if ! command -v psql &> /dev/null; then
        log_error "psql не найден. Установите PostgreSQL:"
        echo "sudo apt update && sudo apt install postgresql postgresql-client"
        exit 1
    fi
    log_success "psql найден: $(psql --version | head -n1)"
}

# Проверка подключения к БД
check_db_connection() {
    log_info "Проверка подключения к БД..."
    if PGPASSWORD="$PGPASSWORD" psql -U "$DB_USER" -d "postgres" -h "$DB_HOST" -p "$DB_PORT" -c "SELECT 1;" &> /dev/null; then
        log_success "Подключение к PostgreSQL установлено"
        return 0
    else
        log_error "Не удалось подключиться к PostgreSQL"
        echo "Проверьте:"
        echo "1. Запущен ли сервер: sudo service postgresql status"
        echo "2. Параметры подключения"
        echo "3. Пароль пользователя postgres"
        return 1
    fi
}

# Создание базы данных если не существует
create_database() {
    log_info "Проверка базы данных $DB_NAME..."
    if PGPASSWORD="$PGPASSWORD" psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        log_success "База данных $DB_NAME существует"
    else
        log_warning "Создание базы данных $DB_NAME..."
        if PGPASSWORD="$PGPASSWORD" createdb -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" "$DB_NAME"; then
            log_success "База данных $DB_NAME создана"
        else
            log_error "Ошибка создания базы данных $DB_NAME"
            return 1
        fi
    fi
}

# Выполнение SQL команды
run_sql_c() {
    local sql="$1"
    PGPASSWORD="$PGPASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -t -c "$sql" 2>/dev/null
}

# Выполнение SQL файла
run_sql() {
    local file="$1"
    log_info "Выполнение: $(basename "$file")"
    if PGPASSWORD="$PGPASSWORD" psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -f "$file" -v ON_ERROR_STOP=1; then
        log_success "Файл выполнен успешно"
        return 0
    else
        log_error "Ошибка выполнения файла"
        return 1
    fi
}

# Создание таблицы миграций
create_migrations_table() {
    log_info "Создание таблицы миграций..."
    local sql="CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        migration_name VARCHAR(255) UNIQUE NOT NULL,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );"
    run_sql_c "$sql"
    log_success "Таблица migrations готова"
}

# Получение списка примененных миграций
get_applied_migrations() {
    run_sql_c "SELECT migration_name FROM migrations ORDER BY applied_at;" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
}

# Основная логика миграций
apply_migrations() {
    log_info "Поиск файлов миграций в $MIGRATIONS_DIR..."
    
    if [ ! -d "$MIGRATIONS_DIR" ]; then
        log_error "Директория $MIGRATIONS_DIR не существует"
        return 1
    fi
    
    local files=($(find "$MIGRATIONS_DIR" -name "*.sql" -type f | sort))
    
    if [ ${#files[@]} -eq 0 ]; then
        log_warning "SQL файлы не найдены"
        return 0
    fi
    
    log_info "Найдено ${#files[@]} файлов миграций"
    
    # Получаем примененные миграции
    declare -A applied_migrations
    while IFS= read -r migration; do
        [ -n "$migration" ] && applied_migrations["$migration"]=1
    done < <(get_applied_migrations)
    
    local applied=0
    local skipped=0
    local errors=0
    
    for file in "${files[@]}"; do
        local migration_name=$(basename "$file")
        
        if [[ ${applied_migrations["$migration_name"]+_} ]]; then
            log_info "Пропущено: $migration_name (уже применена)"
            ((skipped++))
        else
            log_info "Применение: $migration_name"
            if run_sql "$file"; then
                local escaped_name=$(echo "$migration_name" | sed "s/'/''/g")
                if run_sql_c "INSERT INTO migrations (migration_name) VALUES ('$escaped_name');"; then
                    log_success "Миграция применена: $migration_name"
                    ((applied++))
                else
                    log_error "Ошибка записи в историю: $migration_name"
                    ((errors++))
                fi
            else
                log_error "Ошибка применения: $migration_name"
                ((errors++))
            fi
        fi
    done
    
    echo "========================================"
    log_success "Применено: $applied"
    log_warning "Пропущено: $skipped"
    [ $errors -gt 0 ] && log_error "Ошибок: $errors" || log_success "Ошибок: $errors"
    echo "========================================"
    
    return $errors
}

# Главная функция
main() {
    echo "========================================"
    echo "PostgreSQL Мигратор"
    echo "========================================"
    
    check_dependencies
    check_db_connection || exit 1
    create_database || exit 1
    create_migrations_table
    apply_migrations
    
    if [ $? -eq 0 ]; then
        log_success "Миграции завершены успешно!"
    else
        log_error "Миграции завершены с ошибками!"
        exit 1
    fi
}

main "$@"
