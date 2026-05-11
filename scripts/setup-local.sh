#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${DB_NAME:-simulation_training}"
DB_USER="${DB_USER:-simulation_user}"
DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_ADMIN_USER="${DB_ADMIN_USER:-$(whoami)}"
CONFIG_FILE="$ROOT_DIR/config.local.php"

need_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        return 1
    fi
}

random_hex() {
    local bytes="$1"
    openssl rand -hex "$bytes"
}

if ! need_command brew; then
    echo "Homebrew is required. Install it from https://brew.sh, then run this script again."
    exit 1
fi

if ! need_command php; then
    echo "Installing PHP..."
    brew install php
fi

if ! need_command mariadb; then
    echo "Installing MariaDB..."
    brew install mariadb
fi

echo "Starting MariaDB..."
brew services start mariadb >/dev/null || true

for attempt in {1..20}; do
    if mariadb -u "$DB_ADMIN_USER" -e "SELECT 1;" >/dev/null 2>&1; then
        break
    fi

    if [ "$attempt" -eq 20 ]; then
        echo "Could not connect to MariaDB as '$DB_ADMIN_USER'."
        echo "Try running with DB_ADMIN_USER=<your-mariadb-admin-user> ./scripts/setup-local.sh"
        exit 1
    fi

    sleep 1
done

if [ -f "$CONFIG_FILE" ]; then
    DB_PASSWORD="$(php -r '$config = require $argv[1]; echo $config["db"]["password"] ?? "";' "$CONFIG_FILE")"
    HASH_SECRET="$(php -r '$config = require $argv[1]; echo $config["app"]["hash_secret"] ?? "";' "$CONFIG_FILE")"
else
    DB_PASSWORD="$(random_hex 16)"
    HASH_SECRET="$(random_hex 32)"
fi

if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD="$(random_hex 16)"
fi

if [ -z "$HASH_SECRET" ]; then
    HASH_SECRET="$(random_hex 32)"
fi

echo "Creating database and app user..."
mariadb -u "$DB_ADMIN_USER" -e "
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT INSERT, SELECT ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
"

echo "Creating tables..."
mariadb -u "$DB_ADMIN_USER" "$DB_NAME" < "$ROOT_DIR/schema.sql"

cat > "$CONFIG_FILE" <<PHP
<?php

return [
    'db' => [
        'host' => '$DB_HOST',
        'port' => $DB_PORT,
        'name' => '$DB_NAME',
        'user' => '$DB_USER',
        'password' => '$DB_PASSWORD',
        'charset' => 'utf8mb4',
    ],
    'app' => [
        'hash_secret' => '$HASH_SECRET',
    ],
];
PHP

echo
echo "Local setup complete."
echo "Run: ./scripts/run-local.sh"
echo "Open: http://127.0.0.1:8000/index.php"
