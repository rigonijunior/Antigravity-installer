#!/bin/bash
# Unified Installer / Updater — Antigravity 2.0 & Antigravity IDE
# Supports installation via auto-detect in ~/Downloads,
# or update via download URL or local .tar.gz path.
# Includes automatic backup of previous installation, XDG permission fixes,
# and multi-language support (English, Portuguese, Italian, Spanish).
#
# License: GPL-3.0 — https://www.gnu.org/licenses/gpl-3.0.html

set -e

# ============================================================
# ROOT CHECK (before language selection)
# ============================================================
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root (use sudo)."
    echo "ERRO: Este script deve ser executado como root (utilize sudo)."
    exit 1
fi

# ============================================================
# GLOBAL VARIABLES
# ============================================================
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
LOCAL_SHARE="$USER_HOME/.local/share"
APPS_DIR="$LOCAL_SHARE/applications"
ICONS_DIR="$LOCAL_SHARE/icons/hicolor/512x512/apps"

TARGET_DIR_20="/opt/antigravity"
TARGET_DIR_IDE="/opt/antigravity-ide"

TEMP_DIR=""

# ============================================================
# LANGUAGE SELECTION
# ============================================================

select_language() {
    echo ""
    echo "==========================================="
    echo "  Select Language / Selecione o Idioma"
    echo "==========================================="
    echo ""
    echo "  1) English"
    echo "  2) Português"
    echo "  3) Italiano"
    echo "  4) Español"
    echo ""
    read -rp "Choose / Escolha / Scegli / Elija [1-4]: " LANG_CHOICE

    case "$LANG_CHOICE" in
        1) set_lang_en ;;
        2) set_lang_pt ;;
        3) set_lang_it ;;
        4) set_lang_es ;;
        *) set_lang_en ;;  # Default to English
    esac
}

# ============================================================
# LANGUAGE PACKS
# ============================================================

set_lang_en() {
    # --- Sandbox ---
    MSG_SANDBOX_OK="[OK] Sandbox SUID set at:"
    MSG_SANDBOX_WARN="[WARN] Sandbox helper not found at:"

    # --- resolve_tarball ---
    MSG_URL_DETECTED="[INFO] URL detected. Starting download..."
    MSG_ERR_NO_DOWNLOADER="ERROR: Neither 'wget' nor 'curl' found. Install one of them and try again."
    MSG_ERR_DOWNLOAD_FAIL="ERROR: Download failed or file is empty."
    MSG_FILE_DOWNLOADED="[OK] File downloaded to:"
    MSG_ERR_FILE_NOT_FOUND="ERROR: File not found at:"
    MSG_FILE_FOUND="[OK] Local file found:"

    # --- backup_existing ---
    MSG_EXISTING_DETECTED="[INFO] Existing installation detected at"
    MSG_REMOVING_BACKUP="[INFO] Removing previous backup"
    MSG_CREATING_BACKUP="[INFO] Creating backup:"
    MSG_BACKUP_OK="[OK] Backup created successfully."
    MSG_NO_PREVIOUS="[INFO] No previous installation found at"
    MSG_CLEAN_INSTALL="Clean install."

    # --- install_antigravity ---
    MSG_CONFIGURING_20="--- Configuring Antigravity 2.0 ---"
    MSG_FILE_LABEL="[INFO] File:"
    MSG_INTERNAL_DIR="[INFO] Internal directory detected:"
    MSG_EXTRACTING="Extracting"
    MSG_MOVING_TO="Moving to"
    MSG_EXTRACTING_ICON="Extracting icon from app.asar via npx..."
    MSG_CREATING_DESKTOP="Creating .desktop entry..."
    MSG_AG20_OK="[OK] Antigravity 2.0 installed successfully!"

    # --- install_ide ---
    MSG_CONFIGURING_IDE="--- Configuring Antigravity IDE ---"
    MSG_IDE_ICON_CONFIG="Configuring IDE icon..."
    MSG_IDE_ICON_OK="[OK] IDE icon configured."
    MSG_IDE_ICON_WARN="[WARN] Could not find icon code.png."
    MSG_IDE_OK="[OK] Antigravity IDE installed successfully!"

    # --- update_desktop_cache ---
    MSG_UPDATING_CACHE="--- Updating desktop cache ---"

    # --- cleanup ---
    MSG_CLEANING_TEMP="[INFO] Cleaning up temporary files..."

    # --- show_menu ---
    MSG_MENU_TITLE="Installer / Updater Antigravity"
    MSG_MENU_OPT1="1) Install / Update — provide a URL or local path"
    MSG_MENU_OPT2="2) Exit"
    MSG_MENU_PROMPT="Choose an option [1-2]:"

    # --- ask_product ---
    MSG_PRODUCT_TITLE="Which product do you want to install or update?"
    MSG_PRODUCT_OPT1="1) Antigravity 2.0"
    MSG_PRODUCT_OPT2="2) Antigravity IDE"
    MSG_PRODUCT_PROMPT="Choose [1-2]:"

    # --- ask_source ---
    MSG_SOURCE_PROMPT="Provide the URL or local path of the .tar.gz file:"
    MSG_ERR_EMPTY_INPUT="ERROR: No input provided."

    # --- main flow ---
    MSG_ERR_INVALID_OPT="ERROR: Invalid option."
    MSG_EXIT="Exiting. See you soon!"
    MSG_DONE="=== Process Complete! ==="
}

set_lang_pt() {
    # --- Sandbox ---
    MSG_SANDBOX_OK="[OK] Sandbox SUID configurada em:"
    MSG_SANDBOX_WARN="[AVISO] Helper da sandbox não encontrado em:"

    # --- resolve_tarball ---
    MSG_URL_DETECTED="[INFO] URL detetada. A iniciar download..."
    MSG_ERR_NO_DOWNLOADER="ERRO: Nenhum 'wget' ou 'curl' encontrado. Instale um deles e tente novamente."
    MSG_ERR_DOWNLOAD_FAIL="ERRO: O download falhou ou o ficheiro está vazio."
    MSG_FILE_DOWNLOADED="[OK] Ficheiro transferido para:"
    MSG_ERR_FILE_NOT_FOUND="ERRO: Ficheiro não encontrado em:"
    MSG_FILE_FOUND="[OK] Ficheiro local encontrado:"

    # --- backup_existing ---
    MSG_EXISTING_DETECTED="[INFO] Instalação existente detetada em"
    MSG_REMOVING_BACKUP="[INFO] A remover backup anterior"
    MSG_CREATING_BACKUP="[INFO] A criar backup:"
    MSG_BACKUP_OK="[OK] Backup criado com sucesso."
    MSG_NO_PREVIOUS="[INFO] Nenhuma instalação anterior encontrada em"
    MSG_CLEAN_INSTALL="Instalação limpa."

    # --- install_antigravity ---
    MSG_CONFIGURING_20="--- A configurar o Antigravity 2.0 ---"
    MSG_FILE_LABEL="[INFO] Ficheiro:"
    MSG_INTERNAL_DIR="[INFO] Pasta interna detetada:"
    MSG_EXTRACTING="A extrair"
    MSG_MOVING_TO="A mover para"
    MSG_EXTRACTING_ICON="A extrair o ícone do app.asar via npx..."
    MSG_CREATING_DESKTOP="A criar a entrada .desktop..."
    MSG_AG20_OK="[OK] Antigravity 2.0 instalado com sucesso!"

    # --- install_ide ---
    MSG_CONFIGURING_IDE="--- A configurar o Antigravity IDE ---"
    MSG_IDE_ICON_CONFIG="A configurar o ícone do IDE..."
    MSG_IDE_ICON_OK="[OK] Ícone do IDE configurado."
    MSG_IDE_ICON_WARN="[AVISO] Não foi possível encontrar o ícone code.png."
    MSG_IDE_OK="[OK] Antigravity IDE instalado com sucesso!"

    # --- update_desktop_cache ---
    MSG_UPDATING_CACHE="--- A atualizar a cache do ambiente de trabalho ---"

    # --- cleanup ---
    MSG_CLEANING_TEMP="[INFO] A limpar ficheiros temporários..."

    # --- show_menu ---
    MSG_MENU_TITLE="Instalador / Atualizador Antigravity"
    MSG_MENU_OPT1="1) Instalar / Atualizar — forneça URL ou caminho local"
    MSG_MENU_OPT2="2) Sair"
    MSG_MENU_PROMPT="Escolha uma opção [1-2]:"

    # --- ask_product ---
    MSG_PRODUCT_TITLE="Qual produto deseja instalar ou atualizar?"
    MSG_PRODUCT_OPT1="1) Antigravity 2.0"
    MSG_PRODUCT_OPT2="2) Antigravity IDE"
    MSG_PRODUCT_PROMPT="Escolha [1-2]:"

    # --- ask_source ---
    MSG_SOURCE_PROMPT="Forneça a URL ou o caminho local do ficheiro .tar.gz:"
    MSG_ERR_EMPTY_INPUT="ERRO: Nenhuma entrada fornecida."

    # --- main flow ---
    MSG_ERR_INVALID_OPT="ERRO: Opção inválida."
    MSG_EXIT="A sair. Até breve!"
    MSG_DONE="=== Processo Concluído! ==="
}

set_lang_it() {
    # --- Sandbox ---
    MSG_SANDBOX_OK="[OK] Sandbox SUID configurata in:"
    MSG_SANDBOX_WARN="[AVVISO] Helper della sandbox non trovato in:"

    # --- resolve_tarball ---
    MSG_URL_DETECTED="[INFO] URL rilevata. Avvio del download..."
    MSG_ERR_NO_DOWNLOADER="ERRORE: Né 'wget' né 'curl' trovati. Installarne uno e riprovare."
    MSG_ERR_DOWNLOAD_FAIL="ERRORE: Il download è fallito o il file è vuoto."
    MSG_FILE_DOWNLOADED="[OK] File scaricato in:"
    MSG_ERR_FILE_NOT_FOUND="ERRORE: File non trovato in:"
    MSG_FILE_FOUND="[OK] File locale trovato:"

    # --- backup_existing ---
    MSG_EXISTING_DETECTED="[INFO] Installazione esistente rilevata in"
    MSG_REMOVING_BACKUP="[INFO] Rimozione del backup precedente"
    MSG_CREATING_BACKUP="[INFO] Creazione del backup:"
    MSG_BACKUP_OK="[OK] Backup creato con successo."
    MSG_NO_PREVIOUS="[INFO] Nessuna installazione precedente trovata in"
    MSG_CLEAN_INSTALL="Installazione pulita."

    # --- install_antigravity ---
    MSG_CONFIGURING_20="--- Configurazione di Antigravity 2.0 ---"
    MSG_FILE_LABEL="[INFO] File:"
    MSG_INTERNAL_DIR="[INFO] Cartella interna rilevata:"
    MSG_EXTRACTING="Estrazione di"
    MSG_MOVING_TO="Spostamento in"
    MSG_EXTRACTING_ICON="Estrazione dell'icona da app.asar tramite npx..."
    MSG_CREATING_DESKTOP="Creazione della voce .desktop..."
    MSG_AG20_OK="[OK] Antigravity 2.0 installato con successo!"

    # --- install_ide ---
    MSG_CONFIGURING_IDE="--- Configurazione di Antigravity IDE ---"
    MSG_IDE_ICON_CONFIG="Configurazione dell'icona dell'IDE..."
    MSG_IDE_ICON_OK="[OK] Icona dell'IDE configurata."
    MSG_IDE_ICON_WARN="[AVVISO] Impossibile trovare l'icona code.png."
    MSG_IDE_OK="[OK] Antigravity IDE installato con successo!"

    # --- update_desktop_cache ---
    MSG_UPDATING_CACHE="--- Aggiornamento della cache del desktop ---"

    # --- cleanup ---
    MSG_CLEANING_TEMP="[INFO] Pulizia dei file temporanei..."

    # --- show_menu ---
    MSG_MENU_TITLE="Installatore / Aggiornatore Antigravity"
    MSG_MENU_OPT1="1) Installare / Aggiornare — fornire un URL o percorso locale"
    MSG_MENU_OPT2="2) Uscire"
    MSG_MENU_PROMPT="Scegli un'opzione [1-2]:"

    # --- ask_product ---
    MSG_PRODUCT_TITLE="Quale prodotto desideri installare o aggiornare?"
    MSG_PRODUCT_OPT1="1) Antigravity 2.0"
    MSG_PRODUCT_OPT2="2) Antigravity IDE"
    MSG_PRODUCT_PROMPT="Scegli [1-2]:"

    # --- ask_source ---
    MSG_SOURCE_PROMPT="Fornisci l'URL o il percorso locale del file .tar.gz:"
    MSG_ERR_EMPTY_INPUT="ERRORE: Nessun input fornito."

    # --- main flow ---
    MSG_ERR_INVALID_OPT="ERRORE: Opzione non valida."
    MSG_EXIT="Uscita. A presto!"
    MSG_DONE="=== Processo Completato! ==="
}

set_lang_es() {
    # --- Sandbox ---
    MSG_SANDBOX_OK="[OK] Sandbox SUID configurada en:"
    MSG_SANDBOX_WARN="[AVISO] Helper de sandbox no encontrado en:"

    # --- resolve_tarball ---
    MSG_URL_DETECTED="[INFO] URL detectada. Iniciando descarga..."
    MSG_ERR_NO_DOWNLOADER="ERROR: No se encontró 'wget' ni 'curl'. Instale uno de ellos e intente de nuevo."
    MSG_ERR_DOWNLOAD_FAIL="ERROR: La descarga falló o el archivo está vacío."
    MSG_FILE_DOWNLOADED="[OK] Archivo descargado en:"
    MSG_ERR_FILE_NOT_FOUND="ERROR: Archivo no encontrado en:"
    MSG_FILE_FOUND="[OK] Archivo local encontrado:"

    # --- backup_existing ---
    MSG_EXISTING_DETECTED="[INFO] Instalación existente detectada en"
    MSG_REMOVING_BACKUP="[INFO] Eliminando respaldo anterior"
    MSG_CREATING_BACKUP="[INFO] Creando respaldo:"
    MSG_BACKUP_OK="[OK] Respaldo creado con éxito."
    MSG_NO_PREVIOUS="[INFO] No se encontró instalación previa en"
    MSG_CLEAN_INSTALL="Instalación limpia."

    # --- install_antigravity ---
    MSG_CONFIGURING_20="--- Configurando Antigravity 2.0 ---"
    MSG_FILE_LABEL="[INFO] Archivo:"
    MSG_INTERNAL_DIR="[INFO] Carpeta interna detectada:"
    MSG_EXTRACTING="Extrayendo"
    MSG_MOVING_TO="Moviendo a"
    MSG_EXTRACTING_ICON="Extrayendo el ícono de app.asar vía npx..."
    MSG_CREATING_DESKTOP="Creando la entrada .desktop..."
    MSG_AG20_OK="[OK] ¡Antigravity 2.0 instalado con éxito!"

    # --- install_ide ---
    MSG_CONFIGURING_IDE="--- Configurando Antigravity IDE ---"
    MSG_IDE_ICON_CONFIG="Configurando el ícono del IDE..."
    MSG_IDE_ICON_OK="[OK] Ícono del IDE configurado."
    MSG_IDE_ICON_WARN="[AVISO] No se pudo encontrar el ícono code.png."
    MSG_IDE_OK="[OK] ¡Antigravity IDE instalado con éxito!"

    # --- update_desktop_cache ---
    MSG_UPDATING_CACHE="--- Actualizando la caché del escritorio ---"

    # --- cleanup ---
    MSG_CLEANING_TEMP="[INFO] Limpiando archivos temporales..."

    # --- show_menu ---
    MSG_MENU_TITLE="Instalador / Actualizador Antigravity"
    MSG_MENU_OPT1="1) Instalar / Actualizar — proporcione una URL o ruta local"
    MSG_MENU_OPT2="2) Salir"
    MSG_MENU_PROMPT="Elija una opción [1-2]:"

    # --- ask_product ---
    MSG_PRODUCT_TITLE="¿Qué producto desea instalar o actualizar?"
    MSG_PRODUCT_OPT1="1) Antigravity 2.0"
    MSG_PRODUCT_OPT2="2) Antigravity IDE"
    MSG_PRODUCT_PROMPT="Elija [1-2]:"

    # --- ask_source ---
    MSG_SOURCE_PROMPT="Proporcione la URL o la ruta local del archivo .tar.gz:"
    MSG_ERR_EMPTY_INPUT="ERROR: No se proporcionó ninguna entrada."

    # --- main flow ---
    MSG_ERR_INVALID_OPT="ERROR: Opción inválida."
    MSG_EXIT="¡Saliendo. Hasta pronto!"
    MSG_DONE="=== ¡Proceso Completado! ==="
}

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

fix_sandbox() {
    local sandbox_path="$1"
    if [ -f "$sandbox_path" ]; then
        chown root:root "$sandbox_path"
        chmod 4755 "$sandbox_path"
        echo "$MSG_SANDBOX_OK $sandbox_path"
    else
        echo "$MSG_SANDBOX_WARN $sandbox_path"
    fi
}

# Receives user input (URL or local path).
# If URL, downloads to a temporary directory.
# Prints the final local path of the .tar.gz to stdout.
resolve_tarball() {
    local input="$1"

    if [[ "$input" =~ ^https?:// ]]; then
        echo "$MSG_URL_DETECTED" >&2
        TEMP_DIR=$(mktemp -d /tmp/antigravity-update-XXXX)

        local filename
        filename=$(basename "$input")
        local dest="$TEMP_DIR/$filename"

        if command -v wget &>/dev/null; then
            wget -q --show-progress -O "$dest" "$input"
        elif command -v curl &>/dev/null; then
            curl -L --progress-bar -o "$dest" "$input"
        else
            echo "$MSG_ERR_NO_DOWNLOADER" >&2
            exit 1
        fi

        if [ ! -s "$dest" ]; then
            echo "$MSG_ERR_DOWNLOAD_FAIL" >&2
            exit 1
        fi

        echo "$MSG_FILE_DOWNLOADED $dest" >&2
        echo "$dest"
    else
        if [ ! -f "$input" ]; then
            echo "$MSG_ERR_FILE_NOT_FOUND $input" >&2
            exit 1
        fi
        echo "$MSG_FILE_FOUND $input" >&2
        echo "$input"
    fi
}

# Backs up the existing installation: /opt/X → /opt/X.bak
backup_existing() {
    local target_dir="$1"
    local backup_dir="${target_dir}.bak"

    if [ -d "$target_dir" ]; then
        echo "$MSG_EXISTING_DETECTED $target_dir."
        if [ -d "$backup_dir" ]; then
            echo "$MSG_REMOVING_BACKUP ($backup_dir)..."
            rm -rf "$backup_dir"
        fi
        echo "$MSG_CREATING_BACKUP $target_dir → $backup_dir"
        mv "$target_dir" "$backup_dir"
        echo "$MSG_BACKUP_OK"
    else
        echo "$MSG_NO_PREVIOUS $target_dir. $MSG_CLEAN_INSTALL"
    fi
}

# ============================================================
# INSTALLATION FUNCTIONS
# ============================================================

# Installs Antigravity 2.0 from a tarball path.
# Argument $1: path to the .tar.gz file
install_antigravity() {
    local tarball="$1"

    echo ""
    echo "$MSG_CONFIGURING_20"
    echo "$MSG_FILE_LABEL $(basename "$tarball")"

    local root_dir
    root_dir=$(tar -tf "$tarball" | head -n 1 | cut -d/ -f1)
    echo "$MSG_INTERNAL_DIR $root_dir"

    local extract_base
    extract_base=$(dirname "$tarball")
    local src_dir="$extract_base/$root_dir"

    if [ ! -d "$src_dir" ]; then
        echo "$MSG_EXTRACTING $(basename "$tarball")..."
        tar -xzf "$tarball" -C "$extract_base"
    fi

    backup_existing "$TARGET_DIR_20"
    echo "$MSG_MOVING_TO $TARGET_DIR_20..."
    mv "$src_dir" "$TARGET_DIR_20"

    fix_sandbox "$TARGET_DIR_20/chrome-sandbox"

    echo "$MSG_EXTRACTING_ICON"
    su - "$REAL_USER" -c "cd /tmp && npx --yes asar extract-file $TARGET_DIR_20/resources/app.asar icon.png"

    mkdir -p "$ICONS_DIR"
    mv /tmp/icon.png "$ICONS_DIR/antigravity.png"
    chown "$REAL_USER":"$REAL_USER" "$ICONS_DIR/antigravity.png"

    echo "$MSG_CREATING_DESKTOP"
    mkdir -p "$APPS_DIR"
    cat > "$APPS_DIR/antigravity.desktop" <<EOF
[Desktop Entry]
Name=Antigravity 2.0
Comment=Google Antigravity
Exec=$TARGET_DIR_20/antigravity %U
Terminal=false
Type=Application
Icon=antigravity
Categories=Development;
StartupNotify=true
StartupWMClass=Antigravity
MimeType=x-scheme-handler/antigravity;
EOF
    chown "$REAL_USER":"$REAL_USER" "$APPS_DIR/antigravity.desktop"
    chmod +x "$APPS_DIR/antigravity.desktop"
    echo "$MSG_AG20_OK"
}

# Installs Antigravity IDE from a tarball path.
# Argument $1: path to the .tar.gz file
install_ide() {
    local tarball="$1"

    echo ""
    echo "$MSG_CONFIGURING_IDE"
    echo "$MSG_FILE_LABEL $(basename "$tarball")"

    local root_dir
    root_dir=$(tar -tf "$tarball" | head -n 1 | cut -d/ -f1)
    echo "$MSG_INTERNAL_DIR $root_dir"

    local extract_base
    extract_base=$(dirname "$tarball")
    local src_dir="$extract_base/$root_dir"

    if [ ! -d "$src_dir" ]; then
        echo "$MSG_EXTRACTING $(basename "$tarball")..."
        tar -xzf "$tarball" -C "$extract_base"
    fi

    backup_existing "$TARGET_DIR_IDE"
    echo "$MSG_MOVING_TO $TARGET_DIR_IDE..."
    mv "$src_dir" "$TARGET_DIR_IDE"

    fix_sandbox "$TARGET_DIR_IDE/chrome-sandbox"

    echo "$MSG_IDE_ICON_CONFIG"
    mkdir -p "$ICONS_DIR"

    local icon_path=""
    if [ -f "$TARGET_DIR_IDE/resources/app/resources/linux/code.png" ]; then
        icon_path="$TARGET_DIR_IDE/resources/app/resources/linux/code.png"
    elif [ -f "$TARGET_DIR_IDE/antigravity-ide/resources/app/resources/linux/code.png" ]; then
        icon_path="$TARGET_DIR_IDE/antigravity-ide/resources/app/resources/linux/code.png"
    fi

    if [ -n "$icon_path" ] && [ -f "$icon_path" ]; then
        cp "$icon_path" "$ICONS_DIR/antigravity-ide.png"
        chown "$REAL_USER":"$REAL_USER" "$ICONS_DIR/antigravity-ide.png"
        echo "$MSG_IDE_ICON_OK"
    else
        echo "$MSG_IDE_ICON_WARN"
    fi

    echo "$MSG_CREATING_DESKTOP"
    mkdir -p "$APPS_DIR"
    cat > "$APPS_DIR/antigravity-ide.desktop" <<EOF
[Desktop Entry]
Name=Antigravity IDE
Comment=Google Antigravity IDE
Exec=$TARGET_DIR_IDE/antigravity-ide %U
Terminal=false
Type=Application
Icon=antigravity-ide
Categories=Development;IDE;
StartupNotify=true
StartupWMClass=Antigravity-IDE
EOF
    chown "$REAL_USER":"$REAL_USER" "$APPS_DIR/antigravity-ide.desktop"
    chmod +x "$APPS_DIR/antigravity-ide.desktop"
    echo "$MSG_IDE_OK"
}

# ============================================================
# FINALIZATION
# ============================================================

update_desktop_cache() {
    echo ""
    echo "$MSG_UPDATING_CACHE"

    if [ -d "$LOCAL_SHARE/icons" ]; then
        chown -R "$REAL_USER":"$REAL_USER" "$LOCAL_SHARE/icons"
    fi

    su - "$REAL_USER" -c "update-desktop-database $APPS_DIR"
    su - "$REAL_USER" -c "mkdir -p $LOCAL_SHARE/icons/hicolor && gtk-update-icon-cache -t $LOCAL_SHARE/icons/hicolor || true"
}

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        echo "$MSG_CLEANING_TEMP"
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# ============================================================
# INTERACTIVE MENUS
# ============================================================

show_menu() {
    echo ""
    echo "==========================================="
    echo "  $MSG_MENU_TITLE"
    echo "==========================================="
    echo ""
    echo "  $MSG_MENU_OPT1"
    echo "  $MSG_MENU_OPT2"
    echo ""
    read -rp "$MSG_MENU_PROMPT " MENU_CHOICE
}

ask_product() {
    echo ""
    echo "$MSG_PRODUCT_TITLE"
    echo "  $MSG_PRODUCT_OPT1"
    echo "  $MSG_PRODUCT_OPT2"
    echo ""
    read -rp "$MSG_PRODUCT_PROMPT " PRODUCT_CHOICE
}

ask_source() {
    echo ""
    read -rp "$MSG_SOURCE_PROMPT " SOURCE_INPUT
    if [ -z "$SOURCE_INPUT" ]; then
        echo "$MSG_ERR_EMPTY_INPUT"
        exit 1
    fi
}

# ============================================================
# MAIN FLOW
# ============================================================

# Step 1: Select language (before anything else)
select_language

# Step 2: Show main menu
show_menu

case "$MENU_CHOICE" in
    1)
        # ---- INSTALL / UPDATE MODE ----
        ask_product
        ask_source

        # resolve_tarball: info messages go to stderr,
        # only the final file path goes to stdout.
        TARBALL_PATH=$(resolve_tarball "$SOURCE_INPUT")

        case "$PRODUCT_CHOICE" in
            1)
                install_antigravity "$TARBALL_PATH"
                ;;
            2)
                install_ide "$TARBALL_PATH"
                ;;
            *)
                echo "$MSG_ERR_INVALID_OPT"
                exit 1
                ;;
        esac
        ;;

    2)
        echo "$MSG_EXIT"
        exit 0
        ;;

    *)
        echo "$MSG_ERR_INVALID_OPT"
        exit 1
        ;;
esac

update_desktop_cache

echo ""
echo "$MSG_DONE"
