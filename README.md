# Antigravity Installer

> **A unified installer and updater for Google Antigravity 2.0 and Antigravity IDE on Linux.**

---

## Table of Contents

- [Overview](#overview)
- [What Does This Installer Handle?](#what-does-this-installer-handle)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Step 1 — Download the Packages](#step-1--download-the-packages)
  - [Step 2 — Clone This Repository](#step-2--clone-this-repository)
  - [Step 3 — Run the Installer](#step-3--run-the-installer)
- [Language Selection](#language-selection)
- [Usage Guide](#usage-guide)
  - [Install or Update via URL](#install-or-update-via-url)
  - [Install or Update via Local File](#install-or-update-via-local-file)
- [Where Things Get Installed](#where-things-get-installed)
- [How the Install / Update Process Works](#how-the-install--update-process-works)
- [Rollback to a Previous Version](#rollback-to-a-previous-version)
- [Troubleshooting](#troubleshooting)
- [Frequently Asked Questions](#frequently-asked-questions)
- [Architecture Overview](#architecture-overview)
- [License](#license)

---

## Overview

This project provides a single Bash script — `installAntigravity.sh` — that handles the **complete lifecycle** of two Google Antigravity products on Linux:

| Product | Description |
|---|---|
| **Antigravity 2.0** | The main Google Antigravity application (Electron-based) |
| **Antigravity IDE** | A full-featured code editor based on the Antigravity platform |

The script supports **multi-language menus** and two modes of operation:

```
┌───────────────────────────────────────────────────┐
│   Select Language / Selecione o Idioma            │
│                                                   │
│   1) English     2) Português                     │
│   3) Italiano    4) Español                       │
└───────────────────────────────────────────────────┘
             │
             ▼
┌───────────────────────────────────────────────────┐
│   Antigravity Installer / Updater                 │
│                                                   │
│   1) Install / Update — provide URL or local path │
│   2) Exit                                         │
└───────────────────────────────────────────────────┘
```

Whether you are setting up Antigravity for the first time or upgrading to the latest release, this script takes care of everything: extraction, file placement, sandbox permissions, desktop integration, icons, and safe backups — all in **your preferred language**.

---

## What Does This Installer Handle?

Here is everything the script does for you automatically:

```
 Download / Local .tar.gz
          │
          ▼
   ┌──────────────┐
   │  Extract the  │
   │   tarball     │
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐     ┌──────────────────┐
   │  Backup old   │────▶│  /opt/X  →  /opt/X.bak  │
   │  installation │     └──────────────────┘
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │  Move files   │──▶  /opt/antigravity
   │  to /opt      │     /opt/antigravity-ide
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │  Fix sandbox  │──▶  chmod 4755 chrome-sandbox
   │  permissions  │     (SUID root for Electron)
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │  Extract &    │──▶  ~/.local/share/icons/
   │  install icon │
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │  Create       │──▶  ~/.local/share/applications/
   │  .desktop     │     (app appears in your launcher)
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │  Update GTK   │──▶  Icons & shortcuts visible
   │  caches       │     immediately
   └──────────────┘
```

---

## Prerequisites

Before running the installer, make sure you have the following:

| Requirement | Why | How to Check |
|---|---|---|
| **Linux** (Ubuntu, Debian, Fedora, etc.) | The script targets Linux desktops | `uname -s` → `Linux` |
| **sudo / root access** | The script installs to `/opt/` and sets SUID on sandbox | `sudo echo ok` |
| **Node.js + npm** | Used to extract the icon from `app.asar` via `npx` | `node --version` |
| **wget** or **curl** | Required only for URL-based updates (download mode) | `wget --version` or `curl --version` |
| **tar** | To extract `.tar.gz` archives | `tar --version` |

> **Note:** Most Linux distributions ship with `tar`, `wget`, and `curl` pre-installed. You likely only need to ensure Node.js is available.

### Installing Node.js (if not present)

```bash
# Ubuntu / Debian
sudo apt update && sudo apt install -y nodejs npm

# Fedora
sudo dnf install -y nodejs npm

# Or use nvm (any distro)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install --lts
```

---

## Getting Started

### Step 1 — Download the Packages

Visit the official [Google Antigravity downloads page](https://antigravity.google/docs/getting-started) and download the Linux `.tar.gz` files for the products you want:

- `Antigravity-linux-x64-X.X.X.tar.gz` — for Antigravity 2.0
- `AntigravityIDE-linux-x64-X.X.X.tar.gz` — for Antigravity IDE

Save them to your **`~/Downloads`** folder. The installer auto-detects them there.

### Step 2 — Clone This Repository

```bash
git clone https://github.com/rigonijunior/Antigravity-installer.git
cd Antigravity-installer
```

### Step 3 — Run the Installer

```bash
sudo bash installAntigravity.sh
```

That's it! The interactive menu will guide you through the rest.

---

## Language Selection

The **very first screen** you'll see is the language selector. This determines the language of all menus, messages, warnings, and confirmations throughout the entire process.

```
===========================================
  Select Language / Selecione o Idioma
===========================================

  1) English
  2) Português
  3) Italiano
  4) Español

Choose / Escolha / Scegli / Elija [1-4]: _
```

| Choice | Language | All menus displayed in... |
|---|---|---|
| `1` | 🇬🇧 English | English |
| `2` | 🇧🇷 Português | Portuguese |
| `3` | 🇮🇹 Italiano | Italian |
| `4` | 🇪🇸 Español | Spanish |

> **Default:** If you press Enter without choosing or type an invalid number, the script defaults to **English**.

After selecting a language, all subsequent menus, status messages (`[INFO]`, `[OK]`, `[WARN]`), error messages, and prompts will be displayed in your chosen language. Here's a quick comparison:

**English:**
```
===========================================
  Installer / Updater Antigravity
===========================================

  1) Install / Update — provide a URL or local path
  2) Exit

Choose an option [1-2]:
```

**Português:**
```
===========================================
  Instalador / Atualizador Antigravity
===========================================

  1) Instalar / Atualizar — forneça URL ou caminho local
  2) Sair

Escolha uma opção [1-2]:
```

**Italiano:**
```
===========================================
  Installatore / Aggiornatore Antigravity
===========================================

  1) Installare / Aggiornare — fornire un URL o percorso locale
  2) Uscire

Scegli un'opzione [1-2]:
```

**Español:**
```
===========================================
  Instalador / Actualizador Antigravity
===========================================

  1) Instalar / Actualizar — proporcione una URL o ruta local
  2) Salir

Elija una opción [1-2]:
```

---

## Usage Guide

After selecting your language, you'll see the main menu (shown here in English):

```
===========================================
  Installer / Updater Antigravity
===========================================

  1) Install / Update — provide a URL or local path
  2) Exit

Choose an option [1-2]:
```

The flow is the **same for both first-time installation and updates**. You choose a product, then provide the source (a URL or a local file path). The script automatically detects if there's a previous installation and handles the backup for you.

---

### Install or Update via URL

You can paste the download link directly from the [Google Antigravity website](https://antigravity.google/docs/getting-started). The script will download it for you.

**Example session (English, first-time install via URL):**

```
$ sudo bash installAntigravity.sh

  Select Language / Selecione o Idioma
  ...
Choose / Escolha / Scegli / Elija [1-4]: 1

===========================================
  Installer / Updater Antigravity
===========================================

  1) Install / Update — provide a URL or local path
  2) Exit

Choose an option [1-2]: 1

Which product do you want to install or update?
  1) Antigravity 2.0
  2) Antigravity IDE

Choose [1-2]: 1

Provide the URL or local path of the .tar.gz file:
https://storage.googleapis.com/.../Antigravity.tar.gz

[INFO] URL detected. Starting download...
Antigravity.tar.gz     100%[========================>] 198.5M  12.3MB/s   in 16s
[OK] File downloaded to: /tmp/antigravity-update-a1b2/Antigravity.tar.gz

--- Configuring Antigravity 2.0 ---
[INFO] File: Antigravity.tar.gz
[INFO] Internal directory detected: Antigravity
Extracting Antigravity.tar.gz...
[INFO] No previous installation found at /opt/antigravity. Clean install.
Moving to /opt/antigravity...
[OK] Sandbox SUID set at: /opt/antigravity/chrome-sandbox
Extracting icon from app.asar via npx...
Creating .desktop entry...
[OK] Antigravity 2.0 installed successfully!

--- Updating desktop cache ---

[INFO] Cleaning up temporary files...

=== Process Complete! ===
```

> After this, you can find **Antigravity 2.0** and/or **Antigravity IDE** in your application launcher (GNOME Activities, KDE Menu, etc.).

If you run the same process **again with a newer version**, the script will automatically detect the existing installation and create a backup:

```
--- Configuring Antigravity 2.0 ---
[INFO] Existing installation detected at /opt/antigravity.
[INFO] Creating backup: /opt/antigravity → /opt/antigravity.bak
[OK] Backup created successfully.
Moving to /opt/antigravity...
[OK] Antigravity 2.0 installed successfully!
```

---

### Install or Update via Local File

If you already downloaded the `.tar.gz` manually, just provide its full path:

```
Provide the URL or local path of the .tar.gz file:
/home/user/Downloads/Antigravity-2.0.11.tar.gz

[OK] Local file found: /home/user/Downloads/Antigravity-2.0.11.tar.gz

--- Configuring Antigravity 2.0 ---
...
[OK] Antigravity 2.0 installed successfully!
```

---

## Where Things Get Installed

After a successful installation, here's where everything lives on your system:

```
/opt/
├── antigravity/                    ← Antigravity 2.0 application
│   ├── antigravity                 ← Main executable
│   ├── chrome-sandbox              ← Electron sandbox (SUID root)
│   ├── resources/
│   │   └── app.asar                ← Application bundle
│   └── ...
│
├── antigravity.bak/                ← Backup of previous version (if updated)
│
├── antigravity-ide/                ← Antigravity IDE application
│   ├── antigravity-ide             ← Main executable
│   ├── chrome-sandbox              ← Electron sandbox (SUID root)
│   ├── resources/
│   │   └── app/
│   │       └── resources/
│   │           └── linux/
│   │               └── code.png    ← IDE icon source
│   └── ...
│
└── antigravity-ide.bak/            ← Backup of previous IDE version (if updated)

~/.local/share/
├── applications/
│   ├── antigravity.desktop         ← Desktop entry for Antigravity 2.0
│   └── antigravity-ide.desktop     ← Desktop entry for Antigravity IDE
│
└── icons/hicolor/512x512/apps/
    ├── antigravity.png             ← Antigravity 2.0 icon
    └── antigravity-ide.png         ← Antigravity IDE icon
```

> **Important:** Your personal settings, extensions, and configurations for Antigravity IDE are stored in your home directory (e.g., `~/.config/antigravity-ide/`), **not** inside `/opt/`. This means updates will **never** erase your personal data.

---

## How the Install / Update Process Works

The process is **identical for both first-time installation and updates**. The script is designed to be safe and non-destructive:

```
 ┌───────────────────────────────────────────────────────────┐
 │                    UPDATE FLOW                            │
 ├───────────────────────────────────────────────────────────┤
 │                                                           │
 │  1. USER provides URL or local path                       │
 │          │                                                │
 │          ▼                                                │
 │  2. Script resolves the source                            │
 │     ┌─────────────┐     ┌──────────────┐                  │
 │     │ URL?         │────▶│ Download to  │                  │
 │     │ wget / curl  │     │ /tmp/...     │                  │
 │     └─────────────┘     └──────────────┘                  │
 │     ┌─────────────┐                                       │
 │     │ Local path?  │────▶ Use directly                    │
 │     └─────────────┘                                       │
 │          │                                                │
 │          ▼                                                │
 │  3. Backup existing installation                          │
 │     /opt/antigravity  →  /opt/antigravity.bak             │
 │     (previous .bak is removed)                            │
 │          │                                                │
 │          ▼                                                │
 │  4. Extract & install new version to /opt/antigravity     │
 │          │                                                │
 │          ▼                                                │
 │  5. Fix chrome-sandbox permissions (SUID)                 │
 │          │                                                │
 │          ▼                                                │
 │  6. Re-extract icon & recreate .desktop entry             │
 │          │                                                │
 │          ▼                                                │
 │  7. Update desktop & icon caches                          │
 │          │                                                │
 │          ▼                                                │
 │  8. Clean up temporary files                              │
 │                                                           │
 └───────────────────────────────────────────────────────────┘
```

### What is preserved during an update?

| Item | Preserved? | Why |
|---|---|---|
| User settings & config | ✅ Yes | Stored in `~/.config/`, outside `/opt/` |
| IDE extensions | ✅ Yes | Stored in user's home directory |
| Previous installation (backup) | ✅ Yes | Moved to `/opt/X.bak` for rollback |
| Desktop shortcuts | ✅ Recreated | Ensures they point to the correct paths |
| Application icon | ✅ Refreshed | Re-extracted from the new version |

---

## Rollback to a Previous Version

If something goes wrong after an update, you can easily roll back to the previous version:

```bash
# Rollback Antigravity 2.0
sudo rm -rf /opt/antigravity
sudo mv /opt/antigravity.bak /opt/antigravity

# Rollback Antigravity IDE
sudo rm -rf /opt/antigravity-ide
sudo mv /opt/antigravity-ide.bak /opt/antigravity-ide
```

> **Note:** Only one backup is kept at a time. Each update replaces the previous backup. If you need to keep multiple versions, manually copy the `.bak` directory before updating again.

---

## Troubleshooting

### "This script must be run as root"

You need to use `sudo`:

```bash
sudo bash installAntigravity.sh
```

### "No wget or curl found"

Install one of them:

```bash
# Ubuntu / Debian
sudo apt install -y wget

# Fedora
sudo dnf install -y wget
```

### "Sandbox helper not found"

This warning means the `chrome-sandbox` binary wasn't found in the extracted package. The application may still work using the kernel's user namespace sandbox. If Antigravity fails to launch, try running it with:

```bash
/opt/antigravity/antigravity --no-sandbox
```

### The app doesn't appear in my launcher

Try refreshing the desktop database manually:

```bash
update-desktop-database ~/.local/share/applications
gtk-update-icon-cache -t ~/.local/share/icons/hicolor
```

Or log out and log back in.

### "npx: command not found" or icon extraction fails

Make sure Node.js and npm are installed:

```bash
node --version
npm --version
```

If not installed, see the [Prerequisites](#prerequisites) section.

### Download fails with a URL

1. Check that the URL is correct and accessible in your browser
2. Make sure you have internet connectivity
3. Try downloading manually and using the **local path** option instead:
   ```bash
   wget -O ~/Downloads/Antigravity.tar.gz "https://storage.googleapis.com/..."
   # Then run the script and provide: /home/user/Downloads/Antigravity.tar.gz
   ```

---

## Frequently Asked Questions

### Can I install only Antigravity 2.0 without the IDE (or vice versa)?

**Yes.** The script asks you which product you want to install or update — you choose either **Antigravity 2.0** or **Antigravity IDE**. To install both, simply run the script twice, once for each product.

### Does the update erase my IDE extensions and settings?

**No.** Extensions, themes, keybindings, and all personal settings are stored in your home directory (typically `~/.config/antigravity-ide/`), completely separate from the application binaries in `/opt/`. The update only replaces the application files.

### Can I use this script on a headless server?

The script itself works fine on a headless server, but the `update-desktop-database` and `gtk-update-icon-cache` commands at the end are desktop-specific. They will fail silently (the script won't crash). However, Antigravity 2.0 and Antigravity IDE are GUI applications and require a display server (X11 or Wayland) to run.

### What happens if the download is interrupted?

The script uses `set -e`, so it will abort immediately if the download fails. No partial installation will occur. Your existing installation (if any) remains untouched because the backup only happens **after** the tarball is successfully downloaded and validated.

### Can I run the script multiple times?

**Yes.** The script is fully idempotent. Running it again will simply overwrite the current installation (with a backup) or skip products that aren't found.

### Where do the download URLs come from?

The URLs are provided by the official [Google Antigravity website](https://antigravity.google/docs/getting-started). This script does **not** search for or discover URLs automatically — you must provide them yourself when using the update feature.

---

## Architecture Overview

The script is structured into modular functions for maintainability:

```
installAntigravity.sh
│
├── Root & environment check
│   └── REAL_USER, USER_HOME, paths
│
├── Language system (i18n)
│   ├── select_language()    — Language selection menu
│   ├── set_lang_en()        — English language pack
│   ├── set_lang_pt()        — Portuguese language pack
│   ├── set_lang_it()        — Italian language pack
│   └── set_lang_es()        — Spanish language pack
│
├── Utility functions
│   ├── fix_sandbox()        — Set SUID on chrome-sandbox
│   ├── resolve_tarball()    — URL → download; local → validate
│   └── backup_existing()   — /opt/X → /opt/X.bak
│
├── Installation functions
│   ├── install_antigravity() — Full install flow for Antigravity 2.0
│   └── install_ide()         — Full install flow for Antigravity IDE
│
├── Finalization
│   ├── update_desktop_cache() — Refresh .desktop and icon caches
│   └── cleanup()              — Remove temp files (via trap EXIT)
│
├── Interactive menus
│   ├── show_menu()    — Main menu (Install/Update / Exit)
│   ├── ask_product()  — Which product to install or update
│   └── ask_source()   — URL or local path input
│
└── Main flow
    ├── Step 1: select_language → set MSG_* variables
    ├── Step 2: show_menu
    ├── Option 1: ask_product → ask_source → resolve → backup → install
    └── Option 2: Exit
```

### Key design decisions

- **`set -e`** — The script aborts on any error, preventing partial or corrupted installations.
- **`trap cleanup EXIT`** — Temporary files from URL downloads are always cleaned up, even on failure.
- **Extraction as real user** — In install mode, tarballs are extracted as the real user (not root) to avoid file ownership issues.
- **SUID sandbox** — The `chrome-sandbox` binary is given `4755` permissions with root ownership, which is required by Electron's sandboxing on Linux.
- **stderr vs stdout separation** — The `resolve_tarball()` function sends informational messages to stderr and only the resolved path to stdout, enabling clean capture by the caller.
- **i18n via MSG_ variables** — All user-facing strings are stored in `MSG_*` variables, set by `set_lang_XX()` functions. Adding a new language requires only adding a new function with translated strings.

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

You are free to use, modify, and distribute this software under the terms of the GPL-3.0 license. See the full license text at:

🔗 [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html)

```
Antigravity Installer — A unified installer/updater for Google Antigravity on Linux.
Copyright (C) 2025 Rigoni Junior

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.
```

---

<p align="center">
  <em>Built with ❤️ for the Antigravity community on Linux.</em>
</p>
