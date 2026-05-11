# GPhishing Training Simulation

Local PHP/MariaDB training simulation.

## 1. Clone The Repository

```bash
git clone git@github.com:JZtheHypebeast/GPhishing.git
cd GPhishing
```

## 2. Run Local Setup

macOS:

```bash
./scripts/setup-local.sh
```

Windows PowerShell:

```powershell
.\scripts\setup-local.ps1
```

If PowerShell blocks local scripts, run this once in the repo folder:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then rerun:

```powershell
.\scripts\setup-local.ps1
```

If MariaDB uses a root password on Windows:

```powershell
.\scripts\setup-local.ps1 -DbAdminUser root -DbAdminPassword "your-root-password"
```

The setup script installs or checks PHP and MariaDB, starts MariaDB, creates the database/user/table, and generates `config/local.php`.

## 3. Start The Local Site

macOS:

```bash
./scripts/run-local.sh
```

Windows PowerShell:

```powershell
.\scripts\run-local.ps1
```

Open:

```text
http://127.0.0.1:8000/index.php
```

Use another port if needed.

macOS:

```bash
PORT=8080 ./scripts/run-local.sh
```

Windows PowerShell:

```powershell
.\scripts\run-local.ps1 -Port 8080
```

## 4. View Database Records

From the VS Code terminal in the repo folder:

```bash
mariadb -u simulation_user -p$(php -r '$config = require "config/local.php"; echo $config["db"]["password"];') simulation_training -e "SELECT * FROM simulation_submissions ORDER BY created_at DESC;"
```

The table is:

```text
simulation_training.simulation_submissions
```

Current recorded fields:

```text
id
identifier
password
submitted_password
password_length
password_revealed
browser_agent
ip_address
created_at
```

## 5. Clear Test Records

Use your local MariaDB admin user:

```bash
mariadb -u "$(whoami)" simulation_training -e "DELETE FROM simulation_submissions; ALTER TABLE simulation_submissions AUTO_INCREMENT = 1;"
```

## 6. Project Structure

```text
app/        PHP application helpers
config/     Local and sample configuration
database/   SQL schema
public/     Web document root
scripts/    macOS and Windows setup/run scripts
```

`config/local.php` is ignored by Git because it contains local database credentials.
