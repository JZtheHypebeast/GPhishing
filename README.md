# GPhishing Training Simulation

Local PHP/MariaDB training simulation. The password form records simulation metadata only. It does not store submitted password values.

## Quick Start On macOS

From a fresh clone:

```bash
./scripts/setup-local.sh
./scripts/run-local.sh
```

Open:

```text
http://127.0.0.1:8000/index.php
```

The setup script will:

- install PHP with Homebrew if missing
- install MariaDB with Homebrew if missing
- start MariaDB
- create the `simulation_training` database
- create the `simulation_user` database user
- create the `simulation_submissions` table from `schema.sql`
- generate `config.local.php`

`config.local.php` is ignored by Git because it contains local database credentials.

## Manual Setup

Install dependencies:

```bash
brew install php mariadb
brew services start mariadb
```

Create the database and table:

```bash
mariadb -u "$(whoami)" -e "CREATE DATABASE IF NOT EXISTS simulation_training CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb -u "$(whoami)" simulation_training < schema.sql
```

Create `config.local.php`:

```bash
cp config.sample.php config.local.php
```

Then edit `config.local.php` to match your local MariaDB user and password.

## Run

```bash
./scripts/run-local.sh
```

Use a different port if needed:

```bash
PORT=8080 ./scripts/run-local.sh
```

## Database Records

The app inserts rows into `simulation_submissions` with:

- identifier
- submitted password flag
- password length
- hashed IP address
- user agent
- timestamp

The submitted password value is intentionally discarded.
