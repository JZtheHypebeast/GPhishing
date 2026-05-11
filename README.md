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

## Quick Start On Windows

From a fresh clone, open PowerShell in the repo folder:

```powershell
.\scripts\setup-local.ps1
.\scripts\run-local.ps1
```

Open:

```text
http://127.0.0.1:8000/index.php
```

If PowerShell blocks local scripts, run this once in the repo folder:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then rerun:

```powershell
.\scripts\setup-local.ps1
```

If your MariaDB installer created a root password, pass it to the setup script:

```powershell
.\scripts\setup-local.ps1 -DbAdminUser root -DbAdminPassword "your-root-password"
```

## What Setup Does

The setup scripts will:

- install PHP with Homebrew if missing
- install MariaDB with Homebrew if missing
- on Windows, try to install PHP and MariaDB with `winget` if missing
- start MariaDB
- create the `simulation_training` database
- create the `simulation_user` database user
- create the `simulation_submissions` table from `database/schema.sql`
- generate `config/local.php`

`config/local.php` is ignored by Git because it contains local database credentials.

## Project Structure

```text
app/        PHP application helpers
config/     Local and sample configuration
database/   SQL schema
public/     Web document root
scripts/    macOS and Windows setup/run scripts
```

## Manual Setup

Install dependencies:

```bash
brew install php mariadb
brew services start mariadb
```

Create the database and table:

```bash
mariadb -u "$(whoami)" -e "CREATE DATABASE IF NOT EXISTS simulation_training CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mariadb -u "$(whoami)" simulation_training < database/schema.sql
```

Create `config/local.php`:

```bash
cp config/sample.php config/local.php
```

Then edit `config/local.php` to match your local MariaDB user and password.

## Run

macOS:

```bash
./scripts/run-local.sh
```

Windows:

```powershell
.\scripts\run-local.ps1
```

Use a different port if needed.

macOS:

```bash
PORT=8080 ./scripts/run-local.sh
```

Windows:

```powershell
.\scripts\run-local.ps1 -Port 8080
```

## Database Records

The app inserts rows into `simulation_submissions` with:

- identifier
- submitted password flag
- password length
- show-password checkbox usage
- timestamp

The submitted password value is intentionally discarded.
